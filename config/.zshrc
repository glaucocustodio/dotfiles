clear

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

ZSH_THEME="miloshadzic"

# add time to right side of terminal - can be replace by iTerm cmd+shift+e
# export RPROMPT="[%*]"

plugins=(
  git
  # fzf-tab
  zsh-autosuggestions
  colored-man-pages
)

# This will check for updates every x days
zstyle ':omz:update' frequency 60

source $ZSH/oh-my-zsh.sh

# load aliases
[[ -f ~/.aliases ]] && source ~/.aliases

[[ -f ~/.functions ]] && source ~/.functions

[[ -f ~/.private ]] && source ~/.private

# Set default locale for VIM
export LC_ALL=en_US.UTF-8

# https://build.betterup.com/one-weird-trick-that-will-speed-up-your-bundle-install/
#export MAKE="make -j$(nproc)"
export BUNDLE_JOBS=$(nproc)

export DISABLE_SPRING=true

export EDITOR=vim
export BUNDLER_EDITOR=cursor
export RAILS_EDITOR=$BUNDLER_EDITOR # rails 8.1+ (https://github.com/rails/rails/pull/55295)
# prevent update whenever you run a brew command
export HOMEBREW_NO_AUTO_UPDATE=1

# enable a command history feature for the iex console
# https://elixirforum.com/t/is-it-possible-to-enable-a-command-history-feature-for-the-iex-console/27409
export ERL_AFLAGS="-kernel shell_history enabled"

# from zsh-autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"

# With the debug gem v1.9.0, which is part of Ruby 3.3,
# you can configure it to use IRB as its console (by setting RUBY_DEBUG_IRB_CONSOLE=1)
# instead of rdbg (the default).
#
# This is only necessary if using the debug gem (via: `debugger` or `binding.break`) to debug Ruby code.
# As of Ruby 2.5 `binding.irb` is available, which is a simpler way to start a REPL from a breakpoint.
#
# export RUBY_DEBUG_IRB_CONSOLE=1

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# enable file preview when searching files with fzf, need bat installed to have colored output
# set following binds while fzf is open:
#
# - ctrl+e: open selected file with vscode
# - ctrl+y: copy selected file path
# - image preview requires https://github.com/eddieantonio/imgcat and fzf 0.44 (brew install imgcat)
#
# inspiration: https://stackoverflow.com/questions/64753153/cant-preview-directory-using-fzf,
# https://github.com/junegunn/fzf/discussions/3609
#
export FZF_DEFAULT_OPTS='
  --bind "ctrl-y:execute-silent(echo {+} | pbcopy)"
  --bind "ctrl-e:execute(echo {+} | xargs -o $BUNDLER_EDITOR)"
   --preview "
  if file --mime-type {} | grep -qF image/; then
    imgcat --depth iterm2 --width $FZF_PREVIEW_COLUMNS --height $FZF_PREVIEW_LINES {}
  else
    bat --theme=TwoDark --style=numbers --color=always --line-range :500 {}
  fi
  "
'

# disable preview when searching history (CTRL+R)
export FZF_CTRL_R_OPTS='--preview-window=:hidden'

# trigger fzf when pressing arrow up (TOO SLOW FOR ME, DISABLED FOR NOW)
# bindkey "${key[Up]}" fzf-history-widget

# load zsh-autopair
source ~/.zsh-autopair/autopair.zsh
autopair-init

# NeoVim v0.7 binary must be present on this folder
# NeoVim installed from brew is v0.5 (outdated), Telescope plugin requires NeoVim min v0.7
# follow instructions from https://github.com/neovim/neovim/releases/tag/v0.7.2
# then add to the $PATH
export PATH="$HOME/nvim-macos/bin:$PATH"
export NEOVIM_CONFIG_FILE="~/.config/nvim/init.vim"
alias cfv="e $NEOVIM_CONFIG_FILE"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# rust install with rustup, not asdf
source "$HOME/.cargo/env"

export PATH="/Users/glauco/.local/bin/:$PATH"

# Spark requires Java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

export PATH="/Applications/Postgres.app/Contents/Versions/16/bin:$PATH"

# Dracula theme for eza (maintained fork of exa, improved ls) (https://draculatheme.com/eza#installation)
#
# ==> I have changed `da` from `2;34` to `1;34` to make it more readable on dark mode (default is `2;34`)
export EZA_COLORS="\
uu=36:\
uR=31:\
un=35:\
gu=37:\
da=1;34:\
ur=34:\
uw=95:\
ux=36:\
ue=36:\
gr=34:\
gw=35:\
gx=36:\
tr=34:\
tw=35:\
tx=36:\
xx=95:"

# display weather (short version)
# cli_short

# request slow down load time
# fetch_usd_brl_quote

BOLD='\033[1m'
NONE='\033[00m'
GREEN='\033[01;32m'

echo "
  ${GREEN}ALIASES${NONE}

  ${BOLD}e:${NONE} editor
  ${BOLD}b:${NONE} bundle install -j$(nproc)
  ${BOLD}f:${NONE} search files with fzf interactively (use ctrl+e to open selected file with vscode)
  ${BOLD}fd:${NONE} find but faster and with better defaults (ignore files on .gitignore)
  ${BOLD}rg:${NONE} search file content (ignore files on .gitignore)
  ${BOLD}cal:${NONE} calendar
  ${BOLD}cli:${NONE} weather
  ${BOLD}time zsh -i -c exit:${NONE} measure zsh startup time
  ${BOLD}flushdns:${NONE} flush dns
  ${BOLD}imgcat:${NONE} display image (ex: ${BOLD}imgcat foo.jpg${NONE})
  ${BOLD}using_port:${NONE} show processes using the given port. Ex: ${BOLD}using_port tcp:3000${NONE}
  ${BOLD}kill_all_in_port:${NONE} kill all processes using the given port. Ex: ${BOLD}kill_all_in_port tcp:3000${NONE}
  ${BOLD}killruby:${NONE} kill all ruby processes but solargraph
  ${BOLD}flushall-redis:${NONE} flush all redis storage
  ${BOLD}myip:${NONE} show ip address
  ${BOLD}pc:${NONE} pgcli
  ${BOLD}gf:${NONE} open guru focus (ex: ${BOLD}gf meli${NONE})
  ${BOLD}yf:${NONE} open yahoo finance (ex: ${BOLD}yf baba${NONE})
  ${BOLD}br:${NONE} open bull run (ex: ${BOLD}br itub3${NONE})
  ${BOLD}reload:${NONE} reload shell configuration
  ${BOLD}git diff > changes.patch:${NONE} export changes to a patch file (that can be imported with ${BOLD}git apply changes.patch${NONE})
  ${BOLD}git bisect:${NONE} powerful command used to find the specific commit that introduced a bug or regression in your codebase
  ${BOLD}mkfile:${NONE} create a file and its parent directories if needed (ex: ${BOLD}mkfile foo/der/bar.txt${NONE})
  ${BOLD}extract:${NONE} extract any file (rar, zip, gz etc) (ex: ${BOLD}extract file.zip${NONE})
  ${BOLD}pbpaste:${NONE} paste from clipboard
  ${BOLD}command + shift + .:${NONE} open iterm2 AI assistant, then you can ask for help, eg: list files
  ${BOLD}command + y:${NONE} invokes AI assistant to translate type text to bash command
  ${BOLD}shift + enter:${NONE} execute command suggested by the AI assistant
"

draw_flashcard
