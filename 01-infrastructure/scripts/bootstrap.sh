#!/bin/sh

# Check if /flask does not exist
# If /flask doesn't exist assume we are running with a generic
# Amazon Linux image and install apache on port 8000 so that
# ALB health checks will pass and everything will initialize properly.

if [ ! -d "/flask" ]; then
    # Install Apache HTTP Server
    yum install httpd -y

    # Create a dummy landing page
    echo "Dummy landing page on host " > /var/www/html/index.html
    hostname >> /var/www/html/index.html
    
    # Create a dummy directory so that /gtg health check will succeed
    mkdir /var/www/html/gtg
    
    # Update Apache configuration to listen on port 8000
    sed -i 's/^Listen 80$/Listen 8000/' /etc/httpd/conf/httpd.conf

    # Enable and start Apache service
    systemctl enable httpd
    systemctl start httpd

# If /flash exists assume we are running the flask-app AMI and that the 
# "flask-app" service has been installed.
# Get status of flask_app service.

else
    echo "/flask directory exists. Script will not run." >> /tmp/userdata.log
    systemctl status flask_app
fi