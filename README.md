# kampos
Quickly spin up a Vultr VPS running Seafile stack and nginx dockerized - uses terraform and ansible

Note: this is intended for short term use - (that being said) please adjust firewall settings and username/password settings to harden the instance & tear down when intended use case is complete.

Note: This script works on debian distros only at this point (planned feature)

Features:
- Ubuntu 16.04 Server base image
- Ephemeral Seafile, MariaDB & memcached containers via docker
- Ephemeral Nginx container via docker (official nginx container)
  - listens on 80 (443 - WIP to come with auto-cert/dns provisioning)
- Terraform provisioning of Vultr VM and associated resources
- Ansible configuration of VM:
    - nginx reverse proxy
    - seafile, mariadb & memcached via containers
    - persistant seafile and mariadb storage
- Automated installation of required provisioning tools
- Configuration of Vultr firewall rules - ports 80,8000,8082
- Supports customization of hostname/label
- Designed with simplicy and quick functionality in mind


Prereqs:
- Valid Vultr subscription
- Vultr API key

To Deploy:
- Clone image: `git clone https://github.com/66gmc1000/kampos.git`
- Switch to the repo root directory: `cd kampos`
- Execute `./deploy-kampos.sh` with required parameters:

`./deploy-kampos.sh --apikey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --hostname=MyCustomHostname`

- Visit http://IPADDRESS to verify your newly deployed instance

To Destroy:
- Switch to the repo root directory: `cd kampos`
- Execute `./destroy-kampos.sh` with required parameters:

`./destroy-kampos.sh --apikey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`


Defaults (can be edited via ansible/roles/deploy/tasks/main.yml):
