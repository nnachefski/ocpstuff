{
  "AUTH_LDAP_SERVER_URI": "ldap://gw.home.nicknach.net",
  "AUTH_LDAP_BIND_DN": "",
  "AUTH_LDAP_BIND_PASSWORD": "",
  "AUTH_LDAP_CONNECTION_OPTIONS": {
    "OPT_NETWORK_TIMEOUT": 30,
    "OPT_REFERRALS": 0
  },
  "AUTH_LDAP_USER_SEARCH": [
    "cn=users,cn=accounts,dc=home,dc=nicknach,dc=net",
    "SCOPE_SUBTREE",
    "(uid=%(user)s)"
  ],
  "AUTH_LDAP_USER_ATTR_MAP": {
    "first_name": "givenName",
    "last_name": "sn",
    "email": "mail"
  },
  "AUTH_LDAP_GROUP_SEARCH": [
    "cn=tower_users,cn=groups,cn=accounts,dc=home,dc=nicknach,dc=net",
    "SCOPE_SUBTREE",
    "(objectClass=groupofnames)"
  ],
  "AUTH_LDAP_USER_FLAGS_BY_GROUP": {
    'is_superuser': 'cn=tower_admins,cn=groups,cn=accounts,dc=home,dc=nicknach,dc=net',
  }
}
