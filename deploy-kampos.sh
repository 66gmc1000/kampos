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

# check if jq is installed or not
sudo apt install jq -y

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
sleep 120

# run the ansible job against the VPS
sudo ansible-playbook -i ansible/inventory --key-file="./ansible-key" ansible/site.yml 

# set ip to variable
kampos=$(terraform output ip)

# warm up the site then sleep
curl "http://$kampos"
sleep 30

# echo out ip address to connect to
echo "Connect to the kampos vps using the IP address below"
echo $kampos

uri=$(echo "http://"$kampos"/api2/auth-token/")

# get an auth token (default creds - its a throw away)
rawtoken=$(curl -d "username=me@example.com&password=asecret" $uri)

# parse token
token=$(echo $rawtoken | jq -r '.token')

header=$(echo "Authorization: Token $token")

# get default repo
rawrepo=$(curl -X 'POST' -H "$header" "http://$kampos/api2/default-repo/")

# parse repo
repo_id=$(echo $rawrepo | jq -r '.repo_id')

# get upload link
rawupload_link=$(curl -H "$header" "http://$kampos/api2/repos/$repo_id/upload-link/")

# trim output
cleanupload_link=$(echo $rawupload_link | cut -d '/' -f 6 | cut -d '"' -f 1)

# build working link
upload_link=$(echo http://$kampos:8082/upload-api/$cleanupload_link)

# create dirs
for i in pdfs images docs videos keepass powershell
do
   curl -d "operation=mkdir" -v -H "$header" -H 'Accept: application/json' "http://$kampos/api2/repos/$repo_id/dir/?p=/$i"
done

cd ~

# search and upload pdfs
find . -iname '*.pdf' -exec curl -H "$header" -F file=@{} -F parent_dir=/pdfs/ -F replace=1 "$upload_link" \; 

# search and upload images
find . -type f \( -name "*.jpg" -o -name "*.jpeg" \) -exec curl -H "$header" -F file=@{} -F parent_dir=/images/ -F replace=1 "$upload_link" \;

# search and upload office docs
find . -type f \( -name "*.doc" -o -name "*.docx" -o -name "*.xls" -o -name "*.xlsx" -o -name "*.ppt" -o -name "*.pptx" \) -exec curl -H "$header" -F file=@{} -F parent_dir=/docs/ -F replace=1 "$upload_link" \;

# search and upload keepass dbs
find . -iname '*.kdbx' -exec curl -X POST -H "$header" -F file=@{} -F parent_dir=/keepass/ -F replace=1 "$upload_link" \; 

# search and upload keepass dbs
find . -iname '*.ps1' -exec curl -H "$header" -F file=@{} -F parent_dir=/powershell/ -F replace=1 "$upload_link" \; 


# # echo command to upload via api
# echo "Upload single file to /docs"
# echo $(curl -H "$header" -F file=@{} -F parent_dir=/docs/ -F replace=1 "$upload_link")

# # echo command to upload via api
# echo "Find and upload multiple extension types to /docs"
# echo $(find . -type f \( -name "*.doc" -o -name "*.docx" -o -name "*.xls" -o -name "*.xlsx" -o -name "*.ppt" -o -name "*.pptx" \) -exec curl -H "$header" -F file=@{} -F parent_dir=/docs/ -F replace=1 "$upload_link")

# # echo command to upload via api
# echo "create a folder called /newfolder"
# echo $(curl -d "operation=mkdir" -v -H "$header" -H 'Accept: application/json' "http://$kampos/api2/repos/$repo_id/dir/?p=/newfolder")

http://144.202.89.110/api2/repos/f9305e3c-5f82-41ff-be7e-a80ce98535e8/dir/?p=//images
