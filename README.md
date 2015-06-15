# ganesha

#### Table of Contents

1. [Overview](#overview)
2. [Parameters](#parameters)
3. [Usage example](#usage)
4. [Limitations](#limitations)
5. [ChangeLog](#changelog)

## Overview

Puppet module to configure an nfs-ganesha server.

## Parameters

The module accepts an hash of parameters called **exports**.
Each block corresponds to an export and the key is the export ID.
The available parameters for each exports are:

* **path**: Path of the volume to be exported. Eg: "/test_vol"
* **hostname**: IP of one of the nodes in the trusted pool
* **volume**: Volume name. Eg: "test_vol"
* **pseudo_path**: NFSv4 pseudo path for this export. Eg: "/test_vol_pseudo"


## Usage example

```ganesha
class { 'ganesha':
  exports => {
                1 => {
                       path        => "/test_vol1",
                       hostname    => "10.0.0.1",
                       volume      => "/test_vol1",
                       pseudo_path => "/test_vol1_pseudo"
                     },
                2 => {
                       path        => "/test_vol2",
                       hostname    => "10.0.0.1",
                       volume      => "/test_vol2",
                       pseudo_path => "/test_vol2_pseudo"
                     },
             }
}
```
Additional parameter to the module, for HA, are:
* **ganesha_conf**: Ganesha configuration file
* **ganesha_opts_conf**: Ganesha options configuration file
* **ganesha_sysconf**: Ganesha sysconf configuration file
* **ganesha_ha_conf**: Ganesha HA configuration file. Defaults to /etc/ganesha/ganesha.conf
* **exports_conf**: Ganesha exports configuration file. Default is /etc/ganesha/exports.conf
* **ganesha_logfile**: Ganesha log file. Defaults to /var/log/ganesha.log
* **ganesha_debuglevel**: Ganesha debug level. Can be one of NIV_NULL, NIV_MAJ, NIV_CRIT, NIV_EVENT, NIV_DEBUG, NIV_MID_DEBUG or NIV_FULL_DEBUG. Defaults is NIV_EVENT.
* **ganesha_pidfile**: Ganesha pid file. Default is /var/run/ganesha.nfsd.pid
* **enable**: Enable mode for the ganesha service
* **ensure**: Ensure mode for the ganesha service
* **ha**: Enable (true) or disable (false) the HA features
* **ha_name**: The HA cluster name, unique string
* **ha_vol_server**: The server from which you intend to mount the shared volume
* **ha_vips**: Hash of "server_name" => "VIP"
* **rquota_port**: Port to be used by the rquota RPC. Defaults to 4501


## Limitations

Currently only RedHat and its derivatives are supported

## ChangeLog

**0.1.0**

* Initial version
