#!/bin/bash
# ---
# ---  name:   configure_desktop.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Provisioning script.  Installs and configures the dekstop
# ----
# ---  notes:
# ---
export DEBIAN_FRONTEND="noninteractive"
#SCRIPT=`basename $0`
SCRIPT="configure_desktop.sh"
HOSTNAME=`uname -n`

# --- simple logger to give me an idea of what's happening when.
logger()
{
    mesg=$1
    echo "${HOSTNAME} - ${SCRIPT} - ${mesg}"
}

# --- every once in a while we'll need to update the package cache
update_package_cache()
{
    logger "update apt-get cache"
    sudo apt-get update
    if [ "$?" != 0 ]; then
      logger "ERROR: apt-get update failed."
      logger 'ERROR: please investigate.  exitting...'
      exit 2
    fi
}

# --- install the desktop I like to use.  (let the desktop wars begin.)
install_desktop()
{
    logger "installing gnome-core"
    sudo apt-get -qq install -y gnome-core
    if [ "$?" != 0 ]; then
      logger "ERROR: gnome-core installation failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi
}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  update_package_cache
  install_desktop

  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
