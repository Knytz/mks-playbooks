# Ansible playbooks to deploy and maintain MKS infrastructure

Automatically deploy and maintain MKS servers using a set of roles and server groups.

Supported platforms are:
- CentOS 7

## Basic use with the test environment
```
git clone https://github.com/mekomsolutions/mks-playbooks
cd mks-playbooks
```
### 1/ Edit the inventory file
Edit the *hosts* inventory file and set the servers you wish to configure in the group you would like to apply. For instance, to configure a new OpenMRS CD server, add your server in the 'openmrs_cd_host' group:

`nano ./environments/test/hosts.inventory`
```
[docker_host]

[openmrs_cd_host]
52.17.126.111 ansible_user=centos common_name=openmrscd.vpn.mekomsolutions.net

[laptop]

[bahmni_prod]

```
The IP address is the address of the server to configure.
The variables next to each host IP depend on the host group they are in. They are listed in the corresponding *group_vars* folder. For instance, for *openmrs_cd_host* group:

`cat ./environments/test/group_vars/openmrs_cd_host.yml`
```
...
# Default variables that should be overriden in the inventory file, by server:
ansible_user: centos
common_name: test.vpn.mekomsolutions.net
...
```

### 2/ Start the Consul server

The very first task that Ansible will run is fetch various configurations from a configuration service such as Consul.
The URLs are set in the *all.yml* file.

`cat ./environments/test/group_vars/all.yml`
```
...
vault_config_url: http://localhost:8500/v1/kv/config/vault/test
openvpn_config_url: http://localhost:8500/v1/kv/config/openvpn
nexus_config_url: http://localhost:8500/v1/kv/config/nexus
...
```

In this case the config service (Consul) is documented to be available at localhost:8500. Therefore you need to make sure you are running a Consul agent locally (as part of the Consul cluster):
Make sure to export the address of the main Consul server beforehand: CONSUL_SERVER_ADDR.

*Ask MKS technical team to prodide you with this address*

```
export CONSUL_SERVER_ADDR=***.***.***.***
```

Run the Consul agent locally:
```
docker run --rm --net=host --label type=prod --name consul-ui -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul:1.2.2 agent -join=$CONSUL_SERVER_ADDR -bind='{{ GetInterfaceIP "tun0"}}' -ui
```

### 3/ Retrieve a Vault token (Optional, based on the host group used)

Some host groups will require to login to Vault, and therefore have to optain some AppRole credentials from the Vault server. To do so, you need to initially provide a valid Vault token that has access to the AppRole auth backend and the appropriate AppRole role, such as set in the group vars (for instance in [openmrs_cd_host.yml#L2](https://github.com/mekomsolutions/mks-playbooks/blob/01de81fcd111208f572e9f0861a7802c2295fcd4/environments/test/group_vars/openmrs_cd_host.yml#L2) *vault_role: openmrs_cd*)

So with whatever login method suits to your case (Userpass or GitHub), login in Vault,  retrieve your token and export it as VAULT_TOKEN envvar.

### 4/ Fetch the inventory

Inventory files are not stored in this repo (they are gitignored) but are available through the Consul service. Fetch the inventory file based on your environment:

```
envtype="test"; curl -s "http://localhost:8500/v1/kv/config/mks-playbooks/inventory/$envtype" | jq .[0].Value | tr -d '"' | base64 --decode >  ./environments/$envtype/hosts.inventory
```

*If you are running the test environment, verify that the servers IP address in the inventory file are correct. Since the testing environment is using dynamic IPs, you may need to update them*
*If your are running in a production environment, change 'envtype' to 'prod'*

### 5/ Run the playbook
Once you have set your target servers (1), started Consul (2), exported your Vault token (3) in your terminal and fetched the inventory (4), you can run the playbooks using the command:
```
ansible-playbooks playbook.yml --extra-vars "vault_token=$VAULT_TOKEN"
```

If you are running production environment, add `-i ./environments/prod/hosts.inventory`.
