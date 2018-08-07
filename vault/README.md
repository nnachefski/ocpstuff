#### # This is an example of how to deploy vault and associated operator on Openshift
###### # The Vault operator employs the etcd operator to deploy an etcd cluster as the storage backend.
##### # clone the repo
```
git clone https://github.com/coreos/vault-operator.git
cd vault-operator
```
##### # create project for the vault
```
oc new-project vault
```
##### # Create the etcd operator Custom Resource Definitions (CRD):
```
oc create -f example/etcd_crds.yaml
```
##### # Deploy the etcd operator:
```
oc -n default create -f example/etcd-operator-deploy.yaml
```
##### # Deploying the Vault operator
```
oc create -f example/vault_crd.yaml
oc -n default create -f example/deployment.yaml
```
###### # Verify that the operators are running:
```
oc -n default get deploy
```
##### # Deploying a Vault cluster
###### # A Vault cluster can be deployed by creating a VaultService Custom Resource(CR). For each Vault cluster the Vault operator will also create an etcd cluster for the storage backend.
```
oc -n default create -f example/example_vault.yaml
```