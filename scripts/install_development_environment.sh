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

SCRIPT=`basename $0`
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


# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  update_package_cache

  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
