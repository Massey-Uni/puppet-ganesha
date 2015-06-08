class ganesha::params {
    case $osfamily {
      'RedHat': {
         $ganesha_pkgs         = [ 'nfs-ganesha' ]
         $ganesha_gluster_pkgs = [ 'nfs-ganesha-fsal-gluster' ]
         $ganesha_exports      = '/etc/export.conf'
         $ganesha_conf         = '/etc/ganesha.nfsd.conf'
         $ganesha_ha_conf1     = '/etc/ganesha/ganesha.conf'
         $ganesha_ha_conf2     = '/etc/ganesha/ganesha-ha.conf'
         $ganesha_service      = 'nfs-ganesha'
         $ganesha_repo         = "/etc/yum.repos.d/nfs-ganesha.repo"
      }
      default: {
         fail ("OS type $osversion is not supported")
      }
    }
}
