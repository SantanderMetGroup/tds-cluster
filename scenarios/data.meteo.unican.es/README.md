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
