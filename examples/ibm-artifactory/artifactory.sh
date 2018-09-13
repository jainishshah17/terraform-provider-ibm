#!/bin/bash -v

export DEBIAN_FRONTEND=noninteractive

# install the wget and curl
apt-get update
apt-get -y install wget curl>> /tmp/install_curl.log 2>&1

apt-get update -y
apt-get install -y software-properties-common curl > /tmp/install.log

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer>> /tmp/install_java8.log 2>&1
apt-get install oracle-java8-set-default

#Generate Self-Signed Cert
mkdir -p /etc/pki/tls/private/ /etc/pki/tls/certs/
openssl req -nodes -x509 -newkey rsa:4096 -keyout /etc/pki/tls/private/example.key -out /etc/pki/tls/certs/example.pem -days 356 -subj "/C=US/ST=California/L=SantaClara/O=IT/CN=*.localhost"

# Install Artifactory
echo "deb https://jfrog.bintray.com/artifactory-pro-debs xenial main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update -y
apt-get -y install nginx>> /tmp/install_nginx.log 2>&1
apt-get install -y jfrog-artifactory-pro > /tmp/install_artifactory.log

#Install database drivers
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.38.jar https://bintray.com/artifact/download/bintray/jcenter/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mssql-jdbc-6.2.1.jre8.jar https://bintray.com/artifact/download/bintray/jcenter/com/microsoft/sqlserver/mssql-jdbc/6.2.1.jre8/mssql-jdbc-6.2.1.jre8.jar
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/postgresql-9.4.1212.jar https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

#Configuring nginx
rm /etc/nginx/sites-enabled/default

cat <<EOF >/etc/nginx/nginx.conf
  #user  nobody;
  worker_processes  1;
  error_log  /var/log/nginx/error.log  info;
  #pid        logs/nginx.pid;
  events {
    worker_connections  1024;
  }
  http {
    include       mime.types;
    variables_hash_max_size 1024;
    variables_hash_bucket_size 64;
    server_names_hash_max_size 4096;
    server_names_hash_bucket_size 128;
    types_hash_max_size 2048;
    types_hash_bucket_size 64;
    proxy_read_timeout 2400s;
    client_header_timeout 2400s;
    client_body_timeout 2400s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 2400s;
    proxy_buffer_size 32k;
    proxy_buffers 40 32k;
    proxy_busy_buffers_size 64k;
    proxy_temp_file_write_size 250m;
    proxy_http_version 1.1;
    client_body_buffer_size 128k;
    include    /etc/nginx/conf.d/*.conf;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    }
EOF

cat <<EOF >/etc/nginx/conf.d/artifactory.conf
      ssl_certificate      /etc/pki/tls/certs/example.pem;
      ssl_certificate_key  /etc/pki/tls/private/example.key;
      ssl_session_cache shared:SSL:1m;
      ssl_prefer_server_ciphers   on;
      ## server configuration
      server {
        listen 443 ssl;
        listen 80 ;
        server_name ~(?<repo>.+)\.artifactory artifactory;
        if ($http_x_forwarded_proto = '') {
          set $http_x_forwarded_proto  $scheme;
        }
        ## Application specific logs
        ## access_log /var/log/nginx/artifactory-access.log timing;
        ## error_log /var/log/nginx/artifactory-error.log;
        rewrite ^/$ /artifactory/webapp/ redirect;
        rewrite ^/artifactory/?(/webapp)?$ /artifactory/webapp/ redirect;
        rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/$repo/$1/$2;
        chunked_transfer_encoding on;
        client_max_body_size 0;
        location /artifactory/ {
          proxy_read_timeout  2400;
          proxy_pass_header   Server;
          proxy_cookie_path   ~*^/.* /;
          proxy_pass          http://127.0.0.1:8081/artifactory/;
          proxy_set_header    X-Artifactory-Override-Base-Url
          $http_x_forwarded_proto://$host:$server_port/artifactory;
          proxy_set_header    X-Forwarded-Port  $server_port;
          proxy_set_header    X-Forwarded-Proto $http_x_forwarded_proto;
          proxy_set_header    Host              $http_host;
          proxy_set_header    X-Forwarded-For   $proxy_add_x_forwarded_for;
         }
      }
EOF

cat <<EOF >/var/opt/jfrog/artifactory/etc/ha-node.properties
  node.id=art1
  artifactory.ha.data.dir=/var/opt/jfrog/artifactory/data
  context.url=http://127.0.0.1:8081/artifactory
  membership.port=10001
  hazelcast.interface=172.25.0.3
  primary=true
EOF

mkdir -p /var/opt/jfrog/artifactory/etc/security

HOSTNAME=$(hostname)
sed -i -e "s/art1/art-$(date +%s$RANDOM)/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/127.0.0.1/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties
sed -i -e "s/172.25.0.3/$HOSTNAME/" /var/opt/jfrog/artifactory/etc/ha-node.properties

cat /etc/pki/tls/certs/result.pem | sed 's/CERTIFICATE----- /CERTIFICATE-----\n/g' | sed 's/-----END/\n-----END/' > temp.pem
mv -f temp.pem /etc/pki/tls/certs/cert.pem
cat /etc/pki/tls/private/result.key | sed 's/KEY----- /KEY-----\n/g' | sed 's/-----END/\n-----END/'  > temp.key
mv -f temp.key /etc/pki/tls/private/cert.key
echo "artifactory.ping.allowUnauthenticated=true" >> /var/opt/jfrog/artifactory/etc/artifactory.system.properties
chown artifactory:artifactory -R /var/opt/jfrog/  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/*

# start Artifactory
sleep $((RANDOM % 120))
service artifactory start
service nginx start
nginx -s reload
echo "INFO: Artifactory installation completed."