#! /usr/bin/env bash
FILE_NAME=$1
CONTAINER_NAME=orveus-db
DATABASE_NAME=orveus
PW=
RESTORE_FILE_NAME=$(date +%Y-%m-%d_%H_%M_%S.$DATABASE_NAME.bak)

echo "Restoring database '$DATABASE_NAME' from file '$FILE_NAME' to container '$CONTAINER_NAME'..."

echo "Transferring file to container..."

# Copy the created file out of the container to the host filesystem
sudo docker cp $FILE_NAME $CONTAINER_NAME:/var/opt/mssql/backups/$RESTORE_FILE_NAME

# Create a database backup with sqlcmd
sudo docker exec -it "$CONTAINER_NAME" /opt/mssql-tools/bin/sqlcmd -b -V16 -S localhost -U SA -P $PW -Q "ALTER DATABASE [$DATABASE_NAME] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE [$DATABASE_NAME] FROM DISK = N'/var/opt/mssql/backups/$RESTORE_FILE_NAME' WITH REPLACE; ALTER DATABASE [$DATABASE_NAME] SET MULTI_USER;"

echo "Restored database '$DATABASE_NAME' from $FILE_NAME"
