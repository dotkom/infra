write_files:
- encoding: b64
  content: ${consul_vars}
  owner: consul-consul
  path: /etc/consul.d/vars.yml
  permissions: '0664'
  append: true

bootcmd:
- 'echo "node_name: consul-server-$INSTANCE_ID" > /etc/consul.d/vars.yml'
