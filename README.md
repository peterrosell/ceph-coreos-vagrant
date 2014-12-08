

A new cluster always needs a unique discovery-url. You can't reuse it so if you destroy the cluster and recreates it you must generate a new url by running the command again. It must be added to a config file that is provided to CoreOS. It can easily be created by running this command:

``` bash
make discovery-url
```

To start the cluster, at the moment just one server. Run the following command:

``` bash
vagrant up
```

Ceph's different services are installed and managed with fleetctl. To generate the service files from template run the command:

``` bash
make services-from-templates
```

Before you can start the services you need to register ssh key and set two environment variables. The command below registers the ssh key and shows the environment variables to set. Just copy and paste the exports to the command line to set them.

``` bash
make dev-environment
```

##Trobleshoting
If fleetctl complains about bad ssh keys they can be removed with this command.
``` bash
ssh-keygen -f "~/.fleectl/known_hosts" -R "[127.0.0.1]:2222"
```
Or just delete the ```known_hosts``` file
``` bash
rm ~/.fleetctl/known_hosts
```
