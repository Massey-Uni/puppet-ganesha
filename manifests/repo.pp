class ganesha::repo inherits ganesha::params {
   file {$ganesha::params::ganesha_repo:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0644,
      source => "puppet:///modules/${module_name}/nfs-ganesha.repo"
   }
}
