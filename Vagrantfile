# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false

  config.vm.synced_folder ".", "/vagrant"

  config.vm.hostname = "project.test"
  config.vm.network "private_network", ip: "192.168.20.10"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 2
    vb.memory = "1024"
  end

  config.vm.provision :shell, :path => "provision/bootstrap.sh"
end