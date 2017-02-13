#!/bin/bash
# ---
# ---  name:   install_development_environment.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Provisioning script.  Installs and configures a development environment
# ---          specific to the needs of the project
# ----
# ---  notes:
# ---
export DEBIAN_FRONTEND="noninteractive"
#SCRIPT=`basename $0`
SCRIPT="install_development_environment.sh"
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

# --- install openjdk8
install_openjdk8()
{
    logger "installing openjdk8"
    logger "add backports repository"
    sudo add-apt-repository \
       "deb http://httpredir.debian.org/debian \
       $(lsb_release -cs)-backports \
       main"
    if [ "$?" != 0 ]; then
       logger "ERROR: debian backports addition failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

    update_package_cache

    logger "installing openjdk-8"
    sudo apt-get -qq install -y openjdk-8
    if [ "$?" != 0 ]; then
       logger "ERROR: openjdk8 install failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi
}

# --- install jetbrains idea
install_idea_ultimate()
{
    logger "installing jetbrains idea ultimate"
    sudo -H -u vagrant wget --quiet https://download-cf.jetbrains.com/idea/ideaIU-2016.3.4.tar.gz -O idea.tar.gz
    if [ "$?" != 0 ]; then
       logger "ERROR: wget intellij failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

    sudo -H -u vagrant mkdir -p ~vagrant/opt
    if [ "$?" != 0 ]; then
       logger "ERROR: mkdir ~vagrant/opt failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

    sudo -H -u vagrant tar xvfz idea.tar.gz
    if [ "$?" != 0 ]; then
       logger "ERROR: un-packaging idea.tar.gz install failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi

    sudo -H -u vagrant mv

}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  update_package_cache
  install_openjdk8
  install_idea_ultimate

  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
