#!/bin/bash

# Generate genesis files, tessera keys, ethereum keys, and node keys
function generate_genesis() {
  echo "Generating genesis files..."
  npx quorum-genesis-tool \
  --outputPath $QDQS_DIR \
  --consensus qbft \
  --chainID 1337 \
  --blockperiod 5 \
  --requestTimeout 10 \
  --epochLength 30000 \
  --difficulty  1 \
  --gasLimit 0xFFFF \
  --coinbase 0x0000000000000000000000000000000000000000 \
  --maxCodeSize 64 \
  --txnSizeLimit 64 \
  --validators 0 \
  --members 4 \
  --bootnodes 0 \
  --accountPassword "" \
  --tesseraEnabled true \
  --tesseraPassword "" \
  --quickstartDevAccounts false
}

# Generate QDQS project
function generate_qdqs() {
  node build/index.js --clientType goquorum --privacy true --monitoring=loki --blockscout=true --outputPath $QDQS_DIR --orchestrate=false
}

# Mutate QDQS project
function mutate_qdqs() {
  echo "Mutating QDQS"

  # Copy generated tessera keys
  for i in 1 2 3;
  do
      MEMBER_NODE_DIR="$QDQS_DIR/config/nodes/member$i"

      echo "Copying new tessera keys for member$i";
      cp $GENESIS_DIR/member$i/tessera.pub $MEMBER_NODE_DIR/tm.pub
      cp $GENESIS_DIR/member$i/tessera.key $MEMBER_NODE_DIR/tm.key

      echo "Copying new Ethereum keys for member$i";
      cp $GENESIS_DIR/member$i/accountKeystore $MEMBER_NODE_DIR/accountKeystore
      cp $GENESIS_DIR/member$i/nodekey $MEMBER_NODE_DIR/nodekey
  done

  echo "set enhanced genesis mode"
  # set enhanced genesis mode
  sed -i 's/GOQUORUM_GENESIS_MODE=standard/GOQUORUM_GENESIS_MODE=enhanced/g' $QDQS_DIR/docker-compose.yml

  echo "enable tesserra privacy enhancement"
  # enable tesserra privacy enhancement
  sed -i 's/"enablePrivacyEnhancements": false/"enablePrivacyEnhancements": true/g' $QDQS_DIR/config/tessera/data/tessera-config-template.json
}

QDQS_DIR=./genesis-playground
rm -rf $QDQS_DIR

GENERATE_GENESIS_OUTPUT=$(generate_genesis $QDQS_DIR)

if [[ $GENERATE_GENESIS_OUTPUT =~ ($QDQS_DIR/[-[:digit:]]+)$ ]]; then 
  GENESIS_DIR=${BASH_REMATCH[1]}
  echo "Genesis files generated at $GENESIS_DIR"
else 
    echo "Failed to find the nested output dir from the genesis tool"
    exit 1
fi

generate_qdqs $QDQS_DIR

mutate_qdqs $QDQS_DIR $GENESIS_DIR