#!/bin/bash

QDQS_DESTINATION="./quorum-test-network" # Optional override for desired QDQS destination

echo "Cleaning old environment dir"
rm -rf quorum-test-network

echo "Building project"
npm run build

echo "Creating a new QDQS project"
node build/index.js --clientType goquorum --privacy true --monitoring=loki --blockscout=true --outputPath ./quorum-test-network --orchestrate=false

echo "\n\nset enhanced genesis mode"
# set enhanced genesis mode
sed -i 's/GOQUORUM_GENESIS_MODE=standard/GOQUORUM_GENESIS_MODE=enhanced/g' quorum-test-network/docker-compose.yml

echo "enable tesserra privacy enhancement"
# enable tesserra privacy enhancement
sed -i 's/"enablePrivacyEnhancements": false/"enablePrivacyEnhancements": true/g' quorum-test-network/config/tessera/data/tessera-config-template.json
