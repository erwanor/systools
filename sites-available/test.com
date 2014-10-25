<VirtualHost *:80>
	ServerName test.com
	
  ServerAdmin ad@localhost
	DocumentRoot /home/ad/tools/vhostgen/sites-available/

	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /home/ad/tools/vhostgen/sites-available/ >
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory "/usr/lib/cgi-bin">
		AllowOverride None
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
