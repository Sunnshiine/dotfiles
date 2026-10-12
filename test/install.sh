#!/bin/bash
set -uo pipefail
REPO=$1
T=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXX")
fail=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }

mkdir -p "$T/bin" "$T/home"
LOG="$T/calls.log"; : > "$LOG"
SHELLS="$T/etc-shells"; printf '/bin/zsh\n' > "$SHELLS"
LOGIN_SHELL="$T/login-shell"; echo /bin/zsh > "$LOGIN_SHELL"

stub() { printf '#!/bin/bash\n%s\n' "$2" > "$T/bin/$1"; chmod +x "$T/bin/$1"; }
stub brew  "case \$1 in shellenv) echo 'export PATH=$T/bin:\$PATH';; *) echo \"brew \$*\" >> $LOG;; esac"
stub sudo  "echo \"sudo \$*\" >> $LOG; \"\$@\""
stub chsh  "echo \"chsh \$*\" >> $LOG; echo \$2 > $LOGIN_SHELL"
stub dscl  "echo \"UserShell: \$(cat $LOGIN_SHELL)\""
stub git   "if [ \$1 = clone ]; then echo \"git clone \$2\" >> $LOG; exec /usr/bin/git clone -q $REPO \$3; fi; exec /usr/bin/git \"\$@\""
ln -s "$(command -v stow)" "$T/bin/stow"

sed -e "s#/opt/homebrew/bin/brew#$T/bin/brew-installed#g" \
    -e "s#/opt/homebrew/bin/fish#$T/bin/fish#g" \
    -e "s#/etc/shells#$SHELLS#g" \
    "$REPO/install" > "$T/install"
cat > "$T/bin/curl" <<STUB
#!/bin/bash
echo "curl \$*" >> $LOG
case "\$*" in
  *Homebrew*) cp $T/bin/brew $T/bin/brew-installed ;;
  *claude.ai*) echo 'echo installer-ran >> $LOG; mkdir -p \$HOME/.local/bin; touch \$HOME/.local/bin/claude; chmod +x \$HOME/.local/bin/claude' ;;
esac
STUB
chmod +x "$T/bin/curl"

run() { HOME="$T/home" USER=tester PATH="$T/bin:/usr/bin:/bin" /bin/bash -c "$(cat "$T/install")" > "$T/out.log" 2>&1; }

echo "# fresh machine"
run; rc=$?; [ $rc -eq 0 ] || tail -5 "$T/out.log"
check "exits 0" "[ $rc -eq 0 ]"
check "installs homebrew" "grep -q 'curl.*Homebrew' $LOG"
check "clones repo" "grep -q 'git clone https://github.com/Sunnshiine/dotfiles.git' $LOG"
check "runs brew bundle" "grep -q 'brew bundle --file=$T/home/.dotfiles/Brewfile' $LOG"
check "runs claude installer" "grep -q installer-ran $LOG"
check "adds fish to /etc/shells" "grep -qx $T/bin/fish $SHELLS"
check "changes login shell" "grep -q chsh $LOG"
check "fish config is a symlink into repo" "[ \"\$(readlink $T/home/.config/fish/config.fish)\" = ../../.dotfiles/home/.config/fish/config.fish ]"
check "fish config dir is a real dir" "[ -d $T/home/.config/fish ] && [ ! -L $T/home/.config/fish ]"
check ".claude is a real dir" "[ -d $T/home/.claude ] && [ ! -L $T/home/.claude ]"
check "claude settings linked" "[ -L $T/home/.claude/settings.json ]"
check "zshenv linked" "[ -L $T/home/.zshenv ]"

echo "# rerun"
: > "$LOG"; run; rc=$?
check "exits 0" "[ $rc -eq 0 ]"
check "no homebrew reinstall" "! grep -q Homebrew $LOG"
check "no re-clone" "! grep -q 'git clone' $LOG"
check "brew bundle runs again" "grep -q 'brew bundle' $LOG"
check "no claude reinstall" "! grep -q installer-ran $LOG"
check "no chsh" "! grep -q chsh $LOG"
check "/etc/shells not duplicated" "[ \$(grep -cx $T/bin/fish $SHELLS) -eq 1 ]"

echo "# conflicting real file"
rm "$T/home/.config/ghostty/config"; echo "mine" > "$T/home/.config/ghostty/config"
run; rc=$?; [ $rc -eq 0 ] || tail -5 "$T/out.log"
check "exits non-zero" "[ $rc -ne 0 ]"
check "reports conflict" "grep -q 'ghostty/config' $T/out.log"
check "leaves existing file untouched" "[ \"\$(cat $T/home/.config/ghostty/config)\" = mine ]"

rm -rf "$T"
exit $fail
