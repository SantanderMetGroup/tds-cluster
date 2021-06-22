# jupyterhub in ui

Configure `inventory`.

`ansible-playbook main.yml`

In ui:

```bash
source ${HOME}/jupyterhub/miniconda2/bin/activate jupyterhub
jupyterhub -f ${HOME}/jupyterhub/jupyterhub_config.py
```

Go to `http://193.144.184.31:8000` and log in with your ui user.
