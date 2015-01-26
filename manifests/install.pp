# = Private class: kibana3::install
#
# Author: Alejandro Figueroa
class kibana3::install {
  if $::kibana3::manage_git {
    require 'git'
  }

  if $::kibana3::k3_folder_owner {
    $_ws_user = $::kibana3::k3_folder_owner
  } elsif $::kibana3::manage_ws {
    $_ws_user = $::apache::params::user
  } else {
    $_ws_user = 'root'
  }

  Vcsrepo[$::kibana3::k3_install_folder] -> Apache::Vhost[$::kibana3::ws_servername]

  include ::apache

  $base_options = {
    'port'          => $::kibana3::ws_port,
    'default_vhost' => $::kibana3::ws_default_vhost,
    'docroot'       => "${::kibana3::k3_install_folder}/src",
    'docroot_owner' => $_ws_user,
  }

  $merged_options = merge($base_options, $::kibana3::ws_extras)
  $vhost_configuration = hash([$::kibana3::ws_servername, $merged_options])
  create_resources('apache::vhost', $vhost_configuration, { 'notify' => 'Service[httpd]' })

  vcsrepo {
    $::kibana3::k3_install_folder:
    ensure   => present,
    provider => git,
    source   => $::kibana3::k3_clone_url,
    revision => $::kibana3::k3_release,
    owner    => $_ws_user,
  }
}
