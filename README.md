# Prerequisites

Install the following programs before running this script:

- iTerm2

# Install

First, clone this repository:

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

# Other useful apps

## cross plataform

- https://github.com/asdf-vm/asdf: programming language version manager
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

- https://github.com/moretension/duti: to set default apps via cli (brew install duti)
- https://github.com/dbcli/pgcli: pgcli better than psql (brew install pgcli)
- https://github.com/Lord-Kamina/SwiftDefaultApps: to set default app
- https://github.com/ArtemGordinsky/Spotifree: spotify ad muter
- https://apps.apple.com/us/app/brightness-slider/id456624497?mt=12: external monitor brightness control
- https://apps.apple.com/us/app/record-it-screen-recorder/id1339001002?mt=12: screen recorder
- https://maccy.app/: clipboard manager

## Useful

- https://github.com/ibraheemdev/modern-unix

You might also want to add Sublime Merge to $PATH: `ln -s "/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge" /usr/local/bin/merge`

# Acknowledgment

- https://github.com/tegon/dotfiles
- https://github.com/mathiasbynens/dotfiles
- https://github.com/ulwlu/dotfiles
