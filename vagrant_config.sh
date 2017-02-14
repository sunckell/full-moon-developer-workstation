#!/bin/bash
# ---
# ---  name:   vagrant_config.sh
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

# --- we can't derive everything we need from within the script
# --- so we'll need some things passed to us.
parse_cmd_line()
{
    USE_PROXY="false"
    HELP="false"

    while [ "$#" -ne 0 ];
    do
        case $1 in
            --proxy|-p)
                USE_PROXY="$2"; shift; shift;
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
        logger "ERROR: --proxy|-p flag not provided."
        logger "ERROR: exitting without a conscience."
        logger "Take a look at ${SCRIPT} -h for help"
        exit 1
    fi
}

# --- quick and portable way to urlencode a string
# --- https://newfivefour.com/unix-urlencode-urldecode-command-line-bash.html
urlencode()
{
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

# --- quick and portable way to urlecoded a string
# --- https://newfivefour.com/unix-urlencode-urldecode-command-line-bash.html
urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

getpassword() {
    stty -echo
    CHARCOUNT=0
    while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
    do
        # Enter - accept password
        if [[ $CHAR == $'\0' ]] ; then
            break
        fi
        # Backspace
        if [[ $CHAR == $'\177' ]] ; then
            if [ $CHARCOUNT -gt 0 ] ; then
                CHARCOUNT=$((CHARCOUNT-1))
                PROMPT=$'\b \b'
                proxyPass="${proxyPass%?}"
            else
                PROMPT=''
            fi
        else
            CHARCOUNT=$((CHARCOUNT+1))
            PROMPT='*'
            proxyPass+="$CHAR"
        fi
    done
    stty echo
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
    echo "       b. VmWare Workstation (http://www.vmware.com/products/workstation.html)"
    echo ""
    echo "NOTE:"
    echo "    * I develop on gnu linux (specifically Fedora).  While vagrant supports other"
    echo "      virtualization technologies, I only test the ones listed."
    echo ""
    echo "OPTIONS:"
    echo "  Required arguments for long options are mandatory for short options."
    echo "  --help, -h"
    echo "      show the help screen"
    echo "  --proxy, -p"
    echo "      provision a proxy in the virtualized environment"
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
    echo "    https://github.com/sunckell/full-moon-developer-workstation/issues"
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

# --- let's load the most used vagrant plugins
# --- https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins
# --- or from the command line: gem list --remote vagrant-
install_vagrant_plugins()
{
    logger "installing vagrant plugins"

    vagrant plugin install vagrant-vbguest
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-vbguest install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    vagrant plugin install vagrant-reload
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-reload install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    vagrant plugin install vagrant-env
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-env install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    vagrant plugin install vagrant-proxyconf
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-proxyconf install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    vagrant plugin install vagrant-timezone
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-timezone install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    vagrant plugin install vagrant-reload
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-reload install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

    # --- look, the default disk size for Debian is 9gb.  I get it, it's small
    # --- but even if you are using one vm in a domain driven design app ( 1 app == 2+ microservices)
    # --- 9 gb shoul dbe enough.  These things are supposed to be ephemeral.
    vagrant plugin install vagrant-disksize
    if [ "$?" != 0 ]; then
        logger "ERROR: vagrant-diskresize install failed."
        logger "ERROR: please investigate.  exitting.."
        exit 2
    fi

}
# --- configure vagrant based on the parms passed.
configure_vagrant()
{
     logger "configuring vagrant..."
     if [ "USE_PROXY" == "true" ]; then
       # --- vagrant is being run behind a proxy.
       # --- gather the right information to set up the vagrant guest.
       export doproxyconf=y
       prompt_user_for_info
       create_env_file

     else

     fi
}

# --- use a menu to ask for relative information.
prompt_user_for_info()
{
    echo "Enter the proxy host:"
    read proxy_host

    echo "Enter the proxy port:"
    read proxy_port

    echo "Enter your proxy user:"
    read proxy_user

    echo "Enter your proxy password:"
    read -s proxy_pass
    export proxy_pass=`urlencode $proxy_pass`
    echo

    echo "Enter email address:"
    read email_address
    export email_address=$email_address

    export proxy_user=$proxy_user
    export proxy_pass=$proxy_pass

    export http_proxy=http://$proxy_user:$proxy_pass@$proxy_host:$proxy_port
    export https_proxy=https://$proxy_user:$proxy_pass@$proxy_host:$proxy_port

}

# --- store the environment variables we want in the docker containers in a .env file for later
create_env_file()
{
    if [ -e .env ];then
      rm -rf .env
    fi

    echo doproxyconf=$doproxyconf > .env
    echo email_address=$email_address >> .env
    echo proxy_user=$proxy_user >> .env
    echo proxy_pass=$proxy_pass >> .env
    echo sshPrivateKey=$sshPrivateKey >> .env
}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  # --- TODO: make it so that you can pass all the parms in or drive a menu!
  parse_cmd_line "$@"
  configure_vagrant
  install_vagrant_plugins
  logger "done. exitting, stage right!"
}

# --- do it!
main "$@"
