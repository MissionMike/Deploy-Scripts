#!/bin/bash

# Production (source in pull.sh)
declare -A PRODUCTION

# HOSTNAME ex: domain.com
# DIRECTORY ex: /home/user/public_html/wp-content/
PRODUCTION[HOSTNAME]=""
PRODUCTION[DIRECTORY]="" 
PRODUCTION[MYSQL_HOST]="localhost"
PRODUCTION[MYSQL_DB]=""
PRODUCTION[MYSQL_USER]=""
PRODUCTION[MYSQL_PASS]=""
 

# Staging (destination in pull.sh)
declare -A STAGING

# HOSTNAME ex: staging.domain.com
# DIRECTORY ex: /home/user/public_html-staging/wp-content/
STAGING[HOSTNAME]=""
STAGING[DIRECTORY]=""
STAGING[MYSQL_HOST]="localhost"
STAGING[MYSQL_DB]=""
STAGING[MYSQL_USER]=""
STAGING[MYSQL_PASS]=""


RSYNC_OPTIONS=" "
# rsync options below
# comment/uncomment to remove/add to the RSYNC_OPTIONS string

# -r --recursive
RSYNC_OPTIONS="${RSYNC_OPTIONS} --recursive"

# -a --archive
RSYNC_OPTIONS="${RSYNC_OPTIONS} --archive"

# -v --verbose
RSYNC_OPTIONS="${RSYNC_OPTIONS} --verbose"

# -z --compress
RSYNC_OPTIONS="${RSYNC_OPTIONS} --compress"

# --no-A (no Access Control Lists)
RSYNC_OPTIONS="${RSYNC_OPTIONS} --no-A"

# --no-X (don't preserve Extended Attributes)
RSYNC_OPTIONS="${RSYNC_OPTIONS} --no-X"

# --no-o (don't preserve owner)
RSYNC_OPTIONS="${RSYNC_OPTIONS} --no-o"

# --no-g (don't preserve group)
RSYNC_OPTIONS="${RSYNC_OPTIONS} --no-g"

# --delete (delete extraneous files from destination dirs)
# RSYNC_OPTIONS="${RSYNC_OPTIONS} --delete"


# rsync exclude list
# add/remove items as needed
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude wp-config.php"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude .htaccess"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude cache"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude wp-snapshots"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude error_log"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude robots.txt"
RSYNC_OPTIONS="${RSYNC_OPTIONS} --exclude='/.htaccess'"


MYSQLDUMP_OPTIONS=" "

# mysqldump options below
# comment/uncomment to remove/add to the MYSQLDUMP_OPTIONS string

# --add-drop-table
MYSQLDUMP_OPTIONS="${MYSQLDUMP_OPTIONS} --add-drop-table"


if [ -z $1 ]; then

	# No arguments provided; cancel operation.
	echo "Missing argument: 'files', 'db', or 'all'"

elif [[ $1 == "files" ]]; then

	# Pull files from PRODUCTION to STAGING
	echo "Attempting to rsync files from production to staging.";
	rsync ${PRODUCTION[DIRECTORY]} ${STAGING[DIRECTORY]} ${RSYNC_OPTIONS}

elif [[ $1 == "db" ]]; then

	# Pull database from PRODUCTION to STAGING
	echo "Attempting to pull database from production to staging.";
	mysqldump -h ${PRODUCTION[MYSQL_HOST]} ${MYSQLDUMP_OPTIONS} -u${PRODUCTION[MYSQL_USER]} -p${PRODUCTION[MYSQL_PASS]} ${PRODUCTION[MYSQL_DB]} | sed "s/${PRODUCTION[HOSTNAME]}/${STAGING[HOSTNAME]}/g" | mysql -h ${STAGING[MYSQL_HOST]} -u${STAGING[MYSQL_USER]} -p${STAGING[MYSQL_PASS]} ${STAGING[MYSQL_DB]}

elif [[ $1 == "all" ]]; then

	# Pull files from PRODUCTION to STAGING
	echo "Attempting to rsync files from production to staging.";
	rsync ${PRODUCTION[DIRECTORY]} ${STAGING[DIRECTORY]} ${RSYNC_OPTIONS}

	# Pull database from PRODUCTION to STAGING
	# Piped through sed to search/replace hostnames
	echo "Attempting to pull database from production to staging.";
	mysqldump -h ${PRODUCTION[MYSQL_HOST]} ${MYSQLDUMP_OPTIONS} -u${PRODUCTION[MYSQL_USER]} -p${PRODUCTION[MYSQL_PASS]} ${PRODUCTION[MYSQL_DB]} | sed "s/${PRODUCTION[HOSTNAME]}/${STAGING[HOSTNAME]}/g" | mysql -h ${STAGING[MYSQL_HOST]} -u${STAGING[MYSQL_USER]} -p${STAGING[MYSQL_PASS]} ${STAGING[MYSQL_DB]}

fi