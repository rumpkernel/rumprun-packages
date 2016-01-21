#!/bin/sh

. ../config.mk;
gcc_ver=$($RUMPRUN_TOOLCHAIN_TUPLE-gcc -v 2>&1 >/dev/null|grep -Po  '(?<=gcc version\s)([0-9]\.[0-9])');
gcc_ver_check=$(echo $gcc_ver | cut -d '.' -f 1)
if [ $(( $gcc_ver_check )) -ge 5 ] && [ $(( $gcc_ver_check )) -lt 6 ]; then 
	gcc_branch='gcc-5-branch';
	echo $gcc_branch;
	
elif [ $(( $gcc_ver_check )) -ge 4 ] && [ $(( $gcc_ver_check )) -lt 5 ]; then
	gcc_branch="gcc-${gcc_ver/./_}-branch";
	echo $gcc_branch;
else 
	echo "Installed GCC version is not supported by the script!";
	exit 1;
fi
