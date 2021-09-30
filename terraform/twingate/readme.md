# Intro 👋

More and more companies are providing ways to automate via code the creation and management of infrastructure and applications. Terraform is probably the most recognised tool for writing and managing IaC (Infrastructure as Code) and this guide gives you a basic introduction of how it can be used for deploying applications and infrastructure.

The purpose of this guide is to deloy via Terraform:

* A new cluster on [Civo Kubernetes](https://www.civo.com/?ref=c51daf)
* A basic [Ghost](https://ghost.org) application on Kubernetes
* A new [Twingate](https://www.twingate.com) network, connector and resource 

## Tools 🛠

During this guide I will be using the following:

* [kubectl](https://kubernetes.io/docs/tasks/tools/) (Kubernetes management)
* [vscode](https://code.visualstudio.com/download) (IDE)
* [Terraform](https://www.terraform.io) (IaC)
* [Helm](https://helm.sh/docs/) ([Terraform provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs))
* [Civo API (Terraform provider)](https://registry.terraform.io/providers/civo/civo/latest/docs)
* [Twingate API (Terrform provider)](https://registry.terraform.io/providers/Twingate/twingate/latest/docs)
* [GIT](https://git-scm.com) (version control)
* [Twingate client](https://www.twingate.com/download/)

## The End Result 😎
The end result will give us private access via Twingate to the new Ghost service running inside Kuberenetes. All this will be provisioned as code with no manual or GUI interations required.

## Setup 💪

Before we start make sure the following is setup:

* ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/) installed  
* ✅ [vscode](https://code.visualstudio.com/download) installed 
* ✅ [Terraform](https://www.terraform.io) installed 
* ✅ [Civo Kubernetes](https://www.civo.com/?ref=c51daf) account 
* ✅ [Twingate enterprise](http://twingate.go2cloud.org/aff_c?offer_id=1&aff_id=1006) account 
* ✅ [GIT](https://git-scm.com) installed
* ✅ [Twingate client](https://www.twingate.com/download/) installed

## Getting Started 🏁

Let's start by cloning the following repo, open terminal and type:

```
git clone https://github.com/keithhubner/civo-guides.git
```

Next we need to create the ignore directory and also the tfvars file:

```
cd civo-guides/terraform/twingate/
mkdir ignore
touch terraform.tfvars
```

Then we can open this folder in vscode to edit:

```
code .
```

### API keys 🔑
Next we need both our Civo and Twingate API keys:

Civo

![Screenshot-2021-09-29-at-21.00.57](http://www.keithhubner.com/content/images/2021/09/Screenshot-2021-09-29-at-21.00.57.png)

Twingate

![Screenshot-2021-09-29-at-21.02.23](http://www.keithhubner.com/content/images/2021/09/Screenshot-2021-09-29-at-21.02.23.png)

### Updating tfvars ⚙️
Once you have these values, update your terraform.tfvars file with the following, populating the tokens.

```
civo_token=""

twingate_token=""
```

There are two other values which we will need to include in this file:

```
network=""

groupID=""
```

The network value is the name of your Twingate network, this is normally the something before .twingate.com. You can find this via the Twingate GUI.

The groupID value is a bit more tricky to find as it is only available via the API. To get this value we can run the following cURL command, substituting the url for your own and the API key copied above:

```
curl 'https://changeme.twingate.com/api/graphql/' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H 'x-api-key: YOUR_API_KEY' \
  --data-raw '{"query":"query{groups{edges{node{id,name}}}}","variables":{},"operationName":null}'
```

You can then populate the groupID value with the relevant group from Twingate, this is the group you want to allow access to this resource.

### Deploying our code 😬

First we need to initialise Terraform:

```
terraform init
```

This should go off and install the relevant providers:

```
keithhubner@MacBook-Pro twingate % terraform init

Initializing the backend...

Initializing provider plugins...
- Finding civo/civo versions matching "0.10.11"...
- Finding twingate/twingate versions matching "0.1.5"...
- Finding hashicorp/helm versions matching "2.3.0"...
- Finding latest version of hashicorp/local...
- Installing hashicorp/helm v2.3.0...
- Installed hashicorp/helm v2.3.0 (signed by HashiCorp)
- Installing hashicorp/local v2.1.0...
- Installed hashicorp/local v2.1.0 (signed by HashiCorp)
- Installing civo/civo v0.10.11...
- Installed civo/civo v0.10.11 (signed by a HashiCorp partner, key ID CA1DE390990EBE66)
- Installing twingate/twingate v0.1.5...
- Installed twingate/twingate v0.1.5 (self-signed, key ID E8EBBE80BA0C9369)
```

Next we can do a Terraform plan to check the plan will execute properly:

```
terraform plan
```

All being well you should see the plan complete and return the following:

```
Plan: 7 to add, 0 to change, 0 to destroy.
```

Then we can do the apply:

```
terraform apply
```

This will go off and actually build out the infrastructure, deploy the Ghost app and Twingate connector.

Once this completes you should see:

```
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

We can then use kubectl to check the progress of our deployments:

```
kubectl --kubeconfig ignore/civo.conf get pods -A
```

Hopefully in a few minutes you will see the following:

```
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   helm-install-traefik-5fwmk                0/1     Completed   0          2m9s
kube-system   local-path-provisioner-7c458769fb-9shf9   1/1     Running     0          2m9s
default       connector-96cdb6859-dbfmv                 1/1     Running     0          2m4s
kube-system   metrics-server-86cbb8457f-zd6f9           1/1     Running     0          2m9s
kube-system   traefik-6f9cbd9bd4-t8x2k                  1/1     Running     0          115s
kube-system   civo-csi-node-92kln                       2/2     Running     0          2m9s
kube-system   civo-csi-node-rdwlz                       2/2     Running     0          117s
kube-system   coredns-854c77959c-hwrnb                  1/1     Running     0          2m9s
kube-system   svclb-traefik-pmqmg                       2/2     Running     0          115s
kube-system   svclb-traefik-qwhdg                       2/2     Running     0          115s
kube-system   svclb-traefik-sjhn5                       2/2     Running     0          115s
kube-system   civo-csi-node-77x9t                       2/2     Running     0          2m9s
kube-system   civo-csi-controller-0                     3/3     Running     0          2m9s
ghost         ghost-blog-6d7dcf4d96-4n7z2               1/1     Running     0          115s
```

### Accessing Ghost 🤞
If everything is running we can then test the connection to Ghost via the Twingate app:

![Screenshot-2021-09-30-at-10.39.17](http://www.keithhubner.com/content/images/2021/09/Screenshot-2021-09-30-at-10.39.17.png)

You should then see the Ghost default install page in your browser:

![Screenshot-2021-09-30-at-10.40.18](http://www.keithhubner.com/content/images/2021/09/Screenshot-2021-09-30-at-10.40.18.png)

If you want to remove everything we have just created, you can run the terraform destroy command:

```
terraform destroy 
```

This will confirm what you are about to do, i.e. delete everything!

```
Plan: 0 to add, 0 to change, 7 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.
```

Once you type yes, everything we just provisioned will be destroyed.

```
Destroy complete! Resources: 7 destroyed.
```

That's all for now! I hope you found this guide useful, if you have any comments, questions, feedback or just want to say hi then please contact me via [twitter](https://twitter.com/keithhubner).

Thanks! 👋