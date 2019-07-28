#!/bin/bash

# ./deploy-kampos.sh --apikey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --hostname=kampos

for i in "$@"
do
    case $i in
        --apikey=*)
            API="${i#*=}"
            ;;
        --hostname=*)
            HOSTNAME="${i#*=}"
            ;;
    esac
done

# check if terraform is installed or not
if [[ -z "$(type terraform)" ]]; then
  read -p "Terraform is not installed. Press [Enter] to install now..."
  sudo apt-get install unzip
  mkdir temp
  cd temp
  wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip
  unzip terraform_0.12.2_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  cd ..
  rm -rf temp
  terraform
fi

# check if ansible is installed or not
if [[ -z "$(sudo ansible-playbook)" ]]; then
  read -p "Ansible is not installed. Press [Enter] to install now..."
  sudo apt install software-properties-common
  sudo apt-add-repository ppa:ansible/ansible -y
  sudo apt update
  sudo apt install ansible -y
fi

# app check
terraform=$(which terraform)
ansible=$(which ansible-playbook)

# create ssh key for new VPS (required by ansible)
ssh-keygen -t rsa -b 4096 -f ./ansible-key -N ''

# execute terraform job to bring up vps
terraform init terraform
terraform apply -input=false -auto-approve -var api_key=${API} -var host_name=${HOSTNAME} -var ssh_key="$(cat ./ansible-key.pub)" terraform

# create wordpress line in ansible inventory
echo '[kampos]' > ansible/inventory

# create IP entry for wordpress server in ansible inventory
terraform output ip | sed -e 's/,$//' >> ansible/inventory

# give slower boxes a chance to finish the python install
sleep 90

# run the ansible job against the VPS
sudo ansible-playbook -i ansible/inventory --key-file="./ansible-key" ansible/site.yml 

# echo out ip address to connect to
echo "Connect to the kampos vps using the IP address below"
terraform output ip