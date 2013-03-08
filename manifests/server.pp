class postgresql_1_0::server (
  $server_package = $postgresql_1_0::params::server_package,
  $version = $postgresql_1_0::params::version,
  $listen = $postgresql_1_0::params::listen_address,
  $port = $postgresql_1_0::params::port,
  $ssl = true,
  $postgresql_max_connections = $postgresql_1_0::params::postgresql_max_connections,
  $path_pgconf = "postgresql_1_0"

) inherits postgresql_1_0::params {

  package { 
    "postgresql-server-$version":
      name    => sprintf("%s-%s", $server_package, $version),
      ensure  => present,
  }
  package { 
    "postgresql-server-dev-$version":
      name    => sprintf("%s-%s", $server_dev_package, $version),
      ensure  => present,
  }

  service { 
    "postgresql-system-$version":
      name        => 'postgresql',
      enable      => true,
      ensure      => running,
      hasstatus   => false,
      hasrestart  => true,
      provider    => 'debian',
      subscribe   => Package["postgresql-server-dev-$version"],
  }

  file { 
    "postgresql-server-config-$version":
      name    => "/etc/postgresql/$version/main/postgresql.conf",
      ensure  => present,
      content => template("${path_pgconf}/postgresql.conf"),
      owner   => 'postgres',
      group   => 'postgres',
      mode    => '0644',
      require => Package["postgresql-server-dev-$version"],
      notify  => Service["postgresql-system-$version"];

    "postgresql-authentication-config-$version":
      name    => "/etc/postgresql/$version/main/pg_hba.conf",
      ensure  => present,
      content => template("${path_pgconf}/pg_hba.conf"),
      owner   => 'postgres',
      group   => 'postgres',
      mode    => '0644',
      require => Package["postgresql-server-dev-$version"],
      notify  => Service["postgresql-system-$version"];
  }

}
