# Claude Code runs its Bash tool under zsh. An unmatched glob passes through
# literally instead of aborting the command.
[[ -n $CLAUDECODE ]] && setopt no_nomatch no_equals
