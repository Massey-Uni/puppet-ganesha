class ganesha::storhaug::nfs (
  $conf = $::ganesha::params::storhaug_nfs_conf,
  $export_conf = $::ganesha::params::ganesha_export_conf,
  $export_dir = $::ganesha::params::ganesha_export_dir,
  $exports = {},
  $ha_nfs_type = 'glusterfs',
  $ha_nfs_vol  = 'gluster_shared_storage',
  $ha_nfs_mnt_dir = undef,
  $ha_nfs_conf = undef,
) {
  file {$conf:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    content => template("${module_name}/storhaug/nfs-ha.conf.erb")
  }

  file {$export_conf:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    content => template("${module_name}/storhaug/export.conf.erb")
  }

  create_resources ('ganesha::storhaug::nfs::export', $exports)
}
