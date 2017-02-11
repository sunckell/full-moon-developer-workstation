#!/usr/bin/env bash
# --- name:   install_hashicorp_stack.sh
# --- auth:   ckell <sunckell at that google mail site>
# ---         - politely "borrowed" from mr. ploughma
# --- desc:   install the hashicorp tooling on an ami/vagrant host
# --- notes:  make sure the proxy configurations are installed prior
# ---         execution of this script.
# ---         * until we get a base image, we'll install them individually.
# --- TODO:   create a directory to store the binaries in version path and link
# ---         it to latest.  This will allow testing of multiple versions.
SCRIPT=`basename $0`

# --- simple logger to give me an idea of what's happening when.
logger()
{
    mesg=$1
    echo "[`date`] - ${SCRIPT} - ${mesg}"
}

# --- need to install some pre-reqs.
# --- one of these days I will check for the OS type and use the appropriate
# --- package manager
install_prereqs()
{
    logger "installing pre-reqs"

    logger "installing unzip"
    sudo apt-get -qq install -y unzip
    if [ $? -ne 0 ]; then
        logger "ERROR: install of unzip failed."
        logger "ERROR: cancelling build. please investigate."
        exit 2
    fi
}

# --- to be secure, install the Hashicorp pgp key
install_hashicorp_pgp_key()
{
    logger "installing hashicorp pgp key"

    logger "check for existance of hashicorp key on server"
    if [ ! -f /tmp/hashicorp.asc ]; then
        logger "ERROR: Hashicorp PGP key not found."
        logger "ERROR: cannot proceed.  Exitting."
        exit 2
    fi

    logger "gpg import of Hashicorp key"
    gpg --import /tmp/hashicorp.asc
    if [ $? -ne 0 ]; then
        logger "ERROR: gpg import of Hashicorp pgp key failed."
        logger "ERROR: cancelling build. please investigate."
        exit 2
    fi
}

# --- fetch the specific tool
fetch_tool_and_sums()
{
    logger "fetching required files for: $1 ver: $2"

    # --- should be here already, but just in case
    cd /var/tmp/$1_$2

    # -- progress bar doesn't work too well in packer. and wget isn't installed by default
    curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_linux_amd64.zip
    if [ $? -ne 0 ]; then
        logger "ERROR: curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_linux_amd64.zip failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_SHA256SUMS
    if [ $? -ne 0 ]; then
        logger "ERROR: curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_SHA256SUMS failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_SHA256SUMS.sig
    if [ $? -ne 0 ]; then
        logger "ERROR: curl -s -L -O https://releases.hashicorp.com/$1/$2/$1_$2_SHA256SUMS.sig failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi
}

# --- being secure and stuff!
gpg_verify_tool_files()
{
    logger "verifying SHA256SUMS signature file"
    # --- we should be here already, but just in case
    cd /var/tmp/$1_$2

    gpg --verify $1_$2_SHA256SUMS.sig $1_$2_SHA256SUMS
    if [ $? -ne 0 ]; then
        logger "ERROR: gpg --verify $1_$2_SHA256SUMS.sig $1_$2_SHA256SUMS failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    logger "verifying SHA256SUM for $1 $2"
    # --- there is no --ignore-missing flag in this version.  Skin the cat a different way.
    #sha256sum -c --ignore-missing $1_$2_SHA256SUMS
    sha256sum -c $1_$2_SHA256SUMS 2> /dev/null| grep ": OK$"
    if [ $? -ne 0 ]; then
        logger "ERROR: sha256sum -c terraform_0.7.13_SHA256SUMS 2> /dev/null| grep ": OK$" failed."
        logger "ERROR: a sha256sum should not fail."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi
}

# --- keybase has a lot to work out.  You cannot execute keybase as any admin user.  Packer build execute provisioners with sudo, so keybase
# --- on a ami build is going to need some more thought on the matter.
keybase_verify_tool_files()
{
    logger "installing keybase"
     # --- using --force becuase of libXScrnSaver dependency failure.
     curl -O https://prerelease.keybase.io/keybase_amd64.deb
     if [ $? -ne 0 ]; then
         logger "ERROR: curl keybase_amd64.deb failed."
         logger "ERROR: cancelling build.  please investigate."
         exit 2
     fi
     # --- if you see an error about missing `libappindicator1`
     # --- from the next command, you can ignore it, as the
     # --- subsequent command corrects it
     sudo dpkg -i keybase_amd64.deb
     sudo apt-get -qq  install -f
     #run_keybase
     if [ $? -ne 0 ]; then
         logger "ERROR: yum install of keybase failed."
         logger "ERROR: cancelling build. please investigate."
         exit 2
     fi

     logger "verifying SHA256SUMS signature file via keybase"
     cd /var/tmp/$1_$2

     keybase pgp verify -d $1_$2_SHA256SUMS.sig -i $1_$2_SHA256SUMS
     if [ $? -ne 0 ]; then
         logger "ERROR: keybase pgp verify -d $1_$2_SHA256SUMS.sig -i $1_$2_SHA256SUMS failed."
         logger "ERROR: a sha256sum should not fail."
         logger "ERROR: cancelling build.  please investigate."
         exit 2
     fi
}


# --- unzip the tool and move it into place
move_hashicorp_tool_to_path()
{
    logger "unzipping the $1 file"
    # --- we should be here already, but just in case
    cd /var/tmp/$1_$2

    unzip $1_$2_linux_amd64.zip
    if [ $? -ne 0 ]; then
        logger "ERROR: unzip $1_$2_linux_amd64.zip failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    logger "moving file into a directory in PATH"
    sudo mv ./$1 /usr/bin/$1
    if [ $? -ne 0 ]; then
        logger "ERROR: mv ./$1 /usr/bin/$1 failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    logger "setting permissions and ownership on $1"
    sudo chown root:root /usr/bin/$1
    if [ $? -ne 0 ]; then
        logger "ERROR: chown root:root /usr/bin/$1 failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

    sudo chmod 755 /usr/bin/$1
    if [ $? -ne 0 ]; then
        logger "ERROR: chmod 755 /usr/bin/$1 failed."
        logger "ERROR: cancelling build.  please investigate."
        exit 2
    fi

}

# --- make sure we can call the tool from the cmd and it's in PATH
verify_tool()
{
    logger "verifying tool is installed correctly"
    which $1
    if [ $? -ne 0 ]; then
        logger "ERROR: $1 not in PATH"
        logger "ERROR: Please investigate why $1 is not in the PATH."
        exit 2
    fi

}

# --- clean up the workspace we created.
cleanup_workspace()
{
    logger "Clean up the mess we made."
    rm -rf /var/tmp/$1_$2
    if [ $? -ne 0 ]; then
        logger "ERROR: rm -rf /var/tmp/$1_$2."
        logger "ERROR: I wonder why the remove failed.  Not cancelling.  But something to make you go hmmmm?"
    fi
}

# --- main function to call the other to do a proper installation of said Hashitool
install_hashicorp_tool()
{
    logger "installing $1 version $2"

    # --- make a temporary directory to work in.
    tmp_dir="/var/tmp/$1_$2"
    mkdir --mode '0755' --parents ${tmp_dir}
    if [ $? -ne 0 ]; then
        logger "==> ERROR: making temp directory failed."
        logger "==> ERROR: cancelling build.  please investigate."
        exit 2
    fi

    cd ${tmp_dir}

    # --- go get em..
    fetch_tool_and_sums $1 $2

    # --- verify they are real
    gpg_verify_tool_files $1 $2

    # --- move binary in PATH
    move_hashicorp_tool_to_path $1 $2

    # --- is it installed right?
    verify_tool $1

    # --- clean up our workspace
    cleanup_workspace $1 $2

}

# --- a sane place to kick of the actions
main()
{
  logger "starting ${SCRIPT}......"
  logger "insalling Hashicorp tooling in a vagrant box"
  install_prereqs
  install_hashicorp_pgp_key

  # --- this set of calls could easily be converted to ARGV.
  install_hashicorp_tool terraform 0.8.6
  install_hashicorp_tool packer 0.12.2
  install_hashicorp_tool vault 0.6.5
  install_hashicorp_tool consul 0.7.4
  install_hashicorp_tool nomad 0.5.4
  install_hashicorp_tool consul-template 0.18.1
  install_hashicorp_tool consul-replicate 0.3.1
  install_hashicorp_tool envconsul 0.6.2

  logger "done ${SCRIPT}. exitting, stage right!"
}

# --- do it!
main "$@"
