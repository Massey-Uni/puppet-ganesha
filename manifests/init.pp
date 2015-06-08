# == Class: ganesha
#
# Puppet module to configure an nfs-ganesha server
#
# === Parameters
#
# [*exports*]
#   Hash with exports.
#   The hash keys are the export IDs, unique to each export,
#   and the parameters are:
#     path: Path of the volume to be exported. Eg: "/test_vol"
#     hostname: IP of one of the nodes in the trusted pool
#     volume: Volume name. Eg: "test_vol"
#     pseudo_path: # NFSv4 pseudo path for this export. Eg: "/test_vol_pseudo"
#
# [*ha*]
#   Enable (true) or disable (false) the HA features
#
# [*ha_name*]
#   The HA cluster name, unique string
#
# [*ha_vol_server*]
#   The server from which you intend to mount the shared volume
#
# [*ha_vips*]
#   Hash of "server_name" => "VIP"
#
# === Examples
#
#  class { 'ganesha':
#    exports => {
#                  1 => {
#                         path        => "/test_vol1",
#                         hostname    => "10.0.0.1",
#                         volume      => "/test_vol1",
#                         pseudo_path => "/test_vol1_pseudo"
#                       },
#                  2 => {
#                         path        => "/test_vol2",
#                         hostname    => "10.0.0.1",
#                         volume      => "/test_vol2",
#                         pseudo_path => "/test_vol2_pseudo"
#                       },
#               }
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2015 Alessandro De Salvo, unless otherwise noted.
#

class ganesha (
   $exports       = {},
   $fsal          = 'gluster',
   $ha            = false,
   $ha_name       = undef,
   $ha_vol_server = undef,
   $ha_vips       = {}
) inherits ganesha::params {
   include ganesha::repo

   package { $ganesha::params::ganesha_pkgs:
     ensure => installed,
     require => File[$ganesha::params::ganesha_repo]
   }

   case $fsal {
     'gluster': {
       package { $ganesha::params::ganesha_gluster_pkgs:
         ensure  => installed,
         require => File[$ganesha::params::ganesha_repo]
       }
     }
   }

   $ganesha_exports = $ganesha::params::ganesha_exports

   if (!$ha) {
     file { $ganesha::params::ganesha_ha_conf1: ensure => absent }
     file { $ganesha::params::ganesha_ha_conf2: ensure => absent }

     file { $ganesha_exports:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/export.conf.erb"),
        notify  => Service[$ganesha::params::ganesha_service]
     }

     file { $ganesha::params::ganesha_conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha.nfsd.conf.erb"),
        require => File[$ganesha_exports],
        notify  => Service[$ganesha::params::ganesha_service]
     }

     $ganesha_require = [File[$ganesha::params::ganesha_conf]]
   } else {
     file { $ganesha_exports: ensure => absent }
     file { $ganesha::params::ganesha_conf: ensure => absent }

     $ha_cluster_nodes = join(sort(keys($ha_vips)))

     file { $ganesha::params::ganesha_ha_conf1:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => "",
        notify  => Service[$ganesha::params::ganesha_service]
     }

     file { $ganesha::params::ganesha_ha_conf2:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha-ha.conf.erb"),
        require => File[$ganesha_exports],
        notify  => Service[$ganesha::params::ganesha_service]
     }

     $ganesha_require = [File[$ganesha::params::ganesha_ha_conf1],File[$ganesha::params::ganesha_ha_conf2]]
   }

   service { $ganesha::params::ganesha_service:
      ensure  => running,
      enable  => true,
      require => $ganesha_require,
   }
}
