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
alias fu=fileutil
alias fug='fileutil --gfs_user=medlm-externalization-guitar-jobs'
alias gquig='gqui --gfs_user=medlm-externalization-guitar-jobs'

alias annealing='/google/bin/releases/rollouts/annealing/annealing'
alias bard='/google/bin/releases/gemini-cli/tools/gemini --gfg'
alias bard='//google/bin/releases/jetski-devs/tools/cli --agent=gpowers'
alias bisect="/google/data/ro/teams/tetralight/bin/bisect"
alias bluze='/google/bin/releases/blueprint-bluze/public/bluze'
alias bs2='/google/bin/releases/blobstore2/tools/bs2/bs2'
alias ctab_diff='./medical/records/quality/extraction/offline/diff/run_diff.sh'
alias everest='/google/bin/releases/eval/cli/everest'
alias evergreen='/google/bin/releases/deepmind/evergreen/cli/cli.pa'
alias ganpati-onpiper='/google/bin/releases/ganpati-onpiper/ganpati-onpiper'
alias gpaste="/google/src/head/depot/eng/tools/pastebin"
alias include-cleaner='/google/bin/releases/lpt-c-tools/include-cleaner/include_cleaner'
alias lamda_cli='/google/bin/releases/lamda-team/tools/lamda_cli'
alias onborg='/google/data/ro/projects/smartass/onborg'
alias perfgate='/google/bin/releases/perfgate/cli/perfgate'
alias rpcreplay='/google/data/ro/teams/frameworks-test-team/rpcreplay-cli/live/rpcreplay'
alias safergcp=/google/bin/releases/safer-gcp/tools/safergcp
alias snippets="/google/data/ro/projects/contentads/adx/verification/tools/weekly_snippets"
alias tfhub='/google/data/ro/teams/tf-hub/tfhub'
alias tm=/google/data/ro/teams/tenantmanager/tools/tm
alias tricorder='/google/data/ro/teams/tricorder/tricorder'
alias versionstore='/google/bin/releases/rollouts/versionstore/cli'

alias blt="blaze test --flaky_test_attempts=1"
alias blaze='blaze --host_jvm_args=-Xmx18G --host_jvm_args=-Xms18G'
alias irabbit='iblaze -iblaze_blaze_binary rabbit'
alias g3jshell='/google/src/head/depot/google3/experimental/users/diamondm/java/jshell/g3jshell.sh'

function gdb() { cd $(echo $(pwd) | sed "s,google3/,google3/blaze-bin/,"); }
function gdc() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/)?,google3/,"); }
function gdjt() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/|java/)?,google3/javatests/,"); }
function gdj() { cd $(echo $(pwd) | sed "s,google3/(blaze-bin/|javatests/)?,google3/java/,"); }

source /etc/bash_completion.d/hgd
alias hgcl="hg xl | grep '@.*thoth cl' | sed -e's/.*cl.([0-9]*).*/\1/'"
function hgd() { hg diff | ydiff -s }
function hgp() { hg pdiff | ydiff -s }
function hgcld() {
  local CL=$1
  if [ -z "$CL" ]; then
    CL=$(hgcl)
    if [ -z "$CL" ]; then
      echo "You must be in a fig workspace or provide a CL number."
      return 1
    fi
    CL=${CL#cl/} # remove leading "cl/" if present
  fi

  CRITIQUE_ROOT="/google/src/cloud/review/${CL}/google3"
  if [ ! -d "${CRITIQUE_ROOT}" ]; then
    echo "Critique workspace path: ${CRITIQUE_ROOT}"
    echo "Critique workspace not found for CL ${CL}."
    return 1
  fi

  pushd "$(hg root)/google3"
  # Read the multiline output into an array using zsh's (f) parameter expansion flag
  FILES=( ${(f)"$(hg pstatus | grep -v '^\?' | sed -e's/.* //')"} )

  for F in "${FILES[@]}"; do
    diff -u "${F}" "${CRITIQUE_ROOT}/${F}"
  done
  popd
}

alias jadep="/google/data/ro/teams/jade/jadep"
alias menu="/google/data/ro/projects/menu/menu.par LAX"
alias bisect="/google/data/ro/teams/tetralight/bin/bisect"

function myblaze() {
  iblaze $@ --test_output=streamed 2>&1 | grep -A5 '^([0-9]+\)|INFO|DEBUG|THOTH|Caused by)'
}

function build_mpm () {
  pushd /google/src/files/head/depot/google3
    rabbit --verifiable mpm --symlink_prefix=/tmp/output/blaze - -c opt "$@";
  popd
}

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

