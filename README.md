///////////////////////////////////////////
in this project i manually setup conf and inventory file 
in the inventory file we can attach control node ip ddress and worker node ip address. i took my laptop has my control node. also give me the server details
and also i used seperate env for ansible because all the dependency and libery here . 

cd terrraform
using code and create infra. statefile store in backend setup for s3. using dynamo LockID .
terraform init
terraform validate
terraform plan -var-file=".tfvars"
terraform apply -var-file=".tfvars"
terraform destroy -var-file=".tfvars"

cd ansible
ansible all -m ping
# Create the virtual environment
python3 -m venv ansible_env
source ~/ansible_env/bin/activate
(exit-deactivate)
ansible-playbook swarm.yaml
/////////////////////////////////////////////
