class ganesha::params {
    case $osfamily {
      'RedHat': {
         $ganesha_version           = '2.3.0'
         $ganesha_pkgs              = [ 'nfs-ganesha' ]
         $ganesha_gluster_pkgs      = [ 'nfs-ganesha-fsal-gluster' ]
         $exports_conf              = '/etc/ganesha/export.conf'
         $ganesha_conf              = '/etc/ganesha/ganesha.conf'
         $ganesha_export_dir        = '/etc/ganesha/exports'
         $ganesha_export_conf       = '/etc/ganesha/export.conf'
         $ganesha_opts_conf         = '/etc/ganesha/ganesha-opts.conf'
         $ganesha_ha_conf           = '/etc/ganesha/ganesha-ha.conf'
         $ganesha_service           = 'nfs-ganesha'
         $ganesha_sysconf           = '/etc/sysconfig/ganesha'
         $ganesha_repo              = "/etc/yum.repos.d/nfs-ganesha.repo"
         $ganesha_logfile           = "/var/log/ganesha.log"
         $ganesha_debuglevel        = "NIV_EVENT"
         $ganesha_pidfile           = "/var/run/ganesha.pid"
         $rquota_port               = 875
         $storhaug_conf             = '/etc/sysconfig/storhaug.conf'
         $storhaug_pkgs             = ['storhaug','storhaug-nfs','storhaug-smb']
         $storhaug_nfs_conf         = '/etc/sysconfig/storhaug.d/nfs-ha.conf'
         $storhaug_smb_conf         = '/etc/sysconfig/storhaug.d/smb-ha.conf'
         if ($operatingsystem != 'Fedora' and $operatingsystemmajrelease * 1 < 7) {
           $shared_storage_mountpoint = '/var/run/gluster/shared_storage'
         } else {
           $shared_storage_mountpoint = '/run/gluster/shared_storage'
         }
         $shared_storage_tmpconfig  = '/usr/lib/tmpfiles.d/gluster_shared_storage.conf'
      }
      default: {
         fail ("OS type $osversion is not supported")
      }
    }
}
