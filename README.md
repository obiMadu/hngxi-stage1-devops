# Technical Article

## Automating User and Group Creation with a Bash Script

As a SysOps engineer, managing users and groups is a critical task, especially when onboarding new developers. Automating this process ensures consistency and efficiency. In this article, I'll walk you through a bash script designed to create users and groups based on a provided text file. This script also sets up home directories, assigns appropriate permissions, generates random passwords, and logs all actions.

You can learn more about HNG Internship opportunities [here](https://hng.tech/internship) and [here](https://hng.tech/hire).

## Script Overview

The script `create_users.sh` reads a text file where each line contains a username and a semicolon-separated list of groups. It creates each user and their personal group (which has the same name as the username), assigns the user to additional specified groups, sets up home directories, and logs all actions to `/var/log/user_management.log`. Generated passwords are stored securely in `/var/secure/user_passwords.csv`.

## Script Breakdown

1. **Root Check**: Ensure the script runs with root privileges.
    ```bash
    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root."
      exit 1
    fi
    ```

2. **Argument Check**: Verify that the filename argument is provided.
    ```bash
    if [ -z "$1" ]; then
      echo "Usage: $0 <filename>"
      exit 1
    fi
    ```

3. **File Preparation**: Create log and password files if they don't exist, and set secure permissions on the password file.
    ```bash
    touch $LOG_FILE
    touch $PASSWORD_FILE
    chmod 600 $PASSWORD_FILE
    ```

4. **Logging Function**: Define a function to log messages with timestamps.
    ```bash
    log_message() {
      echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
    }
    ```

5. **Password Generation**: Define a function to generate random passwords.
    ```bash
    generate_password() {
      tr -dc A-Za-z0-9 </dev/urandom | head -c 12
    }
    ```

6. **Reading the Input File**: Process each line in the input file.
    ```bash
    while IFS=';' read -r user groups; do
      # Remove leading/trailing whitespace
      user=$(echo "$user" | xargs)
      groups=$(echo "$groups" | xargs)

      if id "$user" &>/dev/null; then
        log_message "User $user already exists."
      else
        useradd -m -g "$user" "$user"
        log_message "Created user $user with personal group $user."

        password=$(generate_password)
        echo "$user:$password" | chpasswd
        echo "$user,$password" >> $PASSWORD_FILE
        log_message "Generated and set password for $user."
      fi

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
    ```

## Conclusion

This script automates the user and group creation process, ensuring that each user has a personal group, is added to specified groups, and has a secure, randomly generated password. All actions are logged for auditing purposes, and the script handles existing users and groups gracefully.

For more on the HNG Internship, visit [HNG Internship](https://hng.tech/internship) and [HNG Hire](https://hng.tech/hire).