#!/bin/sh

usage ()
{
     echo " Shell Script to clone Git repository or a specific branch to a defined path";
     echo " usage: git_clone.sh repository_url destination [branch_name]";
}

if ! type "git" > /dev/null; then
	echo "You need Git installed on your machine to install the package!";
	exit 1;
fi

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	usage;
	exit 1;
fi

if [ -n $3 ]; then
	git clone -b $3 $1 $2;
	exit 0;
else
	git clone $1 $2;
	exit 0;
fi
