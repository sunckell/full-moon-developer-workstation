#!/bin/bash
# ---
# ---  name:   install_extra_software.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Provisioning script.  Installs and configures the extra software
# ----
# ---  notes:
# ---
export DEBIAN_FRONTEND="noninteractive"
#SCRIPT=`basename $0`
SCRIPT="install_extra_software.sh"
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
    sudo apt-get -qq update
    if [ "$?" != 0 ]; then
      logger "ERROR: apt-get update failed."
      logger 'ERROR: please investigate.  exitting...'
      exit 2
    fi
}

# --- install the atom.io
install_atom_io()
{
    logger "installing atom.io"
    wget --quiet https://atom.io/download/deb -O atom.deb
    if [ "$?" != 0 ]; then
      logger "ERROR: wget of atom.io failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi

    logger "installing pre-req for atom.io"
    sudo apt-get -qq install git xdg-utils libxss1
    if [ "$?" != 0 ]; then
      logger "ERROR: atom.io pre-reqs installation failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi


    sudo dpkg -i atom.deb
    if [ "$?" != 0 ]; then
      logger "ERROR: atom.deb installation failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi

    # --- install the atom plugins we use the most.
    logger "install file-icons plugins"
    sudo -H -u vagrant apm install file-icons
    sudo -H -u vagrant apm install language-hcl
    sudo -H -u vagrant apm install language-terraform
    sudo -H -u vagrant apm install markdown-writer

}

# --- install docker...
# --- taken from: https://docs.docker.com/engine/installation/linux/debian/
install_docker()
{
    logger "installing docker"

    logger "install docker pre-reqs"
    sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common
    if [ "$?" != 0 ]; then
      logger "ERROR: docker pre-reqs installation failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi

    logger "add docker official GPG key"
    curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
    if [ "$?" != 0 ]; then
      logger "ERROR: docker gpg installation failed."
      logger "ERROR: please investigate.  exitting.."
      exit 2
    fi

    logger "add docker official repository"
    sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main"
    if [ "$?" != 0 ]; then
       logger "ERROR: docker repo installation failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

    update_package_cache

    logger "installing Docker"
    sudo apt-get -qq -y install docker-engine
    if [ "$?" != 0 ]; then
       logger "ERROR: docker installation failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  install_atom_io
  install_docker
  update_package_cache


  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
