#!/bin/bash

TESSERA_VERSION="22.10.1"
QDQS_DESTINATION="./quorum-test-network" # Optional override for desired QDQS destination

docker pull quorumengineering/tessera:$TESSERA_VERSION

echo "Cleaning old environment dir"
rm -rf quorum-test-network

echo "Building project"
npm run build

echo "Creating a new QDQS project"
node build/index.js --clientType goquorum --privacy true --monitoring=loki --blockscout=true --outputPath ./quorum-test-network --orchestrate=false

# MODIFICATIONS GO AFTER HERE

# Regen tessera keys
for i in 1 2 3;
do
    MEMBER_NODE_DIR="$QDQS_DESTINATION/config/nodes/member$i"
    echo "Member node dir: $MEMBER_NODE_DIR"
    pushd $MEMBER_NODE_DIR
    echo "Deleting old tessera keys for member$i";
    rm tm.*
    echo "Gnerating new tessera keys for member$i";
    docker run -v `pwd`:`pwd` -w `pwd` quorumengineering/tessera:$TESSERA_VERSION keygen -filename tm
    echo "member$i tessera public key:"
    cat tm.pub
    popd
done



echo "\\n\\nset enhanced genesis mode"
# set enhanced genesis mode
sed -i 's/GOQUORUM_GENESIS_MODE=standard/GOQUORUM_GENESIS_MODE=enhanced/g' quorum-test-network/docker-compose.yml

echo "enable tesserra privacy enhancement"
# enable tesserra privacy enhancement
sed -i 's/"enablePrivacyEnhancements": false/"enablePrivacyEnhancements": true/g' quorum-test-network/config/tessera/data/tessera-config-template.json
