
# add texlive to env
texdir="/usr/local/texlive/2013"
export PATH="$texdir/bin/i386-linux:$PATH"
export INFOPATH="$texdir/texmf-dist/doc/info:$INFOPATH"
export MANPATH="$texdir/texmf-dist/doc/man:$INFOPATH"

#================
# screen config functions
#----------------

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

function rave-checkout {
  svn checkout svn://ravesvn.ims.dom/Rave/projects/trunk $1/projects
}

function rave-update-svnkit {
    svn export svn://ravesvn/Rave/tools/svnkit/install.sh /tmp/svnkit-install.sh
    cd /tmp
    ./svnkit-install.sh
}

function rave-patch {
    local ravedir=$HOME/work/$(pwd | sed -e's/.*rave/rave/' -e's/\/.*//')
    echo "ravedir = $ravedir"
    if [[ ! -d "$ravedir" ]]; then
        echo "Could not find a rave directory by the name $ravedir";
        return
    fi

    pushd "$ravedir"
        # verify that remote diff exists
        local remotediff=$(ls -t $HOME/tap/mnt/imsmfg/.$ravedir/*.diff | head -n1)
        if [[ -z "$remotediff" ]] ; then
            echo "Could not find remote diff"
            popd
            return
        fi

        # copy over the remote diff should one not yet exist (first time work setup)
        echo "remotediff = $remotediff"
        if [[ -z $(ls *.diff) ]]; then
            cp $remotediff ./
        fi

        # verify that a local diff exists
        local diff=$(ls -t *.diff | head -n1)
        echo "diff = $diff"
        if [[ -z "$diff" ]]; then
            echo "Could not find a diff file to apply";
            popd
            return
        fi

        pushd projects
            grep Index "../$diff" | field -1 -d' ' | xargs rm
            svn up
            \cp "$remotediff" ../
            patch -p0 < "../$diff"
            svn stat | grep -v '^?'
        popd
    popd > /dev/null
}
