class ganesha::storhaug (
  $conf      = $::ganesha::params::storhaug_conf,
  $ganesha_conf = $::ganesha::params::ganesha_conf,
  $ganesha_export_dir = $::ganesha::params::ganesha_export_dir,
  $ganesha_pkgs = $::ganesha::params::ganesha_pkgs,
  $repo      = undef,
  $packages  = $::ganesha::params::storhaug_pkgs,
  $ha_name   = 'storhaug',
  $ha_password = 'hacluster',
  $ha_server,
  $ha_cluster_nodes,
  $ha_storage_nodes = undef,
  $ha_mnt_dir       = undef,
  $ha_vips,
  $ha_vip_nodes,
  $ha_deterministic_failover = false,
  $ha_services = ['nfs','smb'],
) inherits ::ganesha::params {
  class { ganesha::repo: ganesha_version => $ganesha_version }

  package { $ganesha_pkgs:
    ensure => installed,
    require => File[$ganesha::params::ganesha_repo],
  }

  if ($repo) {
    yumrepo {'ganesha-storhaug':
      name     => 'ganesha-storhaug',
      descr    => 'Ganesha Storhaug repository',
      baseurl  => $repo,
      gpgcheck => 0,
    }
  }

  if ($packages) {
    package {$packages: ensure => latest}
  }

  file {$conf:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    content => template("${module_name}/storhaug/storhaug.conf.erb")
  }

  file { $ganesha_conf:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/storhaug/ganesha.conf.erb"),
  }

  file { $ganesha_export_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
