#!/bin/sh

# This script generate the 'dynamic' portion of the roundcube configuration for
# a new installation. Specifically, the database password and session key.

if [ $# -ne 1 ]; then
    echo usage: $0 path/to/config/directory
    exit 1
fi

OUT="$1/config-gen.inc.php"
PASSWD_FILE="$1/db-password"
KEY_FILE="$1/session-key"

if [ -f "$OUT" ]; then
    echo error: $OUT: file exists, will not overwrite
    exit 1
fi

if [ ! -f "$PASSWD_FILE" -o ! -f "$KEY_FILE" ]; then
    echo error: missing db-password or session-key
    exit 1
fi

PASSWD=$(cat $PASSWD_FILE)
DESKEY=$(cat $KEY_FILE)

cat <<EOM >$OUT
<?php

// AUTOMATICALLY GENERATED

// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql or sqlsrv
// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// NOTE: for SQLite use absolute path: 'sqlite:////full/path/to/sqlite.db?mode=0646'
\$config['db_dsnw'] = 'mysql://rump:${PASSWD}@tcp(u-mysql-1)/roundcube';

// this key is used to encrypt the users imap password which is stored
// in the session record (and the client cookie if remember password is enabled).
// please provide a string of exactly 24 chars.
// YOUR KEY MUST BE DIFFERENT THAN THE SAMPLE VALUE FOR SECURITY REASONS
\$config['des_key'] = '${DESKEY}';
EOM

