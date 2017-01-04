NODE_VERSION=4.3.0
PKGSRC=nodejs4
BUILD_DIR=build-$(NODE_VERSION)
NODE_BIN=$(BUILD_DIR)/out/Release/node-$(shell basename `readlink $(dir $(realpath $(lastword $(MAKEFILE_LIST))))/rumpmain.js` .js)
