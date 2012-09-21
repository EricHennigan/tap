# =========================
# Qt Development
function dev-qt {
    export QTDIR="$HOME/software/qt-git-build"
    export PATH="$QTDIR/bin:$PATH"
    export MANPATH="$QTDIR/man:$MANPATH"
    export LD_LIBRARY_PATH="$QTDIR/lib:$LD_LIBRARY_PATH"
    function update-qt {
        cd "$HOME/software/qt-git"
        git pull
        ./configure -prefix "$HOME/software/qt-git-build" -prefix-install
        make clean
        make -j5
        make install
    }
    export -f update-qt
}

function dev-qt-creator {
    dev-qt
    QTCREATOR="$HOME/software/qt-creator-git-build"
    export PATH="$QTCREATOR/bin:$PATH"
    function update-qt-creator {
        #update-qt
        cd "$HOME/software/qt-creator-git"
        git pull
        cd "$HOME/software/qt-creator-git-build"
        make clean
        qmake "$HOME/software/qt-creator-git/qtcreator.pro"
        make -j5
    }
    export -f update-qt-creator
}

# =========================
# Go language Development
function dev-golang {
    export GOROOT="$HOME/software/golang"
    export GOOS="linux"
    export GOARCH="amd64"
    export GOBIN="$HOME/software/golang/bin"
    export PATH="$GOBIN:$PATH"
}
