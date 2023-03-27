#!/bin/bash

OUTPUT_PATH=./genesis-playground/output

echo "Cleaning old output dir"
rm -rf $OUTPUT_PATH

echo "Creating genesis file"

npx quorum-genesis-tool \
  --outputPath $OUTPUT_PATH \
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

