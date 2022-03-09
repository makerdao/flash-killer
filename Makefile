all    :; dapp --use solc:0.8.12 build
clean  :; dapp clean
test   :; ./test.sh match="$(match)"
