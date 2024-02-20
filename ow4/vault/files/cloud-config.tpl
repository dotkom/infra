write_files:
- encoding: b64
  content: ${consul_vars}
  owner: root:root
  path: /etc/consul.d/vars.yml
  permissions: '0644'
  append: true
- encoding: b64
  content: ${vault_vars}
  owner: root:root
  path: /etc/vault.d/vars.yml
  permissions: '0640'

bootcmd:
- 'echo "node_name: vault-server-$INSTANCE_ID" > /etc/consul.d/vars.yml'
