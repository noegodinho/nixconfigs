eval "$(zellij setup --generate-auto-start zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/pleiades/.conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/pleiades/.conda/etc/profile.d/conda.sh" ]; then
        . "/home/pleiades/.conda/etc/profile.d/conda.sh"
    else
        export PATH="/home/pleiades/.conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

function conda_update_all() {
	conda activate general && conda update --all -y
	conda activate solver && conda update --all -y
	conda activate space && conda update --all -y
    conda activate yafs && conda update --all -y
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
conda activate general