#!/bin/bash
# ---
# ---  name:   install_extra_software.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Provisioning script.  Installs software needed to do what ever you need
# ----         to do
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

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  # --- make 2 ways to kick this off.  Menu driven or parm driven.
  if [ "$@" > 0 ]; then
      # --- parse the option passed
      parse_cmd_line "$@"
  else
      # --- run the Menu
      menu_experience
  fi

  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
