#!/bin/bash
# Builds one specific package, specified by $PACKAGE
if [ -z "${PACKAGE}" ]; then
	echo "PACKAGE is not set"
	exit 1
fi
cd ${PACKAGE}
make -j2
