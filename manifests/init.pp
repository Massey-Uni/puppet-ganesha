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
   $exports = {},
) inherits ganesha::params {
   include ganesha::repo

   package { $ganesha::params::ganesha_pkgs:
     ensure => installed,
     require => File[$ganesha::params::ganesha_repo]
   }

   $ganesha_exports = $ganesha::params::ganesha_exports

   file { $ganesha_exports:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => template("${module_name}/export.conf.erb")
   }

   file { $ganesha::params::ganesha_conf:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => template("${module_name}/ganesha.nfsd.conf.erb"),
      require => File[$ganesha_exports]
   }

   service { $ganesha::params::ganesha_service:
      ensure  => running,
      enable  => true,
      require => File[$ganesha::params::ganesha_conf],
   }
}
