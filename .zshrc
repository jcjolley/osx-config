
config_root="$HOME/.config/zsh/"

zsh_source_files=(
	'zinit.zsh' 
	'gcloud.zsh' 
	'completions.zsh' 
	'aliases.zsh' 
	'functions.zsh' 
	'fzf.zsh'
)

for partial_file in $zsh_source_files; do
	file="$config_root/$partial_file"
	[ -f "$file" ] && source "$file"
done

