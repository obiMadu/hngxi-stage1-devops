#!/bin/bash

touch /var/log/user_management.log &> /dev/null

if [ $? -eq 1 ]; then
    echo "Script must be run as superuser!"
    exit 1
fi

# check that file argument(s) was provided
if [ $# -eq 0 ]; then
    echo "Provide at least one user;groups file"
    exit 1
fi

# redirect all outputs going forward to /var/log/user_management.log
exec > /var/log/user_management.log 2>&1

# create /var/secure/user_passwords.csv
mkdir -p /var/secure
touch /var/secure/user_passwords.csv
chmod 600 /var/secure/user_passwords.csv
echo "" > /var/secure/user_passwords.csv

# loop through provide files
for file in $@; do 
    # check if file exists
    if [ -f "$file" ]; then
        # loop through each line in file
        while read line; do
            # get username
            user=$(echo "$line" | awk '{print $1}')
            user=${user%;}

            # check if user exists
            userExists=$(grep "$user" /etc/passwd | wc -l)
            if [ $userExists -ge 1 ]; then
                echo "user $user already exists, skipping..." 
                echo "$user,password_not_changed" >> /var/secure/user_passwords.csv
            else
                useradd -s /bin/bash -d /home/$user -m -g $user $user
                if [ $? -eq 0 ]; then
                    echo "generating new password for user $user"
                    password=$(date +%s%N | md5sum | head -c 32)
                    echo -e "$password\n$password" | passwd $user
                    sleep 1
                    echo "user $user created successfully with password"
                    passHash=$(grep $user /etc/shadow | awk '{print $2}')
                    echo "$user,$passHash" >> /var/secure/user_passwords.csv
                else
                    echo "failed to create user $user, check the logs..."
                    continue
                fi
            fi
            
            # retrieve user groups
            groups=$(echo "$line" | awk '{print $2}')

            # make group list an array
            IFS=','
            read -ra items <<< $groups

            # iterate over each group
            for group in "${items[@]}"; do

                # check if group exists, and create/add
                groupExists=$(grep "$group" /etc/group | wc -l)
                if [ $groupExists -ge 1 ]; then
                    echo "group $group already exists"
                    usermod -aG $group $user
                    echo "added user $user to group $group"
                else
                    echo "group $group doesn't exist, creating it..."
                    groupadd $group
                    echo "created group $group"
                    usermod -aG $group $user
                    echo "added user $user to group $group"
                fi
            done

            # visually seperate each user;group run
            echo "***********"

        done < $file
    else #throw an error if file does not exist
        echo "$file does not exist!"
        exit 1
    fi
done