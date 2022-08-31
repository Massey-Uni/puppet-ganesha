class ganesha::repo (
  $ganesha_version = $ganesha::params::ganesha_version 
) inherits ganesha::params {

  $release = $ganesha_version
  case $facts['os']['family'] {
    'RedHat': {
      class { 'ganesha::repo::yum':
        release => $release,
      }
    }
    'Debian': {
      #class { 'ganesha::repo::apt':
      #  release => $release,
      #}
    }
    default: { fail("${facts['os']['family']} not yet supported!") }
  }

}
