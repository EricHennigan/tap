#!/usr/bin/env bash

# This script installs the dotfiles
cd $HOME

ln -sf tap/etc/zsh/zshrc .zshrc
ln -sf tap/etc/vim .vim
ln -sf tap/etc/vim/vimrc .vimrc
