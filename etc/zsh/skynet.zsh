
function set-qt5 {
  export QTDIR="$HOME/software/Qt5.0.1/5.0.1/gcc_64"
  export PATH="$QTDIR/bin:$QTDIR/Tools/QtCreator/bin:$PATH"
  export MANPATH="$QTDIR/man:$MANPATH"
  export LD_LIBRARY_PATH="$QTDIR/lib:$LD_LIBRARY_PATH"

  #enable new QtCreator
  export PATH="$HOME/software/Qt5.0.1/Tools/QtCreator/bin:$PATH"
}

#development: Android
export PATH="$HOME/software/adt-bundle-linux-x86_64-20130219/sdk/tools:$PATH"
export PATH="$HOME/software/eclipse:$PATH"
