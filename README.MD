# User Management Script

This repository contains a Bash script to manage user and group creation on a Linux system. The script reads an input file, creates groups if they don't already exist, and then creates users with the specified groups and home directories. Passwords are generated and stored securely.

## Prerequisites

- Root privileges are required to run this script.
- The script uses `openssl` to generate random passwords, ensure it is installed on your system.

## Usage

1. **Clone the repository:**

    ```sh
    git clone https://github.com/six-shot/HNG11DEVOPS.git
    cd stage1
    ```

2. **Prepare the input file:**

    - The input file should contain lines with user and group information separated by a semicolon (`;`).
    - Each line should follow the format: `username;group1,group2,...`

    Example:

    ```sh
    alice;admin,developers
    bob;testers
    ```

3. **Run the script with root privileges:**

    ```sh
    sudo ./user_management.sh <name-of-text-file>
    ```

## Script Details

### Variables

- `LOG_FILE`: Path to the log file where actions are recorded.
- `PASSWORD_FILE`: Path to the file where user passwords are stored.
  
### Functions

- `create_groups(groups)`: Takes a comma-separated string of group names, creates each group if it does not already exist.
- `create_user(username, groups)`: Creates a user with the specified groups. Generates a random password and stores it securely.

### Script Workflow

1. **Check for root privileges:** Ensures the script is run as root.
2. **Create secure directory for password storage:** If not already existing, with appropriate permissions.
3. **Read and process the input file:** For each line, it extracts the username and groups, then calls `create_user()` to create the user and associated groups.
4. **Set permissions for the password file:** Ensures that the password file is accessible only by root.

## Logs and Passwords

- Actions performed by the script are logged in `/var/log/user_management.log`.
- Usernames and generated passwords are stored in `/var/secure/user_passwords.csv` with secure permissions.

## Example Run

```sh
sudo ./user_management.sh users.txt
