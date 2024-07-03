#!/bin/bash

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

INPUT_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Create the log and password files if they don't exist
touch $LOG_FILE
touch $PASSWORD_FILE

# Ensure only root can read/write the password file
chmod 600 $PASSWORD_FILE

# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to create a random password
generate_password() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Read the input file
while IFS=';' read -r user groups; do
  # Remove leading/trailing whitespace
  user=$(echo "$user" | xargs)
  groups=$(echo "$groups" | xargs)

  # Create personal group
  if ! getent group "$user" &>/dev/null; then
    groupadd "$user"
    log_message "Created personal group $user."
  fi

  # Create user
  if id "$user" &>/dev/null; then
    log_message "User $user already exists."
  else
    useradd -m -g "$user" "$user"
    log_message "Created user $user with personal group $user."

    # Generate and set password
    password=$(generate_password)
    echo "$user:$password" | chpasswd
    echo "$user,$password" >> $PASSWORD_FILE
    log_message "Generated and set password for $user."
  fi

  # Create and add user to groups
  IFS=',' read -ra GROUP_ARRAY <<< "$groups"
  for group in "${GROUP_ARRAY[@]}"; do
    group=$(echo "$group" | xargs)
    if ! getent group "$group" &>/dev/null; then
      groupadd "$group"
      log_message "Created group $group."
    fi
    usermod -aG "$group" "$user"
    log_message "Added user $user to group $group."
  done

done < "$INPUT_FILE"

log_message "User creation process completed."

exit 0
