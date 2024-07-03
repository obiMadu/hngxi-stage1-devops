# User Management Bash Script

## Overview

This script is designed to manage user accounts and their associated groups on a Unix-based system. It performs tasks such as creating users, assigning them to groups, and generating passwords. The script logs all its activities to `/var/log/user_management.log` and stores generated passwords in `/var/secure/user_passwords.csv`.

## Prerequisites

- The script must be run as a superuser.
- Ensure that Bash and necessary user management commands (`useradd`, `usermod`, `groupadd`, `passwd`) are available on the system.

## Usage

### Running the Script

To execute the script, use the following command:

```bash
sudo ./user_management.sh user_groups_file1 user_groups_file2 ...
```

Each file should contain lines in the format `username;group1,group2,...`.

### Script Workflow

1. **Check for Superuser Privileges**:
   The script first checks if it is run as a superuser. If not, it exits with a message indicating that superuser privileges are required.

2. **Log Initialization**:
   The script initializes logging by redirecting all outputs to `/var/log/user_management.log`. This ensures that all activities are recorded for auditing purposes.

3. **Creating Secure Password Storage**:
   The script creates the directory `/var/secure` and the file `user_passwords.csv` to store generated passwords securely with appropriate permissions.

4. **Processing Input Files**:
   The script processes each provided file, line by line, to create users and assign them to groups.

   - **User Creation**:
     - If the user already exists, the script logs the event and skips to the next user.
     - If the user does not exist, the script creates the user, generates a random password, sets the password, and logs the credentials in `user_passwords.csv`.

   - **Group Management**:
     - For each group listed for a user, the script checks if the group exists. If not, it creates the group.
     - The script then adds the user to the specified groups, logging the actions.

5. **Error Handling**:
   The script checks for the existence of input files and logs any errors encountered during execution.

## Example

### Input File Format

An example input file (`users_groups.txt`) might look like this:

```
johndoe;developers,admins
janedoe;users,managers
```

### Running the Script

```bash
sudo ./user_management.sh users_groups.txt
```

## Logging

All script activities are logged to `/var/log/user_management.log` for auditing purposes. Generated passwords are stored securely in `/var/secure/user_passwords.csv`.

## Additional Information

To learn more about similar projects and opportunities, check out the [HNG Internship](https://hng.tech/internship) and [HNG Hire](https://hng.tech/hire) websites.

---

For more detailed information and to explore premium features, visit [HNG Premium](https://hng.tech/premium).