#!/bin/bash

# ./destroy-kampos.sh --apikey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

for i in "$@"
do
    case $i in
        --apikey=*)
            API="${i#*=}"
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

# app check
terraform=$(which terraform)

# execute terraform job to destroy vps
$terraform init terraform
$terraform destroy -var api_key=${API} terraform

# echo out ip address to connect to
echo "VPS, sshkey, firewall rules and all other associated resources have been destroyed"

