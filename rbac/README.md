#### # This doc describes how to setup LDAP and Group Sync with IPA

##### # grab the cert from your IPA server
```
curl  http://gw.home.nicknach.net/ipa/config/ca.crt >> /etc/origin/master/my-ldap-ca-bundle.crt
```
##### # test your filter 
```
ldapsearch -H ldaps://dc1.home.nicknach.net:636 -v -x -s base -D uid=bind_account,ou=people,dc=ocp,dc=nicknach,dc=net -W
```
###### # edit master-config.yml.  The following config will use two auth providers, htpasswd and ldap.
```
  identityProviders:
  - challenge: true
    login: true
    mappingMethod: claim
    name: htpasswd_auth
    provider:
      apiVersion: v1
      file: /etc/origin/master/htpasswd
      kind: HTPasswdPasswordIdentityProvider
  - name: "my_ldap_provider"
    challenge: true
    login: true
    mappingMethod: claim
    provider:
      apiVersion: v1
      kind: LDAPPasswordIdentityProvider
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: ""
      bindPassword: ""
      ca: my-ldap-ca-bundle.crt
      insecure: false
      url: "ldap://gw.home.nicknach.net/cn=users,cn=accounts,dc=home,dc=nicknach,dc=net?uid"
  masterCA: ca-bundle.crt
```
##### # get the files called ocp_group_sync.conf and ocp_group_sync-whitelist.conf, edit them with your details, and put them in /etc/origin/master on all masters.
```
curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf
```
##### # then run this...
```
oc adm groups sync --sync-config=ocp_group_sync.conf --confirm --whitelist=ocp_group_sync-whitelist.conf
```
