#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Log file path
LOG_FILE="/var/log/user_management.log"
# Password storage file path
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Create secure directory for passwords if it doesn't exist
mkdir -p /var/secure
chmod 700 /var/secure

# Function to create groups
create_groups() {
  local groups="$1"
  IFS=',' read -r -a group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    group=$(echo "$group" | xargs) # Remove leading/trailing whitespace
    if [ ! -z "$group" ]; then
      if ! getent group "$group" > /dev/null; then
        groupadd "$group"
        echo "Group '$group' created." | tee -a "$LOG_FILE"
      fi
    fi
  done
}

# Function to create user and group
create_user() {
  local username="$1"
  local groups="$2"

  # Create user group if it doesn't exist
  if ! getent group "$username" > /dev/null; then
    groupadd "$username"
    echo "Group '$username' created." | tee -a "$LOG_FILE"
  fi

  # Create the additional groups
  create_groups "$groups"

  # Create user with personal group and home directory if user doesn't exist
  if ! id "$username" > /dev/null 2>&1; then
    useradd -m -g "$username" -G "$groups" "$username"
    echo "User '$username' created with groups '$groups'." | tee -a "$LOG_FILE"

    # Set home directory permissions
    chmod 700 "/home/$username"
    chown "$username:$username" "/home/$username"

    # Generate random password
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    echo "$username,$password" >> "$PASSWORD_FILE"
  else
    echo "User '$username' already exists." | tee -a "$LOG_FILE"
  fi
}

# Read the input file
input_file="$1"
if [ -z "$input_file" ]; then
  echo "Usage: $0 <name-of-text-file>"
  exit 1
fi

# Ensure the input file exists
if [ ! -f "$input_file" ]; then
  echo "File '$input_file' not found!"
  exit 1
fi

# Process each line of the input file
while IFS=';' read -r user groups; do
  user=$(echo "$user" | xargs) # Remove leading/trailing whitespace
  groups=$(echo "$groups" | xargs) # Remove leading/trailing whitespace
  if [ ! -z "$user" ]; then
    create_user "$user" "$groups"
  fi
done < "$input_file"

# Set permissions for password file
chmod 600 "$PASSWORD_FILE"
echo "User creation process completed." | tee -a "$LOG_FILE"