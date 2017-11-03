define ganesha::storhaug::nfs::export (
  $ensure = 'present',
  $id = 1,
  $ganesha_export_dir = $::ganesha::params::ganesha_export_dir,
  $ganesha_export_conf = $::ganesha::params::ganesha_export_conf,
) {
  $filename = sprintf("%s/%02d-%s.conf", $ganesha_export_dir, $id, $title)
  if ($ensure == 'present') {
    $export_setup = Exec["add ganesha ${title} export"]
  } else {
    $export_setup = Exec["remove ganesha ${title} export"]
  }
  file { $filename:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/storhaug/ganesha.export.conf.erb"),
    notify  => $export_setup,
  }

  exec {"add ganesha ${title} export":
    path => ['/usr/bin'],
    command => "ganesha_mgr add_export ${filename} 'EXPORT(Export_ID=${id})'",
    timeout => 0,
    refreshonly => true,
  }

  exec {"remove ganesha ${title} export":
    path => ['/usr/bin'],
    command => "ganesha_mgr remove_export ${id}",
    timeout => 0,
    refreshonly => true,
  }
}
