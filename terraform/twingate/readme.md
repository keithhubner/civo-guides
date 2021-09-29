# Intro 👋

More and more companies are providing ways to automate via code the creation and management of infrastructure and applications. Terraform is probably the most recognised tool for writing and managing IaC and therefore this is what I will be using in this guide. 

The purpose of this guide is to deloy via Terraform:

* A new cluster on Civo Kubernetes
* A basic Ghost application on Kubernetes
* A new Twingate network, connector and resource 

## Tools 🛠

During this guide I will be using the following:

* kubectl (Kubernetes management)
* vscode (IDE)
* Terraform (IaC)
* Helm (Terraform provider)
* Civo API (Terraform provider)
* Twingate API (Terrform provider)
* GIT (version control)

## The End Result 😎
The end result will give us private access via Twingate to the new Ghost service running inside Kuberenetes. All this will be provisioned as code with no manual or GUI interations required.

## Setup 💪

Before we start you will need the following setup:

✅ kubectl installed
✅ vscode installed
✅ Terraform installed
✅ Civo Kubernetes account
✅ Twingate enterprise account

## Getting Started 🏁

> You can either 

