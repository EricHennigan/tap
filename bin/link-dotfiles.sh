#!/usr/bin/env bash

# This script installs the dotfiles
cd $HOME
ln -sf ~/tap/etc/gitconfig .gitconfig
ln -sf ~/tap/etc/hgrc .hgrc
ln -sf ~/tap/etc/tmux/tmux.conf .tmux.conf
ln -sf ~/tap/etc/tmux .tmux
ln -sf ~/tap/etc/vim .vim
ln -sf ~/tap/etc/vim/vimrc .vimrc
ln -sf ~/tap/etc/zsh/zshrc .zshrc

ln -sf ~/tap/etc/ssh/config .ssh/config

mkdir -p $HOME/.config
for file in $HOME/tap/etc/config/* ; do
  ln -sf $file $HOME/.config/$(basename $file)
done

# setup zsh for this computer
cd $HOME/tap
git submodule update --init --recursive

# vim backups/swp/undo
mkdir -p $HOME/tmp/vim

# setup crypt/phonebook
mkdir -p $HOME/tap/mnt/crypt
read -r -p "Install crypt [y/N] " input
case "$input" in
[yY][eE][sS]|[yY])
  git submodule add https://github.com/EricHennigan/crypt.git etc/crypt
  ;;
*)
  mkdir -p etc/crypt
  ;;
esac
