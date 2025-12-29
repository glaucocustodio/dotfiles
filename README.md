# Prerequisites

Install the following programs before running this script:

- iTerm2
- stow (`brew install stow`)

# Install

First, clone this repository at `~/` (otherwise you might have issues with stow):

```bash
cd ~/
git clone git@github.com:glaucocustodio/dotfiles.git
```

Then run the setup script:

```bash
cd ~/dotfiles
chmod +x script/setup
script/setup
```

# Available make tasks

Once you change a dotfile at `config/`, the changes will automatically be reflected at the respective file in `~/` (because of the sym link).

If for some reason you wanna link the files again, run:

```bash
make force_update
```

To delete all dotfiles run:

```bash
make remove
```

# Other useful apps

## cross plataform

- [stow](https://www.gnu.org/software/stow/manual/stow.html): program used to control dotfiles
- https://github.com/asdf-vm/asdf: programming language version manager
- https://www.npmjs.com/package/ezff: plain english to ffmpeg command
- https://github.com/federico-terzi/espanso: text expander
- https://github.com/chmln/sd: like sed / awk, but friendlier
- https://github.com/eddieantonio/imgcat: display image on terminal
- https://github.com/sharkdp/bat: cat-like command, but better
- https://github.com/tldr-pages/tldr: man-like command, but better
- https://github.com/ggreer/the_silver_searcher: a fast command line code-searching tool (search in file content)
- https://github.com/hlissner/zsh-autopair: auto close quotes and more (`", ', (, [...`)
- https://github.com/junegunn/fzf: command-line fuzzy finder (search in file name)
- https://github.com/Aloxaf/fzf-tab: replace zsh's default completion selection menu with fzf

## macOS only

- https://rectangleapp.com/ works better [~~shortcuts for window management/tiling (introduced in macOS Sequoia 15)~~](https://support.apple.com/en-hk/guide/mac-help/mchl9674d0b0/mac)
- ~~https://github.com/moretension/duti: to set default apps via cli (brew install duti)~~ - does not seem to work
- https://github.com/dbcli/pgcli: pgcli better than psql (brew install pgcli)
- ~~https://github.com/Lord-Kamina/SwiftDefaultApps: to set default app~~
- https://github.com/ArtemGordinsky/Spotifree: spotify ad muter
- https://apps.apple.com/us/app/brightness-slider/id456624497?mt=12: external monitor brightness control
- ~~https://apps.apple.com/us/app/record-it-screen-recorder/id1339001002?mt=12: screen recorder~~ (can use QuickTime instead)
- https://maccy.app/: clipboard manager (free to install via brew)
- https://postgresapp.com/: Postgres version managament tool
- https://dbngin.com/: all-in-one database version management tool (allow many versions of Postgres, Redis, MySQL etc)
- https://www.mowglii.com/itsycal/: better calendar
- https://apps.apple.com/us/app/ethernet-status/id1186187538: ethernet cable status indicator

## Useful

- https://github.com/ibraheemdev/modern-unix
- https://www.manualdocodigo.com.br/vim-basico/: set up of Vim/NeoVim
- https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
- https://youtu.be/y6XCebnB9gs: using stow
- https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/

~~You might also want to add Sublime Merge to $PATH: `ln -s "/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge" /usr/local/bin/merge`~~

On recent versions of macOS you might need to enable notifications on Slack:

- open "System Settings"
- look for "Notifications"
- click on "Slack" then toggle on "Allow notifications"

# Acknowledgment

- https://github.com/tegon/dotfiles
- https://github.com/mathiasbynens/dotfiles
- https://github.com/ulwlu/dotfiles
