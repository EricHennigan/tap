alias df="df -h"
alias ssh="ssh -Y -C"
alias web="konqueror"
alias screen="byobu"
alias mux="tmux"

alias mydate="date +%g%m%d"
alias mytime="date +%H%M%S"

alias ls="ls --color=auto -h"
alias ll="ls -l"
alias la="ll -a"
alias lat="la -t"
alias lar="lat -r"
alias lart="lar"
alias latr="lar"
las() { ls -al "$@" | less; }

alias tart="tar tvf"
alias cp="cp -i"
alias cat="cat -v"
alias sed="sed -r"
alias grep="egrep --color=auto"
alias top="htop"
alias diff2="diff -y --suppress-common-lines"
alias emacs="emacs -nw"
alias edit="emacs -nw"
alias cdiff=ydiff

#miss pellings
alias tali="tail"
alias ecoh="echo"
alias more="less"
alias moer="less"
alias mroe="less"
alias mkae="make"
alias gerp="grep"
alias girp="grip"
alias berp="brep"
alias brip="brep -i"
alias birp="brip"
alias grip="grep -i"
function drip () { grep -Rin "$@" *; }

alias pd="pushd"
alias pop="popd"
alias pp="pop"
#alias pwd="dirs"

alias colortest="msgtest --color=test"
alias lh="history | sort -nr | less"
alias h="history | grep -i"
alias hx="hexdump -C"
alias hxm="hexdump -C $@ | less"
alias s="source $HOME/.bash_login"
alias xterm="xterm -ls"
alias nto0="tr '\n' '\000'"
alias hgp="hg pdiff | ydiff -s"

display() { sudo chvt 2; sleep 3; xrandr -d :0 --auto }
dict() { grep -i "$@" /usr/share/dict/*; }
trash(){ mv "$@" $HOME/tap/trash/; }
encrypt() { openssl enc -e -aes256 -in "$@"; }
decrypt() { openssl enc -d -aes256 -in "$@"; }
genkey() { ssh-keygen -t rsa; }
givekey() { cat ~/.ssh/id_rsa.pub | ssh "$@" "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"; }
cdart() { cd `ls -tF | grep '/$' | head -n 1`; }

# ssh quick-links
alias sshome="ssh cogitolingua.net"
alias sshxen="ssh xen.ics.uci.edu"
alias sshxenu="ssh boss.ics.uci.edu"
alias sshlab="ssh ehenniga@openlab.ics.uci.edu"
alias kwireless="sudo iwconfig wlan0 essid \"K wireless\""

#teaching
cd390() { cd /mnt/array/media/Education/UCI/2012--2013-Q1/University*; }
cd142() { cd /mnt/array/media/Education/UCI/teaching/2012--2013-Q1/Comp*; }
cdj() { cd /mnt/array/projects/jsflow; if [[ "$JSFLOW" == "" ]]; then source ./env; fi; }
cdw() { cd /mnt/array/projects/jsflow-webkit; if [[ "$JSFLOW" == "" ]]; then source ./env; fi; }

#trading
tws() { cd $HOME/software/tws/IBJts/; ./run.sh; }

#Phonebook
export PHONE="$HOME/tap/mnt/crypt/phonebook"
#phone() { smount crypt; grep -i "$@" $PHONE; smount -u crypt; }
viphone() { smount crypt && vi $PHONE && smount -u crypt; }


#Notes file
export NOTESFILE="$HOME/tap/etc/notes"
alias vinote="vi $NOTESFILE"
# the note executable is a python script: ~/tap/bin/note

#Hg projects
export PATH="$HOME/software/hgview/bin:$PATH"
#export PYTHONPATH="$HOME/software/hgview:$PYTHONPATH"

# x86_64 Development
export PATH="$HOME/software/udis86-1.7/udcli:$PATH"
alias dis='udcli -64'

#general environment vars
export PATH="$HOME/tap/bin:$PATH:/usr/sbin"
export MANPATH="$HOME/tap/man:$MANPATH"
export OOO_FORCE_DESKTOP="gnome"
#export PYTHONPATH="$HOME/tap/lib/python:$HOME/tap/lib/python/NITFplugins:$PYTHONPATH"
#export DFFPATH="$HOME/software/extract75" # location of *.dff and *.pff files for extract75

# LaTeX
export TEXMFHOME=$HOME/tap/etc/texmf

# Powerline
export PATH="$HOME/.local/bin:$PATH"

# Golang
export GOPATH="$HOME/.go"
