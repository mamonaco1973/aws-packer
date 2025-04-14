#!/bin/bash

# List all files and directories in the /flask directory with detailed information (long listing format)
# including file permissions, ownership, size, and modification date.
ls -al /flask

# Change the permissions of the script `start_flask_app.sh` in the /flask directory to make it executable.
# The `+x` flag ensures the script can be run as a program.
chmod +x /flask/start_flask_app.sh

# Install the Python 3 pip package manager using the Amazon Linux package manager `yum`.
# The `-y` flag automatically answers "yes" to any prompts, ensuring a non-interactive installation.
sudo yum install -y python3-pip stress dos2unix

# Even out any windows LF issues

dos2unix /flask/start_flask_app.sh
dos2unix /flask/app.py
dos2unix /flask/test_candidates.py

# Install the Python dependencies listed in the `requirements.txt` file located in the /flask directory.
# `pip3` refers to the Python 3 version of pip. The `-r` flag specifies the requirements file.
sudo pip3 install -r /flask/requirements.txt

# Copy the systemd service file `flask_app.service` from the /flask directory to the
# /etc/systemd/system directory, which is the location for user-defined service unit files.
sudo cp /flask/flask_app.service /etc/systemd/system/flask_app.service

# Reload the systemd daemon to recognize the new or updated service file.
# This ensures systemd is aware of changes to service configurations.
sudo systemctl daemon-reload

# Enable the `flask_app` service to start automatically at boot.
# This creates symbolic links for the service in the appropriate systemd directories.
sudo systemctl enable flask_app

# Start the `flask_app` service immediately without waiting for a reboot.
# This activates the service and runs it in the foreground.
sudo systemctl start flask_app

# Display the current status of the `flask_app` service, including its running state, PID, memory usage,
# and any error messages or logs. This helps verify that the service started successfully.
sudo systemctl status flask_app

# Start SSM if you need to connect to this EC2 instance to check on things.
sudo systemctl enable amazon-ssm-agent

