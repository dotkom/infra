resource "doppler_secret" "admin_users" {
  config  = data.doppler_secrets.monoweb_rpc.config
  project = data.doppler_secrets.monoweb_rpc.project

  name = "ADMIN_USERS"
  value = join(",", [
    "auth0|b297f5ab-7635-4528-a463-8fc04a069a2f", # jotjernshaugen@gmail.com
    "auth0|643ecd24-ad8d-4ff3-843f-1e647384b348", # henrikskog01@gmail.com
    "auth0|9b80449f-42fe-4595-bb85-d45605444c07", # bragerino+onlinentnu@gmail.com
    "auth0|66b9feb446db2b42d5427ff9",             # mathealiv@gmail.com
    "auth0|6c5a4a22-e6c4-41a4-b8b8-0a659b5eb02d", # markus.wathle@gmail.com
  ])
}
