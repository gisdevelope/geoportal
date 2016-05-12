# Passenger install procedure
Passenger is installed as a Ruby gem, which builds an Apache module.

```shell
# 1. Install the gem for the specific Ruby version in rbenv (--no-rdoc, --no-ri skip installing docs)
$ RBENV_VERSION=2.3.0 gem install passenger --no-rdoc --no-ri

# 2. Build the apache module (select only Ruby)
$ passenger-install-apache2-module
```

## Enable Passenger in Apache config:

### Basic setup
```
#####
# /swadm/etc/httpd/conf.d/00-passenger.conf
# In its own file to control load order and make it easier to find when ruby 
versions change...
#####

LoadModule passenger_module /swadm/usr/local/rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/passenger-5.0.28/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /swadm/usr/local/rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/passenger-5.0.28
  PassengerDefaultRuby /swadm/usr/local/rbenv/versions/2.3.0/bin/ruby
</IfModule>
```

### Note about versions
If the Passenger rubygem is updated, its version number will change, and must 
correspondingly be changed where referenced in the Apache config. For example, 
`passenger-5.0.28`. It is necessary to build a new Apache module when the gem is 
updated, by again invoking `passenger-install-apache2-module`. Make sure the 
Apache conf references the correct module version.


It is possible to have OIT install Passenger via RPM, but the RHEL 6 supported 
version is very old.

Likewise, if a newer Ruby version is installed, rbenv Ruby paths will need to be 
updated from `2.3.0`.

## VirtualHost config
```
######
# /swadm/etc/httpd/conf.d/geoblacklight{dev}.conf
######
<VirtualHost ...>

  # Document root must point to public directory
  DocumentRoot /swadm/usr/local/geoblacklight/public

  <Directory "/swadm/usr/local/geoblacklight">
      # Locate application, passenger will autodetect Rails
      PassengerAppRoot "/swadm/usr/local/geoblacklight"

      # Path we'll expose to the web
      PassengerBaseURI /
      
      # Make sure it's in development mode (default is production)
      PassengerAppEnv "development"

      # .. rest of normal Apache conf stuff..
  </Directory>

  # mod_proxy is used to expose and lock down /solr paths on port 8983
  # with HTTP basic auth
	ProxyRequests Off
	ProxyPreserveHost On
	<Proxy *>
					Order deny,allow
					Allow from all
	</Proxy>

	ProxyPass /solr http://localhost:8983/solr
	ProxyPassReverse /solr http://localhost:8983/solr

	<Location /solr>
			# Basic auth required with user solradmin
			AuthType Basic
			AuthName "Authentication Required"
			AuthUserFile "/swadm/etc/htpasswd-geoblacklight-solr"
			Require user solradmin

			Order allow,deny
			Allow from all
	</Location>

</VirtualHost>
```
