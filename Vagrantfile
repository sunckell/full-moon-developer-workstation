# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
vagrant_settings = YAML.load_file('vagrant_config.yaml')

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # --- some confgurations from the external config file
  config.vm.hostname =  vagrant_settings['vm']['hostname']

  # --- since everything in AWS is UTC, we should get accustomed to it.  But if you have to
  # --- have the time zone set to your particular space in the world, we'll externalize it.
  timezone = vagrant_settings['vm']['timezone']
  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = timezone
  end

  # --- vagrant-vbguest plugin configurations
  # --- https://github.com/dotless-de/vagrant-vbguest

  # we will try to autodetect this path.
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or an URL:
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
  # or relative to the Vagrantfile:
  # config.vbguest.iso_path = File.expand_path("../relative/path/to/VBoxGuestAdditions.iso", __FILE__)

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true



  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
     # --- display the VirtualBox GUI when booting the machine
     vb.gui = true

     # -- customize the amount of memory on the VM:
     vb.memory = vagrant_settings['vm']['memory']

     # --- make some more custom virtualbox configurations
     vb.name = vagrant_settings['vm']['name'] + '_' + Time.now.strftime("%Y-%m-%d-%H%M%S%L")
     vb.customize ["modifyvm", :id, "--cpus", vagrant_settings['vm']['cpus']]
     vb.customize ["modifyvm", :id, "--vram", "128"]
     vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
   end

   #setup proxy for corporate network vagrant box
   doproxyconf = ENV['doproxyconf']
   if doproxyconf == 'y'
     username = ENV['proxyUser']
     password = ENV['proxyPass']
     email = ENV['emailAddress']
     sshPrivateKey = ENV['sshPrivateKey']
     config.vm.provision "file", source: "#{sshPrivateKey}", destination: "~/.ssh_keys"
     cmd = "cp ~/.ssh_keys/* ~/.ssh/ && chmod 400 ~/.ssh/* && rm -R ~/.ssh_keys"
     config.vm.provision :shell, :inline => cmd, :privileged => false
   if Vagrant.has_plugin?("vagrant-proxyconf")
     config.proxy.http     = "http://#{username}:#{password}@proxy.troweprice.com:8080"
     config.proxy.https    = "http://#{username}:#{password}@proxy.troweprice.com:8080"
     config.proxy.no_proxy = "localhost,127.0.0.1,.example.com,.troweprice.com,.awstrp.net"
     # per the doc this must be declared or it will never be set
     config.git_proxy.http = "http://#{username}:#{password}@proxy.troweprice.com:8080"
   end

     cmd = "git config --global user.name #{username}; git config --global user.email #{email}"
     config.vm.provision :shell, :inline => cmd, :privileged => false
     cmd = "git config --global url.\"git@github.awstrp.net:\".insteadOf \"https://github.awstrp.net\""
     config.vm.provision :shell, :inline => cmd, :privileged => false
   end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  # --- custominzing via provisioners
  config.vm.provision "shell", path: "scripts/configure_desktop.sh"

  # --- install the Hashicorp stack of tools
  config.vm.provision "file", source: "files/hashicorp.asc", destination: "/tmp/hashicorp.asc"
  config.vm.provision "shell", path: "scripts/install_hashicorp_stack.sh"
  config.vm.provision "shell", path: "scripts/configure_desktop.sh"
  config.vm.provision "shell", path: "scripts/install_cloud_sdk.sh"

  # --- install some extra software that make our lives easier.
  config.vm.provision "shell", path: "scripts/install_extra_software.sh"

  # --- sometimes it makes sense to reload your vm during.
  # --- https://github.com/aidanns/vagrant-reload
  config.vm.provision :reload
end
