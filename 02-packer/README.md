## Packer Build Configuration Summary

### **Purpose**
- Builds an Amazon Machine Image (AMI) for a Flask server, with pre-configured settings and provisioning.

### **Packer Configuration**
- **Required Plugins**:
  - `amazon`: For building Amazon AMIs (`~> 1` version).

### **Input Variables**
- **Region**: Defaults to `us-east-2`.
- **Instance Type**: Defaults to `t2.micro`.
- **VPC ID**: VPC for the instance (default is empty, should be replaced with actual ID).
- **Subnet ID**: Subnet for the instance (default is empty, should be replaced with actual ID).

### **Source AMI**
- **Data Source**: Amazon Linux 2023 AMI:
  - Filters: `al2023-ami-2023*x86_64`, EBS-backed, HVM virtualization.
  - Owner: `amazon`.
  - Selects the **most recent** AMI matching the filters.

### **Amazon EBS Source Configuration**
- **AMI Name**: Dynamically named `flask_server_ami_<timestamp>` (timestamp formatted to replace `:` with `-`).
- **Region**: Uses the `region` variable.
- **Instance Type**: Uses the `instance_type` variable.
- **Source AMI**: Retrieved from the Amazon Linux 2023 base image.
- **SSH Configuration**:
  - Username: `ec2-user`.
  - Interface: `public_ip`.
- **VPC and Subnet**: Configurable via `vpc_id` and `subnet_id` variables.

### **Provisioning Steps**
1. **Shell Provisioner**:
   - Creates a `/flask` directory and grants write permissions.
2. **File Provisioner**:
   - Copies the contents of the `./scripts/` directory to `/flask/` on the instance.
3. **Shell Script**:
   - Executes the `./install.sh` script to install necessary dependencies or configure the Flask server.

### **Build Configuration**
- Creates a new AMI using the `amazon-ebs` source configuration and applies the defined provisioning steps.

### **Output**
- A customized AMI ready for Flask deployment with pre-installed scripts and permissions set up.

This Packer configuration ensures a reproducible AMI for Flask applications based on Amazon Linux 2023, with flexibility for different VPC and subnet configurations.
