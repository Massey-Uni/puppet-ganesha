# == Class: ganesha
#
# Puppet module to configure an nfs-ganesha server
#
# === Parameters
#
# [*ganesha_conf*]
#   Ganesha configuration file
#
# [*ganesha_opts_conf*]
#   Ganesha options configuration file
#
# [*ganesha_sysconf*]
#   Ganesha sysconf configuration file
#
# [*ganesha_ha_conf*]
#   Ganesha HA configuration file
#
# [*exports_conf*]
#   Ganesha exports configuration file
#
# [*ganesha_logfile*]
#   Ganesha log file
#
# [*ganesha_debuglevel*]
#   Ganesha debug level. Can be one of NIV_NULL, NIV_MAJ, NIV_CRIT, NIV_EVENT, NIV_DEBUG, NIV_MID_DEBUG or NIV_FULL_DEBUG
#
# [*ganesha_pidfile*]
#   Ganesha pid file
#
# [*enable*]
#   Enable mode for the ganesha service
#
# [*ensure*]
#   Ensure mode for the ganesha service
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
# [*ha_vol_name*]
#   The name of the shared volume
#
# [*ha_vips*]
#   Hash of "server_name" => "VIP"
#
# [*rquota_port*]
#   Port to be used by the rquota RPC
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
   $ganesha_version    = $ganesha::params::ganesha_version,
   $ganesha_conf       = $ganesha::params::ganesha_conf,
   $ganesha_opts_conf  = $ganesha::params::ganesha_opts_conf,
   $ganesha_sysconf    = $ganesha::params::ganesha_sysconf,
   $ganesha_ha_conf    = $ganesha::params::ganesha_ha_conf,
   $exports_conf       = $ganesha::params::exports_conf,
   $ganesha_logfile    = $ganesha::params::ganesha_logfile,
   $ganesha_debuglevel = $ganesha::params::ganesha_debuglevel,
   $ganesha_pidfile    = $ganesha::params::ganesha_pidfile,
   $enable             = true,
   $ensure             = 'running',
   $exports            = {},
   $fsal               = 'gluster',
   $ha                 = false,
   $ha_name            = undef,
   $ha_vol_server      = undef,
   $ha_vol_name        = 'gluster_shared_storage',
   $ha_vips            = {},
   $rquota_port        = $ganesha::params::rquota_port
) inherits ganesha::params {

   class { ganesha::repo: ganesha_version => $ganesha_version }

   package { $ganesha::params::ganesha_pkgs:
     ensure => installed,
     require => File[$ganesha::params::ganesha_repo],
   }

   exec { 'cleanup-ganesha-config':
     path        => ['/bin', '/usr/bin'],
     command     => "rm -f $ganesha_conf",
     unless      => "grep \"^%include.*$ganesha_opts_conf\" $ganesha_conf",
     notify      => File[$ganesha_conf],
   }

   case $fsal {
     'gluster': {
       package { $ganesha::params::ganesha_gluster_pkgs:
         ensure  => installed,
         require => File[$ganesha::params::ganesha_repo]
       }
     }
   }

   if (!$ha) {
     file { $exports_conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/export.conf.erb"),
        notify  => Service[$ganesha::params::ganesha_service]
     }

     file { $ganesha_conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha_noha.conf.erb"),
        require => File[$exports_conf],
        notify  => Service[$ganesha::params::ganesha_service]
     }

     $ganesha_require = [File[$ganesha_conf]]
   } else {
     file { $exports_conf: ensure => absent }

     $shared_storage_location = $ganesha::params::shared_storage_mountpoint
     file { $shared_storage_location:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
     }

     mount { $shared_storage_location:
        ensure => mounted,
        device => "${ha_vol_server}:/${ha_vol_name}",
        fstype => 'glusterfs',
        options => '_netdev,defaults',
        notify  => Service[$ganesha::params::ganesha_service]
     }

     if ($operatingsystemmajrelease >= 7) {
       file { $ganesha::params::shared_storage_tmpconfig:
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => 0755,
          content => template("${module_name}/shared_storage.erb"),
       }
     }

     $ha_cluster_nodes = join(sort(keys($ha_vips)),",")

     file { $ganesha_conf:
        ensure  => present,
        replace => false,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha_ha.conf.erb"),
        require => [File[$ganesha_opts_conf],Exec['cleanup-ganesha-config']],
        notify  => Service[$ganesha::params::ganesha_service]
     }

     file { $ganesha_opts_conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha_ha_opts.conf.erb"),
        notify  => Service[$ganesha::params::ganesha_service]
     }

     file { $ganesha_ha_conf:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template("${module_name}/ganesha-ha.conf.erb"),
        require => File[$exports_conf],
        notify  => Service[$ganesha::params::ganesha_service]
     }

     $ganesha_require = [File[$ganesha_conf],File[$ganesha_ha_conf],Mount[$shared_storage_location]]
   }

   file { $ganesha_sysconf:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => template("${module_name}/ganesha.sysconf.erb"),
      notify  => Service[$ganesha::params::ganesha_service]
   }

   if ($ha) {
     service { $ganesha::params::ganesha_service:
        enable => false,
        ensure => $ensure,
        require => $ganesha_require,
     }
   } else {
     service { $ganesha::params::ganesha_service:
        ensure  => $ensure,
        enable  => $enable,
        require => $ganesha_require,
     }
   }
}
