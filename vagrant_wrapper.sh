#!/bin/bash
# ---
# ---  name:   vagrant_wrapper.sh
# ---  author: ckell <sunckell at that google mail site>
# ---  date:   Jan 6, 2017
# ---  descr:  Wrapper script around vagrant.  I do this so that I can create a consistent
# ---          and reproducible experience across desktops.
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

# ---
# --- we can't derive everything we need from within the script so we'll need some things passed to us.
# ---
parse_cmd_line()
{
    ACTION="UNDEFINED"
    HELP="false"

    while [ "$#" -ne 0 ];
    do
        case $1 in
            --action|-a)
                ACTION="$2"; shift; shift;
            ;;
            --help|-h)
                HELP="true"; shift; shift;
            ;;
            *)
                echo "ERROR: Unknown option passed on the command line."
                echo "ERROR: exitting without a conscience."
                exit 1
            ;;
        esac
    done

    # --- do they want help?
    if [ ${HELP} = "true" ]; then
        show_help
        exit 0
    fi

    # --- have to have an action
    if [ ${ACTION} = "UNDEFINED" ]; then
        logger "ERROR: --ACTION|-a flag not provided."
        logger "ERROR: exitting without a conscience."
        logger "Take a look at ${SCRIPT} -h for help"
        exit 1
    fi
}

# --- display help if they need it.
show_help()
{
    echo ""
    echo "${SCRIPT}(1)"
    echo "NAME"
    echo "  ${SCRIPT} - Vagrant wrapper for reproducible and consistent desktop environments"
    echo ""
    echo "SYNOPSYS"
    echo "  ${SCRIPT} [OPTION(S)]"
    echo ""
    echo "DESCRIPTION"
    echo "  In order to create a consistent environment across developers and desktops"
    echo "  we wrap the vagrant command around a shell script."
    echo ""
    echo "REQUIREMENTS"
    echo "  1. Hashicorp Vagrant must be installed and be your PATH."
    echo "          https://www.vagrantup.com/"
    echo "  2. A Desktop virtualization tool."
    echo "     supported products:"
    echo "       a. VirtualBox (https://www.virtualbox.org)"
    echo "       b. VmWare Workstation (http://store.vmware.com/store/vmware/en_US/DisplayProductDetailsPage/ThemeID.2485600/productID.323700100)"
    echo "       c. Qemu (http://wiki.qemu.org/Main_Page)"
    echo ""
    echo "NOTE:"
    echo "    * I develop on gnu linux (specifically Fedora).  While packer supports other builders I only test the ones listed."
    echo ""
    echo "OPTIONS:"
    echo "  Required arguments for long options are mandatory for short options."
    echo "  --help, -h"
    echo "      show the help screen"
    echo "  --action, -a"
    echo "      vagrant action to perform"
    echo ""
    echo "  Exit status:"
    echo "     0        if OK,"
    echo "     1        generic command line option error,"
    echo "     2        "
    echo "     3        "
    echo ""
    echo "AUTHOR"
    echo "    ckell <sunckell at that google mail site>"
    echo ""
    echo "REPORTING BUGS"
    echo "    https://github.com/sunckell/development-desktop/issues"
    echo ""
    echo "COPYRIGHT"
    echo "    Copyright © 2012 Free Software Foundation, Inc.  License GPLv3+: GNU GPL"
    echo "    version 3 or later <http://gnu.org/licenses/gpl.html>."
    echo "    This is free software: you are free to change and redistribute it."
    echo "    There is  NO WARRANTY, to the extent permitted by law."
    echo ""
    echo "The Developer Experience ${VERSION}     Oct 2016                        ${SCRIPT}(1)"
    echo ""

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
