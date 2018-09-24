# Ansible playbooks to deploy and maintain MKS infrastructure

Automatically deploy and maintain MKS servers using a set of roles and server groups.

Supported platforms are:
- CentOS 7

## Basic use with the test environment

By default the playbook will automatically create its own testing environment using a Terraform project (embedded in the playbook) and will dynamically create the inventory file using the new servers just created.

This testing environment is described in [./roles/terraform/files/aws.tf](./roles/terraform/files/aws.tf). Note that the AWS credentials will be fetched from the Vault server so you will need to export a valid Vault Token (more on that later).
If you do not want to let Ansible and Terraform create a testing infrastructure and rather want to use existing servers, you should manually fill out the inventory file.

Some of the configuration needed for the playbooks is obtained via Consul.
So the first thing to do will be to run a local Consul agent within the MKS Consul cluster.

### 1/ Start the Consul agent

Default variables are documenting that the Consul agent is available at **http://localhost:8500**

See all URLs in *all.yml* file.
`cat ./environments/test/group_vars/all.yml`
```
...
vault_config_url: http://localhost:8500/v1/kv/config/vault/test
openvpn_config_url: http://localhost:8500/v1/kv/config/openvpn
nexus_config_url: http://localhost:8500/v1/kv/config/nexus
...
```

So run the Consul agent on this URL.
Make sure to export the address of the main Consul server beforehand.
**Ask MKS technical team to prodide you with this address**
```
export CONSUL_SERVER_ADDR=***.***.***.***
```

Now run the Consul agent locally:
```
docker run --rm --net=host --label type=prod --name consul-ui -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul:1.2.2 agent -join=$CONSUL_SERVER_ADDR -bind='{{ GetInterfaceIP "tun0"}}' -ui
```

This assumes that you access to the Consul cluster via the network interface **tun0**.

### 2/ Fill out the inventory file (Optional, not needed if using Terraform project):

Retrieve an empty inventory file from the Consul configuration service:
```
export ansible_envtype="test"
```
```
curl -s "http://localhost:8500/v1/kv/config/mks-playbooks/inventory/$ansible_envtype" | jq .[0].Value | tr -d '"' | base64 --decode >  ./environments/$ansible_envtype/hosts.inventory
```

Edit the *./environments/test/hosts.inventory* inventory file just created and set the servers in the group you would like to setup. For instance, to configure a new OpenMRS CD server, add your server in the 'openmrs_cd_host' group:

`nano ./environments/test/hosts.inventory`
```
[docker_host]

[openmrs_cd_host]
52.17.126.111 ansible_user=centos common_name=openmrscd.vpn.mekomsolutions.net
```
The IP address is the address of the server to configure.
The variables next to each host IP depend on the host group they are in. But at a minimum you will need:
- ansible_user
- common_name
- domain
- subdomain

Note that this only if you are using inventory files. If using Terraform and therefore not putting any host in the inventory file, then those vars are inherited from the terraform definition file directly (through AWS Tags). See [./roles/terraform/files/aws.tf](./roles/terraform/files/aws.tf)

### 3/ Retrieve a Vault token (Optional, based on the host group used or if you are using Terraform)

Some host groups will require to login to Vault (to fetch TLS certifactes or application passwords...) and therefore need to first obtain AppRole credentials from the Vault server. To do so, you need to initially provide a valid Vault token that has access to the AppRole auth backend and the appropriate AppRole role, such as set in the group vars (for instance in [openmrs_cd_host.yml#L2](https://github.com/mekomsolutions/mks-playbooks/blob/01de81fcd111208f572e9f0861a7802c2295fcd4/environments/test/group_vars/openmrs_cd_host.yml#L2) *vault_role: openmrs_cd*)

So with whatever login method suits to your case (Userpass or GitHub), login in Vault, retrieve your token and export it as VAULT_TOKEN envvar.

### 4/ Run the playbook

```
git clone https://github.com/mekomsolutions/mks-playbooks
cd mks-playbooks
```

#### Case 1, let Ansible + Terraform create the testing infrastructure
```
ansible-playbook playbook.yml --extra-vars "vault_token=$VAULT_TOKEN"
```
Note that at the end of the playbook, if successful, the testing infrastructure just created will be destroyed.
If you want to keep it running, add `--skip-tags "destroy_servers"`
```
ansible-playbook playbook.yml --extra-vars "vault_token=$VAULT_TOKEN" --skip-tags "destroy_servers"
```

#### Case 2, Use a manually created inventory file
```
ansible-playbook playbook.yml --extra-vars "vault_token=$VAULT_TOKEN" --skip-tags "terraform"
```

If you are running production environment, add `-i ./environments/prod/hosts.inventory` to point the production inventory file.