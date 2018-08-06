#### # This is an example of how to deploy vault and associated operator on Openshift
###### # The Vault operator employs the etcd operator to deploy an etcd cluster as the storage backend.

##### # Create the etcd operator Custom Resource Definitions (CRD):
```
kubectl create -f example/etcd_crds.yaml
```
##### # Deploy the etcd operator:
```
kubectl -n default create -f example/etcd-operator-deploy.yaml
```
##### # Deploying the Vault operator
```
kubectl create -f example/vault_crd.yaml
kubectl -n default create -f example/deployment.yaml
```
###### # Verify that the operators are running:
```
kubectl -n default get deploy
```
##### # Deploying a Vault cluster
###### # A Vault cluster can be deployed by creating a VaultService Custom Resource(CR). For each Vault cluster the Vault operator will also create an etcd cluster for the storage backend.
```
kubectl -n default create -f example/example_vault.yaml
```