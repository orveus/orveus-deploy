#! /usr/bin/env bash

CONTAINER_NAME=orveus-db
DATABASE_NAME=orveus
PW=

# Create a file name for the backup based on the current date and time
FILE_NAME=$(date +%Y-%m-%d_%H_%M_%S.$DATABASE_NAME.bak)
CURR_DIR=$(pwd)

# Make sure the backups folder exists on the host file system
mkdir -p "./backups"

echo "Backing up database '$DATABASE_NAME' from container '$CONTAINER_NAME'..."

# Create a database backup with sqlcmd
docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -b -V16 -S localhost -U SA -P $PW -Q "BACKUP DATABASE [$DATABASE_NAME] TO DISK = N'/var/opt/mssql/backups/$FILE_NAME' with NOFORMAT, NOINIT, NAME = '$DATABASE_NAME-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

echo "Exporting file from container..."

# Copy the created file out of the container to the host filesystem
docker cp $CONTAINER_NAME:/var/opt/mssql/backups/$FILE_NAME ./backups/$FILE_NAME

echo "Backed up database '$DATABASE_NAME' to ./backups/$FILE_NAME"

SMTP_ADDR=
SMTP_FROM=
SMTP_TO=
SMTP_AUTH=
SMTP_SUBJECT="ORVEUS / Backup erfolgreich / $(date +'%d.%m.%Y %H:%M')"
FILE_STATS=$(stat ./backups/$FILE_NAME)
SMTP_BODY="Die Sicherung für ORVEUS wurde erfolgreich erstellt.\n\n\nSicherungspfad: $CURR_DIR/backups/$FILE_NAME\n\n\nInformationen:\n$FILE_STATS"

curl --retry 3 --url "$SMTP_ADDR" --ssl-reqd --mail-from "$SMTP_FROM" --mail-rcpt "$SMTP_TO" --user "$SMTP_AUTH" -T <(echo -e "From: $SMTP_FROM\nTo: $SMTP_TO\nSubject: $SMTP_SUBJECT\n$SMTP_BODY")
