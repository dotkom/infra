resource "nomad_job" "nodes" {
  jobspec = file("./files/plugin-aws-efs-nodes.nomad")
}
