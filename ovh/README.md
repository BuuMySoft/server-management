OVH Server installation and management
====

How To install Xen on a OVH dedicated server
---

1. Get the URL of the raw file `install_xen_on_ovh_server.sh`
1. Copy this URL as the installation script in the OVH installation process
1. Once the server is installed, reboot the
1. Replace the file `/etc/xen-tools/xen-tools.conf` by the one in this directory

How create a Xen VM
---

### Prerequesites

* Order a set of failover IPs
* Create a MAC address for every IP you will use

### Description

#### Without role
Run the following command:
```xen-create-image --hostname=<hostname> --ip=<IP failover> --mac=<mac associated to the IP>```

#### With role
Run the following command:
```xen-create-image --hostname=<hostname> --ip=<IP failover> --mac=<mac associated to the IP> --role=<role>```
