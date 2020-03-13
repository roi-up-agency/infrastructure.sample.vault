#!/usr/bin/env bash

command -v docker >/dev/null 2>&1 || { echo >&2 "I require docker cli but it's not installed.  Aborting."; exit 1; }

docker run -v $HOME/bin:/software sethvargo/hashicorp-installer vault 1.2.2
export PATH=$HOME/bin:$PATH

[[ -f  "${HOME}"/.bashrc ]] && echo "PATH=${HOME}/bin:$PATH" >> "${HOME}"/.bashrc
[[ -f  "${HOME}"/.zshrc ]]  && echo "PATH=${HOME}/bin:$PATH" >> "${HOME}"/.zshrc


sudo chown -R "$(whoami):$(whoami)" "${HOME}"/bin/
vault -h
