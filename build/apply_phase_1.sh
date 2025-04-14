#!/bin/bash

# First phase - Build all the infrastructure with 0 autoscaling instances and a generic AMI

cd 01-infrastructure
echo "NOTE: Building infrastructure phase 1."
terraform init
terraform apply -var="asg_instances=0" -auto-approve
cd ..