write_files:
- encoding: b64
  content: ${consul_vars}
  owner: root:root
  path: /etc/consul.d/vars.yml
  permissions: '0644'
  append: true
- encoding: b64
  content: ${nomad_vars}
  owner: root:root
  path: /etc/nomad.d/vars.yml
  permissions: '0644'

bootcmd:
- 'echo "node_name: nomad-client-$INSTANCE_ID" > /etc/consul.d/vars.yml'