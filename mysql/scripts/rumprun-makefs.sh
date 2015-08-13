#!/bin/sh
#
# rumprun-makefs: Create a CD9660 or FFS image suitable for use with rumprun
# from a directory tree.
#
# This is currently a wrapper over NetBSD makefs, this may change in the
# future. On Debian-based systems you can install a suitable makefs with
# "apt-get install makefs". For other systems, see
# http://www.daemonology.net/makefs/.
#

err() {
	echo rumprun-makefs: error: "$@" 1>&2
	exit 1
}

usage() {
	cat <<EOM
usage: rumprun-makefs [-t FSTYPE] [-u UID] [-g GID] IMAGE-FILE DIRECTORY
	-t FSTYPE sets image filesystem type, cd9660 or ffs (default)
	-u UID forces all files in the image to be owned by UID, default=0
	-g GID forces all files in the omage to have a group of GID, default=0
EOM
	exit 1
}

opt_fstype=ffs
opt_uid=0
opt_gid=0
while getopts "t:u:g:" opt; do
	case "$opt" in
		t)
			opt_fstype=${OPTARG}
			;;
		u)
			opt_uid=${OPTARG}
			;;
		g)
			opt_gid=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

shift $((OPTIND-1))
[ $# -ne 2 ] && usage
opt_image=$(readlink -f $1)
opt_dir=$(readlink -f $2)
[ ! -d ${opt_dir} ] && err "Not a directory: ${opt_dir}"
makefs_extra=
# For CD9660 we want rockridge extensions.
[ "${opt_fstype}" = "cd9660" ] && makefs_extra="-o rockridge"
# For FFS, the version of makefs in Debian has problems with small image
# sizes. Set a minimum size.
[ "${opt_fstype}" = "ffs" ] && makefs_extra="-M 256k"
# For FFS, give us some free space to play with.
# [ "${opt_fstype}" = "ffs" ] && makefs_extra="${makefs_extra} -b 25% -f 25%"
[ "${opt_fstype}" = "ffs" ] && makefs_extra="${makefs_extra} -b 50% -f 250"

# Generate a mtree specification for the directory tree, with uid and gid
# set appropriately.
# TODO: Support types other than file and dir.
cd $opt_dir &&
find . -printf "%p type=%y mode=0%m uid=${opt_uid} gid=${opt_gid}\\n" | \
	sed -e "s/type=f/type=file/" -e "s/type=d/type=dir/" \
	>${opt_image}.spec

# Create the filesystem image using the generated spec.
makefs -t ${opt_fstype} -F ${opt_image}.spec ${makefs_extra} \
	${opt_image} ${opt_dir} \
	|| err "makefs failed"

rm ${opt_image}.spec

