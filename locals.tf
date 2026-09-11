locals {
  post_private_endpoint_sleep_duration = "60s"
  is_prd_or_mpd_environment            = contains(["prd", "mpd"], lower(var.environment))
}
