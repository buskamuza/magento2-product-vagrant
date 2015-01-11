# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = 2048
  end
  config.vm.network :private_network, ip: '192.168.10.11'
  config.vm.host_name = "magento2.product.dev"
  config.vm.synced_folder '.', '/vagrant', nfs: true

  config.vm.provision :shell, path: "bootstrap.sh"
end
