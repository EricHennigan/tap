
# add texlive to env
texdir="/usr/local/texlive/2013"
export PATH="$texdir/bin/i386-linux:$PATH"
export INFOPATH="$texdir/texmf-dist/doc/info:$INFOPATH"
export MANPATH="$texdir/texmf-dist/doc/man:$INFOPATH"

#================
# screen config functions
#----------------

function rave-checkout {
  svn checkout svn://ravesvn.ims.dom/Rave/projects/trunk $1/projects
}

function towork {
  optirun true
  sleep 1
  xrandr --output LVDS1 --mode 1920x1080 --output VIRTUAL --mode 1920x1080 --left-of LVDS1
  sleep 1
  start-stop-daemon --start --background --exec /usr/bin/screenclone -- -d :8 -x 1
}

function tohome {
  xrandr --output LVDS1 --mode 1920x1080 --output VIRTUAL --off
  sleep 1
  start-stop-daemon --stop --exec /usr/bin/screenclone -- -d :8 -x 1
  sleep 1
  optirun false
}

#================
# SVN setup
#----------------

if [[ -f "$HOME/.svnkit" ]]; then
    source $HOME/.svnkit
    export SVNUSER=ehennigan
    #export SVNME=svn://ravesvn/Rave/projects/branches/private/erich
fi

function rave-update-svnkit {
    svn export svn://ravesvn/Rave/tools/svnkit/install.sh /tmp/svnkit-install.sh
    cd /tmp
    ./svnkit-install.sh
}
