#!/usr/bin/env bash
set -e

[[ "$(seth chain --rpc-url=$ETH_RPC_URL)" == "ethlive"  ]] || { echo "Please set a mainnet ETH_RPC_URL"; exit 1;  }

if [[ -z "$MATCH" ]]; then
  dapp --use solc:0.8.11 test --rpc-url="$ETH_RPC_URL" -v
else
  dapp --use solc:0.8.11 test --rpc-url="$ETH_RPC_URL" --match "$MATCH" -vv
fi
