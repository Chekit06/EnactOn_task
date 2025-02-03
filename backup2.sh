#!/bin/bash

# Configuration
PROJECT_NAME="github-clone"
GITHUB_REPO="https://github.com/Chekit06/Three-Tier-Project.git"  # github URL
PROJECT_DIR="$PROJECT_NAME"  # directory where the code will be cloned first
BACKUP_DIR="/Users/chekitsharma/Desktop"   # directory where the .zip file will reside
GDRIVE_REMOTE="gdrive"       # rclone gdrive remote name
GDRIVE_FOLDER="enactOn-task" # folder name in Google Drive

LOG_DIR=/Users/chekitsharma/Desktop

exec >> $LOG_DIR

# Retention 
DAILY_RETENTION_DAYS=1    # delete backups older than 7 days
WEEKLY_RETENTION_DAYS=28  # delete weekly backups older than 28 days, 4 weeks from the day set for example = sunday.
MONTHLY_RETENTION_DAYS=90 # delete monthly backups older than 90 days

# Discord webhook url for interaction with discord api for alerts on the custom server
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1335951224629100594/Y08zzorYSEjbjLgslx6fbl7gHMCqaCl6zCVHPtLUE1oQn_awcbxn5HPeVucinZJ2nO2n"  # Replace with your Discord webhook URL
ENABLE_DISCORD=true  # to turn on or off the alerts on discord

# cloning the github repo in the project directory 

if [ -d "$PROJECT_DIR" ]; then    # It checks using the -d if the directory exists
  cd "$PROJECT_DIR" && git pull origin main   # change directory to project directory and clones the code inside
  cd ..
else
  git clone "$GITHUB_REPO" "$PROJECT_DIR"  # if the directory doesnt exist it creates a new directory with the name and clone inside it
fi

# checks if the directory exists and creates if it dont
mkdir -p "$BACKUP_DIR"

# timestamp to be given to files to organize them storing in the variable to be used later in naming of backup files
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

#DAILY
# This part is only for daily backup as i have divided them in daily, weekly and monthly
DAILY_BACKUP_FILE="$BACKUP_DIR/${PROJECT_NAME}_daily_$TIMESTAMP.zip"  # this gives the backup file name using timestamp and project name
zip -r "$DAILY_BACKUP_FILE" "$PROJECT_DIR" > /dev/null   # then creates a zip file using that name from project dir folder
rclone copy "$DAILY_BACKUP_FILE" "$GDRIVE_REMOTE:$GDRIVE_FOLDER/" --progress # This is the part it actually clones the .zip file to gdrive folder using rclone


# Weekly Backups (on a specified weekly day)
# date +%u returns 7 for Sunday (1=Monday ... 7=Sunday)
if [ "$(date +%u)" -eq 1 ]; then       # here it checks if the today is equal to 7 which means sunday.
  WEEKLY_BACKUP_FILE="$BACKUP_DIR/${PROJECT_NAME}_weekly_$TIMESTAMP.zip" # naming weekly backup file same as daily to distinguish between them for retention
  cp "$DAILY_BACKUP_FILE" "$WEEKLY_BACKUP_FILE"    # if its sunday we will simply copy the daily backup file because it will already be there and we dont need to create a new archive
  rclone copy "$WEEKLY_BACKUP_FILE" "$GDRIVE_REMOTE:$GDRIVE_FOLDER/" --progress  # use the same command as daily for weekly and clone it to gdrive
fi


# Monthly Backup (only on the 1st day of the month)
if [ "$(date +%d)" = "01" ]; then  # Same as before checks for the 1st of the month if yes it runs the condition which satisfies
  MONTHLY_BACKUP_FILE="$BACKUP_DIR/${PROJECT_NAME}_monthly_$TIMESTAMP.zip"
  cp "$DAILY_BACKUP_FILE" "$MONTHLY_BACKUP_FILE"  # same we will copy the daily backup file because we dont need to create a new zip
  rclone copy "$MONTHLY_BACKUP_FILE" "$GDRIVE_REMOTE:$GDRIVE_FOLDER/" --progress # clones the .zip to gdrive using distinguished name
fi

# Rotating Backups gdrive via rclone

# here we are deleting the older backup files using delete the remote path,
# --min-age tells it to keep the files which has the age of the given value, like 7 days or younger should be kept not delete.
# the "d" after the variable specifies days (other -> h, m, s) 
# --include tells it to include all files starting with projectname_daily_* (star is postfix which means include all the files that start with this)
# Delete daily backups older than specified days in the DAILY_RETENTION_DAYS
rclone delete "$GDRIVE_REMOTE:$GDRIVE_FOLDER" --min-age ${DAILY_RETENTION_DAYS}m --include "${PROJECT_NAME}_daily_*.zip"

# Delete daily backups older than specified days in the WEEKLY_RETENTION_DAYS
rclone delete "$GDRIVE_REMOTE:$GDRIVE_FOLDER" --min-age ${WEEKLY_RETENTION_DAYS}d --include "${PROJECT_NAME}_weekly_*.zip"

# Delete daily backups older than specified days in the MONTHLY_RETENTION_DAYS
rclone delete "$GDRIVE_REMOTE:$GDRIVE_FOLDER" --min-age ${MONTHLY_RETENTION_DAYS}d --include "${PROJECT_NAME}_monthly_*.zip"


# Discord Alerts
if [ "$ENABLE_DISCORD" = true ]; then # this checks if the variable is set to true or false for alerts
  MESSAGE="Backup completed for project '$PROJECT_NAME' on $TIMESTAMP. Daily backup file: $DAILY_BACKUP_FILE." # message for alerts using timezone
  
  if [ "$(date +%u)" -eq 7 ]; then    # this checks if the day is sunday weekly backup must be create so rolls out an alert for that too
    MESSAGE="$MESSAGE Weekly backup created."
  fi
  if [ "$(date +%d)" = "01" ]; then   # same as weekly it checks for monthly
    MESSAGE="$MESSAGE Monthly backup created."
  fi

  # This is the curl command which passes the message to discord server using the webhook that we provided
  curl -X POST -H "Content-Type: application/json" \
       -d "{\"content\": \"$MESSAGE\"}" \
       "$DISCORD_WEBHOOK_URL"
fi

# LOGS
echo "Backup completed at $TIMESTAMP"
echo "Daily Backup:   $DAILY_BACKUP_FILE"
[ -f "$WEEKLY_BACKUP_FILE" ] && echo "Weekly Backup:  $WEEKLY_BACKUP_FILE"
[ -f "$MONTHLY_BACKUP_FILE" ] && echo "Monthly Backup: $MONTHLY_BACKUP_FILE"
