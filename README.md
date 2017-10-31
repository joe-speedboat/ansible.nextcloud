joe-speedboat.nextcloud
=================

* install nextcloud on centos 7
* install dependencies: nginx, php, redis, mariadb
* generate ssl cert (self signed) if nextcloud_use_https is true

Requirements
------------

* Currently only tested with CentOS 7

Role Variables
--------------

```
nextcloud_nginx_ssl_cert_host: '{{ nextcloud_fqdn }}'
nextcloud_repo_url: https://download.nextcloud.com/server/releases
nextcloud_version:  nextcloud-12.0.3
nextcloud_fqdn: "{{ansible_fqdn}}"
nextcloud_use_https: true
nextcloud_nginx_ssl_cert_days: 3650
nextcloud_nginx_ssl_cert_dir: /etc/nginx
nextcloud_nginx_ssl_cert_key: "{{nextcloud_nginx_ssl_cert_dir}}/{{nextcloud_fqdn}}_key.pem"
nextcloud_nginx_ssl_cert_crt: "{{nextcloud_nginx_ssl_cert_dir}}/{{nextcloud_fqdn}}_crt.pem"
nextcloud_nginx_ssl_cert_ca_chain: "{{nextcloud_nginx_ssl_cert_dir}}/{{nextcloud_fqdn}}_ca.pem"
nextcloud_trusted_domains: ['localhost', '{{ nextcloud_fqdn }}']
nextcloud_webroot: /srv/nextcloud/html
nextcloud_dataroot: /srv/nextcloud/data
nextcloud_cert_store: "{{nextcloud_webroot}}/resources/config/ca-bundle.crt"
nextcloud_admin_user: admin
nextcloud_admin_pw: 'krypt0n!'
nextcloud_max_upload_size: 16G
nextcloud_max_upload_time: 3600

nextcloud_mysql_db: nextcloud
nextcloud_mysql_root_password: '.R00T.'
nextcloud_mysql_db_password: 'krypt0n.'

```


example playbooks for this role are located in `test` folder:
--------------
* `install_nextcloud.yml`: Role for testing


License
--------------
https://opensource.org/licenses/LGPL-3.0    
Copyright (c) Chris Ruettimann <chris@bitbull.ch>  

