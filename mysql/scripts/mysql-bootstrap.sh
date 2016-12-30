#!/bin/sh
# mysql-bootstrap.sh: Cross-bootstrap a fresh MySQL unikernel.

die()
{
    [ -n "$@" ] && echo $0: error: "$@" 1>&2
    exit 1
}

if [ $# -lt 1 ]; then
    cat << EOM 1>&2
usage: $0 DATA_DIR [ BOOTSTRAP_SQL ]
DATA_DIR is the destination directory for the MySQL unikernel data files.
BOOTSTRAP_SQL, is the file containing bootstrap SQL commands.
If BOOTSTRAP_SQL is not specified, the default 'mysql_rump_bootstrap.sql'
will be used.
EOM
    exit 1
fi

# Find our package directory from script location.
PACKAGE_DIR=$(readlink -f $(dirname $0)/..)

# Check prerequisites.
BUILD_DIR="${PACKAGE_DIR}/build/mysql"
[ -d "${BUILD_DIR}" ] || die "${BUILD_DIR} missing or not built"
NATIVE_DIR="${BUILD_DIR}/build-native"
[ -d "${NATIVE_DIR}" ] || die "${NATIVE_DIR} missing or not built"
DATA_DIR=$(readlink -f "$1")
[ -d "${DATA_DIR}" ] || die "Not a directory: ${DATA_DIR}"
MYSQLD=${PACKAGE_DIR}/bin/mysqld-bootstrap
[ -x "${MYSQLD}" ] || die "${MYSQLD} is missing or not built"
BOOTSTRAP_SQL=${PACKAGE_DIR}/mysql_rump_bootstrap.sql
[ -n "$2" ] && BOOTSTRAP_SQL=$(readlink -f "$2")
[ -f "${BOOTSTRAP_SQL}" ] || die "${BOOTSTRAP_SQL} is missing"

echo "$0: Bootstrapping MySQL unikernel at ${DATA_DIR} using ${BOOTSTRAP_SQL}"
mkdir -p ${DATA_DIR}/share || die
cp ${PACKAGE_DIR}/my.cnf ${DATA_DIR} || die
cp -r ${NATIVE_DIR}/sql/share/english ${DATA_DIR}/share || die
perl ${NATIVE_DIR}/scripts/mysql_install_db \
    --defaults-file=${DATA_DIR}/my.cnf \
    --builddir=${NATIVE_DIR} \
    --srcdir=${BUILD_DIR} \
    --datadir=${DATA_DIR}/mysql \
    --lc-messages-dir=${DATA_DIR}/share \
    --cross-bootstrap || die "mysql_install_db failed"
cat ${BOOTSTRAP_SQL} | \
    ${MYSQLD} \
    --defaults-file=${DATA_DIR}/my.cnf \
    --basedir=${DATA_DIR} \
    --bootstrap || die "mysqld-bootstrap failed"
echo "$0: MySQL bootstrap successful"
