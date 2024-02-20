resource "nomad_job" "jaeger-agent" {
  jobspec = file("./files/jaeger-agent.nomad")
}