#!/bin/sh

#Test if argument (Rumprun GCC) was passed
if [ -z $1 ] ; then
	echo "Error: RUMPRUN_GCC wasnt passed by make script";
	exit 1;
fi 

gcc_ver=$($1 -v 2>&1 >/dev/null|grep -Po  '(?<=gcc version\s)([0-9]\.[0-9])');
gcc_ver_check=$(echo $gcc_ver | cut -d '.' -f 1)
if [ $(( $gcc_ver_check )) -eq 5 ] ; then 
	gcc_branch='gcc-5-branch';
	echo $gcc_branch;
	
elif [ $(( $gcc_ver_check )) -eq 4 ] ; then
	gcc_branch="gcc-${gcc_ver/./_}-branch";
	echo $gcc_branch;
else 
	echo "Error: Installed GCC version is not supported by the script!";
	exit 1;
fi
