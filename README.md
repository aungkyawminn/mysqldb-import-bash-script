## Description
- This script connects to external database server by ssh tunnel using username/password, dump database and clean import to  local database
- You will need root access to execute this script and need to pre-configure networking and security for connecting between external database server and local database server

## Pre-Configure
- You will need to enter password for user if external database server ssh service is configured using password authentication.
- If external database server ssh service is using public key authentication, you need to add your server public key in external server's authorized_keys file.

## Configuration
You need to add following information before running script.

### SSH details for the external server
SSH_USER=""
SSH_HOST=""

### External database details
EXTERNAL_DB_NAME=""
EXTERNAL_DB_USER=""
EXTERNAL_DB_PASSWORD=""

### Local database details
LOCAL_DB_NAME=""
LOCAL_DB_USER=""
LOCAL_DB_PASSWORD=""


## Execute Script

`# bash db_import.sh`

