# SantanderMetGroup Data Services

## Local testing

- To copy an already populated database to the database server (e.g. lxc file push -r tap $CONTAINER/root/services/tds-cluster/derbydb).
- The udg-tap.war installed is builded from the latest commit of the svn repo.
- You need to fill your secrets.yml file.

```
tds:
  user:
  password:

derby:
  name:
  user:
  password:
  url:

tap:
  verificationurl:
  privatekey:
  publickey:
  noreply:
  emails:

svn:
  username:
  password:

# password for esgf
admin_pass:
admin_pass_digest:
```

To test the deployment using lxdock (requires lxc):

```bash
lxdock up
ansible-playbook backends.yml gateway.yml
```

## Add a new load balancer

Add the load balancer to `templates/modproxy.conf.j2`.

## Adding new tomcats

Create the tomcat variable and execute the role `udg` passing the tomcat variable:

```yaml
- name: Minimal demo of how to install a tomcat and add it to a modproxy load balancer
  hosts: localhost
  vars:
    a_tomcat_for_testing:
      home: sandbox
      http: 8080
      ssl: 8443
      ajp: 8009
      shutdown: 8005
    derby:
      name: ""
      user: ""
      password: ""
      url: ""
    tap:
      verificationurl: ""
      privatekey: ""
      publickey: ""
      noreply: ""
      emails: ""
  roles:
    - role: udg
      tomcat: "{{ a_tomcat_for_testing }}"
#  tasks:
#    - name: Add tomcat to a load balancer if it exists
#      lineinfile:
#        path: /etc/httpd/conf.d/modproxy.conf
#        insertafter: <Proxy "balancer://balancer_name">
#        line: BalancerMember "ajp://{{ ansible_all_ipv4_addresses[0] }}:{{ a_tomcat_for_testing.ajp }}" loadfactor=1 route={{ ansible_hostname }}
#      delegate_to: balancer_host
```

# Additional notes

## Install httpd from source

```
wget -qc https://ftp.cixug.es/apache//httpd/httpd-2.4.46.tar.gz -O httpd.tar.gz
wget -qc https://ftp.cixug.es/apache/apr/apr-1.7.0.tar.gz -O apr.tar.gz
wget -qc https://ftp.cixug.es/apache/apr/apr-util-1.6.1.tar.gz -O apr-util.tar.gz
wget -qc https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -O pcre.tar.gz
wget -qc https://github.com/maxmind/geoip-api-mod_geoip2/archive/refs/tags/1.2.10.tar.gz -O mod-geoip.tar.gz

mkdir -p apr apr-util pcre httpd mod-geoip
tar -xf apr.tar.gz -C apr --strip-components=1
tar -xf apr-util.tar.gz -C apr-util --strip-components=1
tar -xf pcre.tar.gz -C pcre --strip-components=1
tar -xf httpd.tar.gz -C httpd --strip-components=1
tar -xf mod-geoip.tar.gz -C mod-geoip --strip-components=1

# build
cd apr
./configure
make
make install

cd ../apr-util
./configure --with-apr=../apr
make
make install

cd ../pcre
./configure
make
make install

cd ../httpd
./configure
make
make install

cd ../mod_geoip
apxs -i -a -L/usr/local/lib -I/usr/local/include -lGeoIP -c mod_geoip.c
```

## ESGF installation from single playbook

This is just a test I used to create my own roles for ESGF:

esgfvars.yml

```
hostname:
  self: "{{ ansible_fqdn }}" # This will be the output of `hostname -f` and may not be the correct hostname to use
  idp: "{{ groups['idp'][0] }}"
  index: "{{ groups['index'][0] }}"

# OS Info
is_7: "{{ (ansible_distribution_major_version == '7') | bool }}"
is_6: "{{ (ansible_distribution_major_version == '6') | bool }}"
httpd_version: "{{ '2.4' if (is_7) else '2.2' }}"

# ESGF Info
versions:
  installer: 4.0.0-alpha1
  java: jdk1.8.0_192
  search: v4.17.10
  stats_api: v1.0.9
  node_manager: v1.0.5
  node_manager_db: 0.1.7
  orp: v2.11.0
  security: v2.8.11
  security_db: 0.1.7
  idp: v2.8.8

assets:
  base: https://github.com/ESGF/esgf-ansible/releases/download/{{ versions.installer }}
  search: https://github.com/ESGF/esg-search/releases/download/{{ versions.search }}
  stats_api: https://github.com/ESGF/esgf-stats-api/releases/download/{{ versions.stats_api }}
  node_manager: https://github.com/ESGF/esgf-node-manager/releases/download/{{ versions.node_manager }}
  orp: https://github.com/ESGF/esg-orp/releases/download/{{ versions.orp }}
  security: https://github.com/ESGF/esgf-security/releases/download/{{ versions.security }}
  idp: https://github.com/ESGF/esgf-idp/releases/download/{{ versions.idp }}

mirror_host: aims1.llnl.gov
mirror:
  base: https://{{ mirror_host }}/esgf/dist

esg:
  config:
    repo: https://github.com/ESGF/config.git
    version: master
    dir: "{{ esgf_root }}/config"
  content: "{{ esgf_root }}/content"
  home: "{{ esgf_root }}"
  log: "{{ esgf_root }}/log"

pkgs:
  apache: httpd
  postgres_server: postgresql-server
  postgres_devel: postgresql-devel
  psgycopg2: python-psycopg2

conda_home: "{{ esgf_root }}/conda"
conda:
  prefix: "{{ conda_home }}"
  exe: "{{ conda_home }}/bin/conda"
  actv: source {{ conda_home }}/bin/activate
  envs: "{{ conda_home }}/envs"
  mods: lib/python2.7/site-packages

tomcat:
  src: http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.46/bin/apache-tomcat-8.5.46.tar.gz
  root_dir: apache-tomcat-8.5.46
  path: "{{ tomcats.esgf.home }}"
  webapps: "{{ tomcats.esgf.home }}/webapps"
  ts:
    url: "{{ assets.base }}/esg-truststore.ts"
    path: "{{ esg.config.dir }}/tomcat/esg-truststore.ts"
    pass: changeit
  ks:
    path: "{{ esg.config.dir }}/tomcat/keystore-tomcat"
    pass: changeit
tomcat_ctrl: /usr/local/tomcat/bin/catalina.sh

esgf_rpm:
  baseurl: https://{{ mirror_host }}/esgf/RPM/centos/{{ ansible_distribution_major_version }}/x86_64/

all_db:
  users:
    super:
      name: dbsuper
      pass: "{{ admin_pass }}"
  db: esgcet
  host: localhost
  port: 5432

db_url: '{{ all_db.users.super.name }}:{{ all_db.users.super.pass }}@{{ all_db.host }}:{{ all_db.port }}/{{ all_db.db }}'

schema_migrate:
  env: schema-migrate

properties:
  dest: /esg/config/esgf.properties
  fragments: /tmp/properties_fragments/

httpd:
  trusted_ca:
    url: "{{ assets.base }}/esgf-ca-bundle.crt"
    name: esgf-ca-bundle.crt
  cert_dir: /etc/certs
  cabundle: /etc/certs/esgf-ca-bundle.crt
  hostkey: /etc/certs/hostkey.pem
  hostcert: /etc/certs/hostcert.pem
  cachain: /etc/certs/cachain.pem
  ssl_proxy_dir: /etc/httpd/conf.d/esgf-proxy-ssl
  proxy_dir: /etc/httpd/conf.d/esgf-proxy

orp_webapp:
  url: "{{ assets.orp }}/esg-orp.war"
  name: esg-orp

security:
  egg:
    name: "esgf_security-{{ versions.security_db }}-py2.7.egg"
    url: "{{ assets.security }}/esgf_security-{{ versions.security_db }}-py2.7.egg"
    script: "esgf_security_initialize"

type_bits:
  data: 4
  index: 8
  idp: 16

grid_security:
  dir: /etc/grid-security
  cert_dir: /etc/grid-security/certificates
  host:
    key: /etc/grid-security/hostkey.pem
    cert: /etc/grid-security/hostcert.pem

gridftp:
  port: 2811
  chroot: "{{ esg.home }}/gridftp_root"

filebeat:
  rpm: "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.5.1-x86_64.rpm"
  data_log_path: "/var/log/httpd/country_downloads_log"
  ssl_ca_path: "/etc/filebeat/ca.pem"
  ssl_key_path: "/etc/filebeat/key.pem"
  ssl_cert_path: "/etc/filebeat/cert.pem"
  logstash_host: "ophidialab.cmcc.it:5044"

thredds:
  content: "{{ esg.content }}/thredds"
  tomcat_user:
    name: "dnode_user"
    pass: "{{ admin_pass }}"
    roles: "tdrAdmin,tdsConfig"

thredds_webapp:
  url: "{{ assets.base }}/thredds.war"
  name: thredds

node_manager:
  egg:
    name: "esgf_node_manager-{{ versions.node_manager_db }}-py2.7.egg"
    url: "{{ assets.node_manager }}/esgf_node_manager-{{ versions.node_manager_db }}-py2.7.egg"
    script: esgf_node_manager_initialize

data_db:
  users:
    pub:
      name: esgcet
      pass: "{{ admin_pass }}"
```

Playbook:

```
- name: Install ESGF stuff for SantanderMetGroup
  hosts: esgf
  vars:
    esgf:
      thredds_username: dnode_user
      thredds_restrict_access: esg-user
    esg:
      home: "{{ root }}/esg"
      config: "{{ root }}/esg/config"
      esgcet: "{{ root }}/esg/config/esgcet"
      content: "{{ root }}/esg/content"
    conda:
      home: "{{ root }}/miniconda2"
      exe: "{{ root }}/miniconda2/bin/conda"
      actv: "source {{ root }}/miniconda2/bin/activate"
    db:
      name: esgcet
      host: localhost
      port: 5432
      admin:
        name: dbsuper
        pass: "{{ admin_pass }}"
      user:
        name: esgcet
        pass: "{{ admin_pass }}"
    index:
      host: esgf-node.ipsl.upmc.fr
    gridftp:
      security: /etc/grid-security
      port: 2811
      chroot: "{{ esg.home }}/gridftp_root"
      cert_dir: /etc/grid-security/certificates
      hostcert: /etc/grid-security/hostcert.pem
      hostkey: /etc/grid-security/hostkey.pem
  vars_files:
    - secrets.yml
  tasks:
    # Downloads
    - name: Clone git repos
      run_once: True
      local_action:
        module: git
        repo: "{{ item.repo }}"
        dest: "{{ item.dest }}"
        version: "{{ item.version|default('master') }}"
      with_items:
        - { 'repo': 'https://github.com/ESGF/config.git', 'dest': 'files/esgf/config' }

    # Config
    - name: Create directories
      file: state=directory dest={{ item }}
      with_items:
        - "{{ root }}"
        - "{{ esg.config }}"
        - "{{ esg.esgcet }}"
        - "{{ esg.content }}"
        - "{{ tomcats.esgf.home }}/webapps"

    - name: Copy esgf config files
      synchronize: src=files/esgf/config/esgf-prod/ dest={{ esg.config }}

    - name: Copy /esgf_policies_local.xml
      copy: src=files/esgf/esgf_policies_local.xml dest={{ esg.config }}/esgf_policies_local.xml

    - name: Copy /esgf_policies_common.xml
      copy: src=files/esgf/esgf_policies_common.xml dest={{ esg.config }}/esgf_policies_common.xml

    - name: Template esgf.properties.j2
      template: src=templates/esgf/config/base.properties.j2 dest={{ esg.config }}/esgf.properties

    - name: Template esgf_ats.xml.j2
      template: src=templates/esgf/config/esgf_ats.xml.j2 dest={{ esg.config }}/esgf_ats.xml

    - name: Template esgf_azs.xml.j2
      template: src=templates/esgf/config/esgf_azs.xml.j2 dest={{ esg.config }}/esgf_azs.xml

    - name: Template esgf_idp.xml.j2
      template: src=templates/esgf/config/esgf_idp.xml.j2 dest={{ esg.config }}/esgf_idp.xml

    - name: Copy password
      no_log: true
      copy:
        content: "{{ admin_pass }}"
        dest: "{{ esg.config }}/{{ item }}"
        mode: 0640
      loop:
        - ".esgf_pass"
        - ".esg_keystore_pass"
        - ".esg_pg_pass"
        - ".esg_pg_publisher_pass"

    # Miniconda
    - name: Copy miniconda installer
      copy: src=files/esgf/conda/Miniconda2-latest-Linux-x86_64.sh dest={{ root }}/Miniconda2-latest-Linux-x86_64.sh mode=0755

    - name: Install miniconda
      command: "bash {{ root }}/Miniconda2-latest-Linux-x86_64.sh -b -p {{ conda.home }}"
      args:
        creates: "{{ conda.home }}"

    # Publisher
    - name: Copy esgf-pub conda environment
      copy: src=files/esgf/conda/esgfpub-environment.yml dest={{ root }}/esgfpub-environment.yml

    - name: Create esgf-pub conda environment
      command: "{{ conda.exe }} env create --file {{ root }}/esgfpub-environment.yml -p {{ conda.home }}/envs/esgf-pub"
      args:
        creates: "{{ conda.home }}/envs/esgf-pub"

    - name: Copy .ini
      synchronize: src=files/esgf/config/publisher-configs/ini/ dest={{ esg.esgcet }}

    - name: Override .ini
      synchronize: src=files/esgf/ini/ dest={{ esg.esgcet }}

    - name: Template esg.ini
      template: src=templates/esgf/config/esg.ini.j2 dest={{ esg.esgcet }}/esg.ini

    - name: Copy esgcet_models_table.txt
      copy: src=files/esgf/config/publisher-configs/esgcet_models_table.txt dest={{ esg.esgcet }}/esgcet_models_table.txt

    - name: Run esgsetup for the database
      shell: >
        {{ conda.actv }} esgf-pub && \
        esgsetup --db --minimal-setup \
        --db-name '{{ db.name }}' \
        --db-admin '{{ db.admin.name|quote }}' \
        --db-admin-password '{{ db.admin.pass|quote }}' \
        --db-user '{{ db.user.name|quote }}' \
        --db-user-password '{{ db.user.pass|quote }}' \
        --db-host '{{ db.host|quote }}' \
        --db-port '{{ db.port|quote }}'
      environment:
        UVCDAT_ANONYMOUS_LOG: no
        ESGINI: "{{ esg.esgcet }}/esg.ini"
    
    - name: Run esginitialize
      shell: >
        {{ conda.actv }} esgf-pub && \
        esginitialize -c -i {{ esg.esgcet }}
      environment:
        UVCDAT_ANONYMOUS_LOG: no
        ESGINI: "{{ esg.esgcet }}/esg.ini"
    
    - name: Run esgsetup for thredds
      shell: >
        {{ conda.actv }} esgf-pub && \
        esgsetup --config --minimal-setup \
        --thredds --publish --gateway '{{ index.host|quote }}' \
        --thredds-password '{{ admin_pass }}' \
        --thredds-root '{{ esg.content }}'
      environment:
        UVCDAT_ANONYMOUS_LOG: no
        ESGINI: "{{ esg.esgcet }}/esg.ini"

    # Tomcat
    - name: Unarchive tomcat
      unarchive: src=files/esgf/tomcat/tomcat.zip dest={{ tomcats.esgf.home }}

    - name: Install ESGF server.xml
      template: src=templates/esgf/server.xml.j2 dest={{ tomcats.esgf.home }}/conf/server.xml

    - name: Template tomcat-users.xml
      template: src=templates/esgf/tomcat-users.xml.j2 dest={{ tomcats.esgf.home }}/conf/tomcat-users.xml

    - name: Copy truststore
      copy: src={{ certs }}/esg-truststore.ts dest={{ tomcats.esgf.truststore }} mode=644

    - name: Copy keystore
      copy: src={{ certs }}/esg-keystore.ts dest={{ tomcats.esgf.keystore }} mode=600

    - name: Template ORP security-context-auth.xml.j2
      template: src=templates/esgf/orp/security-context-auth.xml.j2 dest={{ tomcats.esgf.home }}/webapps/esg-orp/WEB-INF/classes/esg/orp/orp/config/security-context-auth.xml

    - name: Template ORP security-context-authz.xml.j2
      template: src=templates/esgf/orp/security-context-authz.xml.j2 dest={{ tomcats.esgf.home }}/webapps/esg-orp/WEB-INF/classes/esg/orp/orp/config/security-context-authz.xml

    - name: Template ORP properties
      template: src=templates/esgf/orp/esg-orp.properties.j2 dest={{ tomcats.esgf.home }}/webapps/esg-orp/WEB-INF/classes/esg-orp.properties

    - name: Disable cookie session in ORP
      lineinfile:
        line: "<session-config><tracking-mode>COOKIE</tracking-mode></session-config>"
        dest: "{{ tomcats.esgf.home }}/webapps/esg-orp/WEB-INF/web.xml"
        insertbefore: "</web-app>"

    - name: Template TDS web.xml
      template: src=templates/esgf/orp/web.xml.j2 dest={{ tomcats.esgf.home }}/webapps/thredds/WEB-INF/web.xml

    - name: Template setenv.sh
      template: src=templates/esgf/setenv.sh.j2 dest={{ tomcats.esgf.home }}/bin/setenv.sh

    - name: Clone tds-content
      run_once: True
      local_action:
        module: git
        repo: git@gitlab.com:SCDS/tds-content.git
        dest: esgf-content
        version: esgf
        depth: 1

    - name: Synchronize esgf-content
      synchronize: src=esgf-content/ dest={{ esg.content }}/thredds
```
