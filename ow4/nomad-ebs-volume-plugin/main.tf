resource "nomad_job" "nodes" {
  jobspec = file("./files/plugin-aws-ebs-nodes.nomad")
  hcl2 {
    enabled = true
  }
}
