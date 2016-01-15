class ganesha::repo (
  $ganesha_version = $ganesha::params::ganesha_version
) inherits ganesha::params {
   file {$ganesha::params::ganesha_repo:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      content => template("${module_name}/nfs-ganesha.repo.erb")
   }
}
