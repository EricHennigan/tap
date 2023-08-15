source /etc/bash_completion.d/g4d
#source /etc/bash_completion.d/flag_completion.sh
set show-all-if-ambiguous on

# appengine
# source $HOME/software/google-cloud-sdk/completion.zsh.inc
# source $HOME/software/google-cloud-sdk/path.zsh.inc

export PATH="/usr/lib/google-dartlang/bin:${PATH}"
#export PATH="$HOME/software/go_appengine:${PATH}"
export GOPATH="$HOME/tap/etc/gopath"
export PATH="${GOPATH}/bin:${PATH}"

alias gd=g4d
alias g=g4
alias irabbit='iblaze -iblaze_blaze_binary rabbit'
alias snippets="/google/data/ro/projects/contentads/adx/verification/tools/weekly_snippets"
alias gpaste="/google/src/head/depot/eng/tools/pastebin"

function gdb() { cd $(echo $(pwd) | sed "s,google3/,google3/blaze-bin/,"); }
function gdc() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/)?,google3/,"); }
function gdjt() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/|java/)?,google3/javatests/,"); }
function gdj() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/|javatests/)?,google3/java/,"); }

function hgp() { hg pdiff | ydiff -s }

alias blt="blaze test --flaky_test_attempts=1"
alias jadep="/google/data/ro/teams/jade/jadep"

function myblaze() {
  iblaze $@ --test_output=streamed 2>&1 | grep -A5 '^([0-9]+\)|INFO|DEBUG|THOTH|Caused by)'
}

function build_mpm () {
  pushd /google/src/files/head/depot/google3
    rabbit --verifiable mpm --symlink_prefix=/tmp/output/blaze - -c opt "$@";
  popd
}
