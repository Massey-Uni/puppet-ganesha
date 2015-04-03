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

The module accepts the an hash of parameters called **exports**.
Each block corresponds to an export and the key is the export ID.
The available parameters for each exports are:

* **path**: Path of the volume to be exported. Eg: "/test_vol"
* **hostname**: IP of one of the nodes in the trusted pool
* **volume**: Volume name. Eg: "test_vol"
* **pseudo_path**: # NFSv4 pseudo path for this export. Eg: "/test_vol_pseudo"


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

## Limitations

Currently only RedHat and its derivatives are supported

## ChangeLog

**0.1.0**

* Initial version
