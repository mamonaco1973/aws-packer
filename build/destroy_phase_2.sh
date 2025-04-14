
#!/bin/bash

cd 01-infrastructure

terraform init
terraform destroy -auto-approve
cd ..

