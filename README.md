# dotfiles

Set up a new Mac for agentic development with one command. The script installs the apps and command-line tools in the [`Brewfile`](Brewfile), links the configs in [`home/`](home) into your home folder, installs Claude Code, and makes fish the login shell.

The script is for Apple silicon Macs only. It installs the latest version of every package and pins nothing.

## Set up a new Mac

1. Open Terminal and run:

	```sh
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Sunnshiine/dotfiles/main/install)"
	```

	Homebrew asks for your password and installs the Xcode Command Line Tools. The script then clones this repo to `~/.dotfiles` and continues. `chsh` asks for your password again when it changes the login shell.

2. Quit Terminal and open Ghostty. New windows now start fish with the starship prompt.

If the script stops, fix the error and run it again. Each step skips work that is already done.

## After the script

The script can't sign in to accounts or change System Settings. Do these steps by hand:

1. Sign in to GitHub. Git uses `gh` for credentials, so you don't need an SSH key.

	```sh
	gh auth login
	```

2. Set your git name and email. The repo leaves them out so they stay private. Git reads them from `~/.config/git/local`, which is not in the repo.

	```sh
	git config --file ~/.config/git/local user.name "Your Name"
	git config --file ~/.config/git/local user.email "you@example.com"
	```

3. Start `claude` and sign in. If the pstack plugin is missing, install it with `/plugin`.
4. Run `codex` and sign in.
5. Open Tailscale and sign in.
6. To SSH into the Mac over Tailscale, open **System Settings > General > Sharing** and turn on **Remote Login**.
7. To keep agents running while the display is off, open **System Settings > Energy** and turn on **Prevent automatic sleeping when the display is off**.
8. Open Alfred, Rectangle Pro, OrbStack, and ChatGPT. Enter licenses, sign in, and grant the permissions each app asks for.

## Change what gets installed

- To add an app or tool, add a `brew` or `cask` line to the [`Brewfile`](Brewfile). Then run `~/.dotfiles/install`.
- To add a config file, put it in `home/` at the same path it has under `~`. Then run `~/.dotfiles/install`. For example, `home/.config/ghostty/config` links to `~/.config/ghostty/config`.

The script links each file, not whole folders. Files that apps write next to their configs, such as `fish_variables` and `~/.claude` sessions, stay out of the repo.

If a real file already exists where a link should go, the script stops and names the file. Move or delete the file, then run the script again.

## Test the script

`test/install.sh` runs `install` in a temporary home folder. It replaces `brew`, `curl`, `sudo`, and `chsh` with stubs, so it changes nothing on your Mac. It checks a first run, a second run, and a conflicting file.

```sh
test/install.sh ~/.dotfiles
```

The test clones the repo path you give it, so commit your changes first.
