
class lwr (
  $user,
  $repository_url = "https://bitbucket.org/jmchilton/lwr",
  $port = 8913,
  $private_token = undef,
  $destination = '/usr/share/lwr',
  $ssl_pem = undef,
) {
  # Also needed python-dev, python-setuptools.
  
  if defined(User[$user]) {
    User[$user] -> Vcsrepo[$destination]
  }

  vcsrepo { "$destination":
    ensure => present,
    provider => hg,
    source => $repository_url,
    owner => $user,
  }

  exec { 'create lwr virtualenv':
    command => "/bin/bash -c './setup_venv.sh'",  
    cwd     => $destination,
    creates => "$destination/.venv",
    require => [Vcsrepo[$destination],],
    user => $user,
  }

  file { "$destination/server.ini":
    content => template("lwr/server.ini.erb"),
    owner   => $user,
    require => [Vcsrepo[$destination]],
  }

  file { "$destination/job_managers.ini":
    content => template("lwr/job_managers.ini.erb"),
    owner   => $user,
    require => [Vcsrepo[$destination]],
  }

  if $ssl_pem != undef {
    package { "libssl-dev":
    }
    
    file { "$destination/host.pem":
      content => $ssl_pem,
      owner   => $user,
      mode    => 0644,
      require => [Vcsrepo[$destination]],
    }
  }

}

