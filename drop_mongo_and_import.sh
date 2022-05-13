#!/bin/bash

dbname="${1:-appdb}"
dbpath="/data/db/${dbname}"
read -sp "Dropping database: $dbname. Do you wish to continue? (y/N)" result
echo

if ([[ "$result" = "y" ]]); then
	if [[ -d $dbpath ]]; then
		echo "Dropping database: $dbname"
		mongo $dbname --eval "printjson(db.dropDatabase())"
		mongorestore --db $dbname $dbpath
	else
		echo "Error: Import directory $dbpath does not exist. Aborting"
		exit 1
	fi
else
	echo "Aborted"
	exit 0
fi
