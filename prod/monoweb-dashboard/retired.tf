removed {
  from = module.server_ecr_image

  lifecycle {
    destroy = true
  }
}

removed {
  from = doppler_secret.sentry_dsn

  lifecycle {
    destroy = true
  }
}
