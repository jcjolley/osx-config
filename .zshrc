source "$HOME/.config/zsh/zinit.zsh"
source "$HOME/.config/zsh/gcloud.zsh"
source "$HOME/.config/zsh/completions.zsh"
source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/functions.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(atuin init zsh)"
