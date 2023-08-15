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

alias hgcl="hg xl | grep '@.*thoth cl' | sed -e's/.*cl.([0-9]*).*/\1/'"
alias hgd="hg diff | ydiff -s -w111"
alias hgp="hg pdiff | ydiff -s -w111"

alias blt="blaze test --flaky_test_attempts=1"
alias blaze='blaze --host_jvm_args=-Xmx18G --host_jvm_args=-Xms18G'
alias irabbit='iblaze -iblaze_blaze_binary rabbit'
alias jadep="/google/data/ro/teams/jade/jadep"
alias rpcreplay='/google/data/ro/teams/frameworks-test-team/rpcreplay-cli/live/rpcreplay'
alias versionstore='/google/bin/releases/rollouts/versionstore/cli'
alias tricorder='/google/data/ro/teams/tricorder/tricorder'

function myblaze() {
  iblaze $@ --test_output=streamed 2>&1 | grep -A5 '^([0-9]+\)|INFO|DEBUG|THOTH|Caused by)'
}

function build_mpm () {
  pushd /google/src/files/head/depot/google3
    rabbit --verifiable mpm --symlink_prefix=/tmp/output/blaze - -c opt "$@";
  popd
}

if ! gcertstatus -quiet; then
  echo "Gcert required for loading sandbox_rc. Running gcert..."
  gcert
fi
source /google/data/ro/teams/health-research/tools/sandbox_rc

function startup_flags() {
  if [[ -z "${BOQ_NODE_PATH}" ]]; then
    echo "define BOQ_NODE_PATH=java/com/google/medical/records/guardian/server"
    return -1
  fi
  blaze build "${BOQ_NODE_PATH}:startup_flag_files" && (
  for f in blaze-genfiles/${BOQ_NODE_PATH}/[a-z]*.flags; do
    echo "\n### ${f}"
    python3 -m json.tool "${f}"
  done)
}

function server_flags() {
  if [[ -z "${BOQ_NODE_PATH}" ]]; then
    echo "define BOQ_NODE_PATH=java/com/google/medical/records/guardian/server"
    return -1
  fi
  blaze build "//${BOQ_NODE_PATH}:piccolo_binaryproto"
  gqui from rawproto:blaze-bin/${BOQ_NODE_PATH}/piccolo_binaryproto.txt \
    proto startpcl.AllObjects print object.job.name, object.job.argv \
    > /tmp/out.proto
  grep '  (name|argv)' /tmp/out.proto \
    | sed -e's/^ *name.*"(.*).patient.*/### \1/' \
    | sed -e's/--/\n--/g'
}

function protoconf() {
  if [[ -z "${BOQ_NODE_PATH}" ]]; then
    echo "define BOQ_NODE_PATH=java/com/google/medical/records/guardian/server"
    return -1
  fi
  blaze build "//${BOQ_NODE_PATH}:protoconf"
  mkdir -p /tmp/code/protos
  echo > /tmp/code/protos/cmds
  for bproto in $(ls blaze-genfiles/${BOQ_NODE_PATH}/*_protoconf.binaryproto) ; do
    name=$(basename $bproto .binaryproto)
    cmd="from $bproto proto social.boq.proto.protoconf.ProtoConf --outfile=/tmp/code/protos/$name.txt"
    echo $cmd >> /tmp/code/protos/cmds
  done
  cat /tmp/code/protos/cmds | xargs -L1 -P30 gqui
}

