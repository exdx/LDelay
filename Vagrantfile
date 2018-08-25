# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 9545, host: 9545
  config.vm.network "forwarded_port", guest: 3000, host: 3000


  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |vb|
  vb.name = "LDelay-dev-instance"
  # Display the VirtualBox GUI when booting the machine
  vb.gui = true
  # Customize the amount of memory on the VM:
  vb.memory = "1024"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
  apt-get update
  # apt-get install -y node
  apt-get install -y npm
  git clone https://github.com/Denton24646/LDelay
  git clone https://github.com/oraclize/ethereum-bridge
  SHELL
end
