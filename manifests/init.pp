
class lwr (
  $user,
  $repository_url = "https://bitbucket.org/jmchilton/lwr",
  $port = 8913,
  $private_token = undef,
  $destination = '/usr/share/lwr',
  $ssl_pem = undef,
) {
  
  if defined(User[$user]) {
    User[$user] -> Vcsrepo[$destination]
  }

  vcsrepo { "$destination":
    ensure => present,
    provider => git,
    source => $repository_url,
    owner => $user,
  }

  exec { 'create lwr virtualenv':
    command => "/bin/bash -c 'setup_venv.sh'",  
    cwd     => $destination,
    creates => "$destination/.venv",
    require => [Vcsrepo[$destination],],
    user => $user,
  }

  file { "$destination/server.ini":
    content => template("lwr/server.ini.erb"),
    owner => $user,
  }

  file { "$destination/job_managers.ini":
    content => template("lwr/job_managers.ini.erb"),
    owner   => $user,
  }

  if $ssl_pem != undef {
    package { "libssl-dev":
    }
    
    file { "$destination/host.pem":
      content => $ssl_pem,
      owner   => $user,
      mode    => 0644,
    }
  }

}

