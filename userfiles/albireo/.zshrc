eval "$(zellij setup --generate-auto-start zsh)"

function update_rebuild() {
	cd ~/zsh-autocomplete && git pull && cd - && cd ~/powerlevel10k && git pull && cd - && cd ~/zsh-nix-shell && git pull && cd -
	sudo nixos-rebuild switch --upgrade-all
}

if [[ -d  ~/powerlevel10k/ ]]; then
	source ~/powerlevel10k/powerlevel10k.zsh-theme
	source ~/.p10k.zsh
fi

if [[ -d  ~/zsh-autocomplete/ ]]; then
    source ~/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

if [[ -d  ~/zsh-nix-shell/ ]]; then
    source ~/zsh-nix-shell/nix-shell.plugin.zsh
fi

alias update="sudo nix-channel --update"
alias rebuild="sudo nixos-rebuild switch"

eval "$(atuin init zsh)"