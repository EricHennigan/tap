#!/usr/bin/env bash

# This script installs the dotfiles
cd $HOME

ln -sf tap/etc/zsh/zshrc .zshrc
ln -sf tap/etc/vim .vim
ln -sf tap/etc/vim/vimrc .vimrc
ln -sf tap/etc/gitconfig .gitconfig
ln -sf tap/etc/tmux.conf .tmux.conf

ln -sf tap/etc/ssh/config .ssh/config

mkdir -p $HOME/.config
for file in $HOME/tap/config ; do
    ln -sf $file $HOME/.config/
done

# setup zsh for this computer
cd $HOME/tap/etc/zsh
touch $(hostname).zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git
