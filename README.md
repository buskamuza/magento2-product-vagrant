# Vagrant for magento/product-community-edition

[magento/product-community-edition](https://packagist.org/packages/magento/product-community-edition) is used to deploy a Magento 2 project from [packages](http://packages.magento.com/).

See Alan Kent's post [REDUCING MAGENTO 2 INSTALL PAIN THROUGH VIRTUALIZATION](https://alankent.wordpress.com/2014/12/21/reducing-magento-2-install-pain-through-virtualization/), where he describes two different strategies of using Magento 2 code:
> ... there are two different ways that developers are likely to interact with the Magento 2 code base now with the public GitHub repository now accepting pull requests.

> 1. Developers wishing to contribute to the Magento 2 code base (e.g. to submit a pull request with a bug fix) will clone the Magento 2 repository.

> 2. Developers building a customer production site should not clone the Magento 2 repository – they should instead use the officially released Composer packages (with version numbers), downloaded via Composer. They are also likely to make a number of local customizations that they would manage for that specific site.

In his post, Alan touches on the first scenario while this Vagrant configuration covers the second one. I'd also add a third scenario: developers creating their own extensions. I believe that in this scenario, the Magento code base should also be deployed from packages (covered by this configuration).

## What You Get

The current Vagrant configuration performs the following:

1. Runs Ubunty box
2. Installs and configures all software necessary for Magento 2
3. Downloads Magento 2 code from Composer [packages](http://packages.magento.com/)
4. Installs all necessary libraries
5. Installs the Magento 2 application

## Usage

If you never used Vagrant before, read [Vagrant Docs](https://docs.vagrantup.com/v2/)

You need to install:
- Vagrant
- VirtualBox (used by the current configuration)

To install, configure and run the Magento VM, you need to launch virtualbox and then execute the following via command line:

```
cd magento2-product # empty folder for the Magento 2 product
git clone https://github.com/buskamuza/magento2-product-vagrant.git .
vagrant up
```

### GitHub Limitations

Be aware that you may encounter GitHub limits on the number of downloads (used by Composer to download Magento dependencies).
These limits may significantly slow down the installation since all of the libraries will be cloned from GitHub repositories instead of downloaded as ZIP archives. In the worst case, these limitations may even terminate the installation.

If you have a GitHub account, you can bypass these limitations by using an OAuth token in the Composer configuration. See [API rate limit and OAuth tokens](https://getcomposer.org/doc/articles/troubleshooting.md#api-rate-limit-and-oauth-tokens) for more information.

For the Vagrant configuration you may specify your token in `local.config/github.oauth.token` file after cloning the repository. The file is a basic text file and is ignored by Git, so you'll need to create it yourself. Simply write your OAuth token in this file making sure to avoid any empty spaces, and it will be read during deployment. You should see the following message in the Vagrant log:
```
Installing GitHub OAuth token from /vagrant/local.config/github.oauth.token
```

## After Installation

Upon a successful installation, you'll see the location and URL of the newly-installed Magento 2 application:
```
Installed Magento application in /var/www/magento2
Access front-end at http://192.168.10.11/
Access back-end at http://192.168.10.11/admin/
```
The directory is a path on the VM.
The URL represented as IP address may be changed in the `Vagrantfile` **before** installation:
```
config.vm.network :private_network, ip: '192.168.10.11'
```

## Additional Information

```
db host: localhost (not accessible remotely)
db user/password: magento/magento
db name: magento

also available db user/password: root/password

Magento admin user/password: admin/iamtheadmin
```

## Removing the Installation

If the installation terminates at any time, or you want to get rid of the VM, you can use 

``` 
vagrant destroy
```
from inside the Magento 2 product folder.


## Related Repositories

Vagrant for [magento/magento2](https://github.com/magento/magento2):
- https://github.com/alankent/vagrant-magento2-apache-base
- https://github.com/ryanstreet/magento2-vagrant
- https://github.com/rgranadino/mage2_vagrant

Additionally, I'd like to thank the authors of the above repositories as they provided me with some ideas for a better implementation of the Vagrant configuration.
