class ganesha::params {
    case $osfamily {
      'RedHat': {
         $ganesha_pkgs         = [ 'nfs-ganesha' ]
         $ganesha_gluster_pkgs = [ 'nfs-ganesha-fsal-gluster' ]
         $exports_conf         = '/etc/ganesha/export.conf'
         $ganesha_conf         = '/etc/ganesha/ganesha.conf'
         $ganesha_ha_conf      = '/etc/ganesha/ganesha-ha.conf'
         $ganesha_service      = 'nfs-ganesha'
         $ganesha_repo         = "/etc/yum.repos.d/nfs-ganesha.repo"
         $ganesha_logfile      = "/var/log/ganesha.log"
         $ganesha_debuglevel   = "NIV_EVENT"
         $ganesha_pidfile      = "/var/run/ganesha.nfsd.pid"
         $rquota_port          = 4501
      }
      default: {
         fail ("OS type $osversion is not supported")
      }
    }
}
