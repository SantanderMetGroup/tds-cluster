# SantanderMetGroup Data Services

## Local testing

- You need to fill your secrets.yml file (secrets.yml.dummy is provided as template)
- If catalogs.yml reports unauthorized you should copy the database to the database server (e.g. lxc file push -r tap $CONTAINER/root/services/tds-cluster/derbydb). Note that first you have to obtain the tap folder, which contains the database
- The udg-tap.war installed is builded from the latest commit of the svn repo

```bash
lxdock up
ansible-playbook esgf-ansible/install.yml install.yml esgf-ansible/stop.yml esgf-ansible/start.yml start.yml catalogs.yml
```

## Update catalogs and datasets

**Note the `-i` flag:** This runs the playbook against data.meteo.unican.es/thredds.

```bash
ansible-playbook catalogs.yml -i inventories/prod
```

## Adding new development TDSs

First, add the modproxy load balancer to the `clusters` variable in `install.yml`:

```
clusters:
  - name: NAME
    urls:
      - /thredds/catalog/devel/PATH
      - /thredds/dodsC/devel/PATH
      - ...
```

Then, declare a `tomcat` variable for the `devel` role and execute it in the hosts you wish:

```
- name: TDS devel deployment example
  hosts: HOST
  tags: devels
  roles:
    - role: devel
      tomcat:
        jdk: JDK_PATH
        home: TOMCAT_HOME
        http: 0000 # http port
        ajp: 0001 # ajp port
        shutdown: 0002 # shutdown port
        gateway: ANSIBLE_HOST # ansible host (as defined in inventory) of the gateway
        cluster: NAME # refers to cluster NAME, see above
        host: "{{ ansible_all_ipv4_addresses[0] }}" # choose an appropiate value
        properties: loadfactor=1 route={{ ansible_hostname }} # choose appropiates values
```

Examples can be found in the `inventories/group_vars` directory and in the `devels` directory.

Run the playbook

```
ansible-playbook $PLAYBOOK
# to update all workers you have to include all playbooks
ansible-playbook install.yml devels/*.yml --tags update-workers
```

Finally, to set up development TDS catalogs and datasets, just access the directory where you have deployed the new TDS and clone the appropiate branch of [tds-content](https://gitlab.com/scds/tds-content).

```
cd $TOMCAT_HOME/content/thredds
git init .
git remote add origin $URL # https://gitlab.com/scds/tds-content or git@gitlab.com:scds/tds-content.git
git fetch
```

Now start the TDS using `$TOMCAT_HOME/bin/startup.sh` and start making changes to catalogs and datasets.
