class ganesha::storhaug::smb (
  $conf = $::ganesha::params::storhaug_smb_conf,
  $ha_smb_type = 'glusterfs',
  $ha_smb_vol  = 'ctdb',
  $ha_smb_mnt_dir = undef,
) {
  file {$conf:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    content => template("${module_name}/storhaug/smb-ha.conf.erb")
  }
}
