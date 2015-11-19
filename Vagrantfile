# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "puppetlabs/centos-7.0-64-nocm"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

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
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # From:
  #  https://simp-project.atlassian.net/wiki/display/SD/Setting+up+your+build+environment
  config.vm.provision "shell", inline: <<-SHELL
    # Install required packages
    # --------------------------------------------------------------------------
    sudo yum install -y augeas-devel createrepo genisoimage git gnupg2 \
                        libicu-devel libxml2 libxml2-devel libxslt libxslt-devel \
                        mock rpmdevtools clamav
    sudo usermod -a -G mock vagrant

    # Install RVM
    # --------------------------------------------------------------------------
    cd ~vagrant
    sudo -u vagrant gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    sudo -u vagrant \\curl -sSL https://get.rvm.io > ~vagrant/get-rvm.bash
    sudo -u vagrant bash ~vagrant/get-rvm.bash stable --ruby=2.0.0 --with-default-gems="bundler pry"
    sudo -u vagrant ~vagrant/.rvm/bin/rvm all do gem install bundler pry
  SHELL
end
