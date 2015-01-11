# Vagrant for magento/product-community-edition

[magento/product-community-edition](https://packagist.org/packages/magento/product-community-edition) is used to deploy Magento 2 project from [packages](http://packages.magento.com/).

See Alan Kent's post [REDUCING MAGENTO 2 INSTALL PAIN THROUGH VIRTUALIZATION](https://alankent.wordpress.com/2014/12/21/reducing-magento-2-install-pain-through-virtualization/), where he describes 2 different strategies of using Magento 2 code:
> ... there are two different ways that developers are likely to interact with the Magento 2 code base now with the public GitHub repository now accepting pull requests.

> 1. Developers wishing to contribute to the Magento 2 code base (e.g. to submit a pull request with a bug fix) will clone the Magento 2 repository.

> 2. Developers building a customer production site should not clone the Magento 2 repository – they should instead use the officially released Composer packages (with version numbers), downloaded via Composer. They are also likely to make a number of local customizations that they would manage for that specific site.

In his post Alan touches 1st scenario. While this Vagrant configuration covers 2nd one. I'd also add 3rd scenario - developers creating their extensions. I believe, in this scenario Magento code base should also be daployed from packages (covered by this configuration).

## What You Get?

Current Vagrant configuration performs the following:

1. Run Ubunty box
2. Install and configure all software necessary for Magento 2
3. Download Magento 2 code from Composer [packages](http://packages.magento.com/)
4. Install all necessary libraries
5. Install Magento 2 application

## Usage

If you never used Vagrant before, read [Vagrant Docs](https://docs.vagrantup.com/v2/)

You need to install:
- Vagrant
- VirtualBox (used by the current configuration)

All you need to run Magento VM is the following:
```
cd magento2-product # empty folder for the Magento 2 product
git clone https://github.com/buskamuza/magento2-product-vagrant.git .
vagrant up
```

## After Installation

When installation is successfully finished, you'll see location and URL of the installed Magento 2 application:
```
Installed Magento application in /var/www/magento2
Access front-end at http://192.168.10.11/
Access back-end at http://192.168.10.11/admin/
```
The directory is a path on the VM.
URL represented as IP address may be changed in `Vagrantfile` **before** installation:
```
config.vm.network :private_network, ip: '192.168.10.11'
```

Additional information:

```
db host: localhost (not accessible remotely)
db user/password: magento/magento
db name: magento

also available db user/password: root/password

Magento admin user/password: admin/iamtheadmin
```

## Related Repositories

Vagrant for [magento/magento2](https://github.com/magento/magento2):
- https://github.com/alankent/vagrant-magento2-apache-base
- https://github.com/ryanstreet/magento2-vagrant
- https://github.com/rgranadino/mage2_vagrant

Actually, I'd like to say "thanks" to authors of the above repositories. They gave me some ideas of the better implementation of the Vagrant configuration.
