# @summary enable the upstream NFS Ganesha Yum repo
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
# Based on Gluster repo

class ganesha::repo::yum (
  String $release = $ganesha::params::ganesha_version,
  String $repo_key_source = $ganesha::params::repo_gpg_key_source,
) inherits ganesha::params {

  case $facts['os']['family'] {
    'RedHat': {
        $sig_mirror = $facts['os']['release']['major'] ? {
        '8' => 'centos.org/centos/8-stream',
        '9' => 'stream.centos.org/SIGs/9-stream',
        default => "centos.org/centos/${facts['os']['release']['major']}"
        }
      }
    default: {
        $sig_mirror = "centos.org/centos/${facts['os']['release']['major']}"
      }
  }

  $_release = if versioncmp($release, '4.1') <= 0 {
    $release
  } else {
    $release.scanf('%d')[0]
  }

  yumrepo { "NFS-Ganesha-${facts['os']['architecture']}":
    enabled  => 1,
    baseurl  => "http://mirror.${sig_mirror}/storage/${facts['os']['architecture']}/nfsganesha-${_release}/",
    descr    => "CentOS-${facts['os']['release']['major']} - NFS-Ganesha ${_release}",
    gpgcheck => 1,
    gpgkey   => $repo_key_source,
  }

}
