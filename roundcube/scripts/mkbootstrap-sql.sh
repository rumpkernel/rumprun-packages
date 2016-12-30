#!/bin/sh

# This script generates the SQL required to initialise the MySQL database
# for roundcube, including setting up the roundcube user and password
# using the generated values in config/.

if [ $# -ne 1 ]; then
    echo usage: $0 path/to/config/directory
    exit 1
fi

OUT="$1/bootstrap.sql"
PASSWD_FILE="$1/db-password"
ROUNDCUBE_SQL="$1/../build/SQL/mysql.initial.sql"

if [ -f "$OUT" ]; then
    echo error: $OUT: file exists, will not overwrite
    exit 1
fi

if [ ! -f "$PASSWD_FILE" ]; then
    echo error: missing db-password
    exit 1
fi

if [ ! -f "$ROUNDCUBE_SQL" ]; then
    echo error: missing "${ROUNDCUBE_SQL}"
    exit 1
fi

PASSWD=$(cat $PASSWD_FILE)

cat <<EOM >$OUT
-- AUTOMATICALLY GENERATED

-- Rump-specific bootstrap for MySQL.

-- For roundcube, drop all users except 'rump' which is made
-- equivalent to the 'root' user and allowed to login from any host.
USE mysql;
UPDATE user SET User = 'rump', Host = '%' WHERE User = 'root' AND Host = 'localhost';
DELETE from user WHERE User != 'rump';

-- Set password to value generated at configuration time.
update user set Password = PASSWORD('${PASSWD}') where User = 'rump';

-- ROUNDCUBE INITIALISATION FOLLOWS
CREATE DATABASE roundcube;
USE roundcube;

EOM

sed -e 's%/\*!40000 ENGINE=INNODB \*/%%g' < ${ROUNDCUBE_SQL} >>${OUT}
