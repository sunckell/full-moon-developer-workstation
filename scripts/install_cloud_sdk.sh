#!/bin/bash
# ---
# ---  name:   install_cloud_sdk.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Install some typical tools to integrate wit the big 3 cloud providers
# ---  notes:
# ---
export DEBIAN_FRONTEND="noninteractive"
#SCRIPT=`basename $0`
SCRIPT="install_cloud_sdk.sh"
HOSTNAME=`uname -n`

# --- simple logger to give me an idea of what's happening when.
logger()
{
    mesg=$1
    echo "${HOSTNAME} - ${SCRIPT} - ${mesg}"
}

# --- every once in a while we'll need to update the package cache
# --- I know, I know, DRY....   Well I'll forgive myself if you will?
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
# --- installing the aws cli
install_aws_cli()
{
    logger "installing aws cli"
    sudo apt-get -qq install -y awscli
    if [ "$?" != 0 ]; then
       logger "ERROR: awscli install failed."
       logger "ERROR: please investigate.  exitting.."
       exit 2
    fi
}

# --- install the azure cli
install_azure_cli()
{
     logger "installing azure sdk- npm version"
     logger "install pre-reqs first."
     sudo apt-get -qq install -y npm
     if [ "$?" != 0 ]; then
        logger "ERROR: npm pre-reqs install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
     fi

     sudo npm install -g azure-cli
     if [ "$?" != 0 ]; then
        logger "ERROR: azure-cli npm install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
     fi
}

# --- google SDK - python
install_gce_cli()
{
     logger "installing google cloud engine sdk tools"
     wget --quiet https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-143.0.1-linux-x86_64.tar.gz -O gce.tar.gz
     if [ "$?" != 0 ]; then
        logger "ERROR: wget for gce sdk failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
     fi

     sudo tar xfz ./gce.tar.gz
     if [ "$?" != 0 ]; then
        logger "ERROR: extract of gce archive failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
     fi

     sudo ./google-cloud-sdk/install.sh --usage-reporting false --rc-path /home/vagrant/.bashrc --command-completion true --path-update true
     if [ "$?" != 0 ]; then
        logger "ERROR: gce sdk installation failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
     fi
}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  update_package_cache
  install_aws_cli
  install_azure_cli
  install_gce_cli

  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
