
How to vagrant up (Dataverse) on Windows
=================================================


Before you start
-----------------

* Your git setting about the line terminator must be unix-type or keep-original setting before you clone the Dataverse project from its IQSS GitHub; otherwise, its BASH-based set-up scripts would fail after vagrant up.

* If you want the host-side rather than guest-side to open the admin console of GlassFish Server or connect to postgresql server, add port-forwarding settings like below to the Vagrantfile:

```BASH
    config.vm.network "forwarded_port", guest: 4848, host: 14848

config.vm.network "forwarded_port", guest: 5432, host: 15432
```
* If you are going to simultaneously vagrant up two or more VirtualBox intances, it is better to set a unique forwarding-port number for SSH for each instance to avoid ssh-port-conflicts:

```BASH
    config.vm.network "forwarded_port", id: "ssh", guest: 22, host: 7022
```
