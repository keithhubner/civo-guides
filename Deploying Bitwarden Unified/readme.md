
> gitignore file


### Setup civo cli

Adding API key

Setting key to current

## Terraform

tfvars file api key

main.tf

> The kubeconfig should automatically be saved and merged

Switch to the context

```
kubectx CLUSTER_NAME
```

### Create Namespace

```
kubectl create ns bitwarden
```

## Creating the database

> Need to create via the CLI at the moment until terraform provider update.

> Check you are in the same region as the cluster

```
civo database create bitwarden --size g3.db.xsmall --firewall demo-firewall-db

```

Wait until the db is created:

```
civo db ls
```

Get the connection information:

```
civo db credentials bitwarden
```

> You may want to create a spoecific bitwarden mysql user and give it permissions to only the bitwarden db

Creating the db connection secret

Create the secrets for db conneciton, key and ID
```
kubectl create secret generic bitwarden \
    --from-literal=connstring='server=[db_server_ip];port=3306;database=bitwarden;user=root;password=[your_password]' \
    --from-literal=installationID='[your_installation_KEY]]' \
    --from-literal=installationKEY='[your_installation_key]' -n bitwarden
```

Create the config map:

```
kubectl apply -f configmap_bitwarden.yaml
```

Apply the deployment:

```
kubectl apply -f deployment_bitwarden.yaml
```

Connect to via proxy forward to test:

```
kubectl port-forward svc/bitwarden 8080:80
```

You should see the bitwarden login page where you can create an account

