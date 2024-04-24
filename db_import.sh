#!/bin/bash

# Author: Aung Kyaw Minn https://github.com/aungkyawminn
# Created on: 2024-04-02
# Description:
# This script connects to external database server by ssh tunnel using username/password, dump database and clean import to  local database.
# You will need to enter password for ssh user if ssh server is configured using password authentication.
# If ssh server is using public key authentication, you need to add your server public key in external server's authorized_keys file.
# Notice: You will need root access to execute this script and need to pre-configure networking and security for connecting between external database server and local database server

# SSH details for the external server
SSH_USER=""
SSH_HOST=""
SSH_PORT="22" # SSH port, 22 is the default

# External database details
EXTERNAL_DB_NAME=""
EXTERNAL_DB_USER=""
EXTERNAL_DB_PASSWORD=""

# Local database details
LOCAL_DB_NAME=""
LOCAL_DB_USER=""
LOCAL_DB_PASSWORD=""

# Local port for the SSH tunnel, different from the MySQL port to avoid conflicts
LOCAL_PORT="3307"

# Create an SSH tunnel
echo "Establishing an SSH tunnel on port $SSH_PORT..."
ssh -f -N -L ${LOCAL_PORT}:localhost:3306 -p $SSH_PORT ${SSH_USER}@${SSH_HOST}

# Check if the SSH tunnel was established successfully
if [ $? -eq 0 ]; then
  echo "SSH tunnel established successfully."
else
  echo "Failed to establish an SSH tunnel."
  exit 1
fi

# Temporary file to store the database dump
DUMP_FILE="/tmp/ems_old_uat.sql"

# Export the external database through the SSH tunnel
echo "Exporting external database..."
mysqldump -h 127.0.0.1 -P $LOCAL_PORT -u $EXTERNAL_DB_USER -p$EXTERNAL_DB_PASSWORD $EXTERNAL_DB_NAME > $DUMP_FILE

# Check if the dump was successful
if [ $? -eq 0 ]; then
  echo "Database exported successfully."
else
  echo "Failed to export database."
  exit 1
fi

# Drop the local database and recreate it to ensure it's clean for import
echo "Preparing local database..."
mysql -u $LOCAL_DB_USER -p$LOCAL_DB_PASSWORD -e "DROP DATABASE IF EXISTS $LOCAL_DB_NAME; CREATE DATABASE $LOCAL_DB_NAME;"

# Import the dump into the local database
echo "Importing dump into local database..."
mysql -u $LOCAL_DB_USER -p$LOCAL_DB_PASSWORD $LOCAL_DB_NAME < $DUMP_FILE

if [ $? -eq 0 ]; then
  echo "Database imported successfully."
else
  echo "Failed to import database."
  exit 1
fi

# Clean up the dump file
rm $DUMP_FILE

# Close the SSH tunnel after finished importing
# Find the process ID (PID) of the SSH tunnel and kill it.
SSH_TUNNEL_PID=$(ps aux | grep 'ssh -f -N -L' | grep -v grep | awk '{print $2}')
if [[ ! -z "$SSH_TUNNEL_PID" ]]; then
  kill $SSH_TUNNEL_PID
  echo "SSH tunnel closed."
fi