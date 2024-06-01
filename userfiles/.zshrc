eval "$(zellij setup --generate-auto-start zsh)"

function conda() {
	conda-shell -c "conda activate "$1" && python "$2""
}

function conda_update() {
	conda-shell -c "conda activate general && conda update --all -y"
	conda-shell -c "conda activate solver && conda update --all -y"
	conda-shell -c "conda activate space && conda update --all -y"
    conda-shell -c "conda activate yafs && conda update --all -y"
}

function update_rebuild() {
	cd ~/zsh-autocomplete && git pull && cd - && cd ~/powerlevel10k && git pull && cd -
	sudo nixos-rebuild switch --upgrade-all
}

if [[ -d  ~/powerlevel10k/ ]]; then
	source ~/powerlevel10k/powerlevel10k.zsh-theme
	source ~/.p10k.zsh
fi

if [[ -d  ~/zsh-autocomplete/ ]]; then
    source ~/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

alias update="sudo nix-channel --update"
alias rebuild="sudo nixos-rebuild switch"

eval "$(atuin init zsh)"
