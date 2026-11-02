# Restored from the NixOS shell configuration; native Artix paths.
export PATH="$HOME/.local/bin:$HOME/.local/scripts:$HOME/.cargo/bin:$HOME/go/bin:$HOME/develop/flutter/bin:$HOME/Android/Sdk/emulator:$HOME/Android/Sdk/platform-tools:$HOME/Android/Sdk/tools:$HOME/Android/Sdk/cmdline-tools/latest/bin:$HOME/.pyenv/bin:$HOME/.bun/bin:$HOME/.mimocode/bin:$HOME/Applications:$PATH"
export TERMINAL=ghostty
export EDITOR=nvim
export EZA_CONFIG_DIR="$HOME/.config/eza"
export ANDROID_HOME="$HOME/Android/Sdk"
export REACT_TERMINAL=ghostty
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export SDKMAN_DIR="$HOME/.sdkman"
export BUN_INSTALL="$HOME/.bun"
export ZSH="$HOME/.local/share/oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/oh-my-zsh-custom"
ZSH_THEME=daivasmara
plugins=(git)
zstyle ':omz:update' mode reminder
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY APPEND_HISTORY
source "$ZSH/oh-my-zsh.sh"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
unset EZA_COLORS LS_COLORS
alias ll='eza --long --all --icons --git --classify --color-scale all'
alias ls=eza
alias v=nvim
alias c=clear
alias icat='kitten icat'
alias open=xdg-open
alias du=dust
alias ps=procs
alias top=btm
alias grep=rg
alias man="BAT_THEME='gruvbox-dark' batman"
alias r='sudo reboot now'
alias sn='sudo shutdown now'
alias sct='cd /home/thiago/Projects/work/sct/'
alias pf='cd /home/thiago/Projects/personal/'
if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)"
fi
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
function watch() {
  while true; do
    clear
    date
    "$@"
    sleep 2
  done
}
bindkey '^Y' autosuggest-accept
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
[[ -x "$PYENV_ROOT/bin/pyenv" ]] && eval "$(pyenv init -)"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
[[ -s "$HOME/.jetbrains.vmoptions.sh" ]] && source "$HOME/.jetbrains.vmoptions.sh"
[[ -s "$HOME/.config/envman/load.sh" ]] && source "$HOME/.config/envman/load.sh"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -t 1 ]] && fastfetch
