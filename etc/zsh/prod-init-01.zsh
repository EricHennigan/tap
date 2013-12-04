
export PATH="/opt/rave/lib:/opt/rave/client:$PATH"

if [[ -f "$HOME/.svnkit" ]]; then
    source $HOME/.svnkit
fi

function rave-update-svnkit {
    svn export svn://ravesvn/Rave/tools/svnkit/install.sh /tmp/svnkit-install.sh
    cd /tmp
    ./svnkit-install.sh
}

alias rave-power="/opt/rave/client/PwrControl"
alias rave-network="/opt/rave/lib/networkConfig.py"

function rave-checkout {
  svn checkout svn://ravesvn.ims.dom/Rave/projects/trunk $1/projects
}

function rave-ssh {
  ssh root@172.168.0.10
}

function rave-start-servers {
  sudo ls >/dev/null || return
  /opt/rave/kraken_server/app_kraken_server.py -v sdu_audio_fixture -l /home/erich/krakenLogs/sdu_audio_fixture.log&
  /opt/rave/kraken_server/app_kraken_server.py -v phidget -l /home/erich/krakenLogs/phidget.log&
}

function rave-start-client {
  sudo touch kraken_debug.log
  sudo chmod a+w kraken_debug.log
  ./app_kraken_client.py -g qt sdu $2 --title "TESTING" --timeout 120 --lru $1 -v -l /home/erich/krakenLogs/client_sdu.log --power phidget
}
