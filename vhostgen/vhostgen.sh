#!/bin/bash

############################
#        By adnorth        #
#           2014           #
#       MIT LICENSE        #
############################

# The purpose of this script is to allow the generation of subdomains using Namecheap API (c) and Apache2

##############CONFIGURATION INFORMATIONS###############
vhost_directory="/etc/apache2/sites-available/"
config_dir="/home/user/tools/vhostgen/config"
subdomain=$1
serverpath=$2

##############NAMECHEAP INFORMATIONS###################
api_user=""
api_key=""
nc_user=""
client_ip=""
target_ip=""
domain_sld=""
domain_tld=""

#############DEBUG INFORMATIONS#########################
debug="0"
if [ "$3" = "-d" ]; then debug="1" fi

# CheckDomain string -> boolean
# Check if $string is an allowed domain name (alphanumerical characters)(dot)(alpha characters)
function CheckDomain(){
  echo $1 > $config_dir/in.tmp
  input=$(grep -P '^[a-zA-Z0-9]*[.][a-zA-Z]*$' $config_dir/in.tmp)
  rm $config_dir/in.tmp
  if [ -z "$input" ]
  then
    if [ "$debug" = "1" ]
    then
      echo "0"
    else
      echo "incorrect domain name"
    fi
  elif [ "$input" = "$1" ]
  then
    echo "1"
  fi
}

# CheckDirectory $string -> boolean
# Check if $string is an existing directory
function CheckDirectory(){
  if [ -d $1 ]
  then
    echo "1"
  else
    if [ "$debug" = "0" ]
    then
      echo "0"
    else
      echo "directory does not exist"
    fi
  fi
}

# EscapeDirectory string -> string
# Escape slashes from $string to make it usable by sed
function EscapeDirectory(){
  echo "$1" > tmp.in
  directory=$(sed 's@/@\\\/@g' tmp.in)
  rm tmp.in
  echo "$directory"
}

# Sanitize string -> string
# Escape all non-alphanumerical characters

# CheckAPI string -> boolean
# Check validity of Namecheap API Key
: 'function CheckAPI(){
  api_command="namecheap.domains.getList"
  call="https://api.namecheap.com/xml.response?ApiUser=$api_user&ApiKey=$api_key&UserName=$nc_user&ClientIp=$client_ip&Command=$api_command"
  output= curl $call
  echo $output
}'

# AddRecord string , string -> boolean
# Add subdomain to host records
function SetRecord(){
  api_command="namecheap.domains.dns.setHosts"
  call="http://api.namecheap.com/xml.response?apiuser=$nc_user&apikey=$api_key&username=$nc_user&Command=$api_command&ClientIp=$client_ip&SLD=$domain_sld&TLD=$domain_tld"

  # Namecheap overwrite all the DNS Hosts records by default
  # Afaik there is no way to avoid to overwrite everything, everytime we create a new host. To counter this side effect, we will store all our host records and generate a query when needed

  if grep -q $subdomain "$config_dir/hosts"; then if [ "$debug" = "1" ]; then echo "0"; else echo "subdomain exist already"; exit 0; fi fi
  numberOfRecords=$(cat "$config_dir/hosts" | wc -l)
  if [ $numberOfRecords -ge 10 ]; then if [ "$debug" = "1" ]; then echo "0"; else echo "There is too many subdomains"; exit 0; fi fi
  cursor=1
  while [ $cursor -le $numberOfRecords ]; do
    line=$cursor"p"
    path="$config_dir/hosts"
    call+="&HostName$cursor=$(sed -n $line $path)&RecordType$cursor=A&Address$cursor=$target_ip"
    ((cursor++))
  done
  ((cursor++))
  call+="&HostName$cursor=$subdomain&RecordType$cursor=A&Address$cursor=$target_ip"
  output= curl $call>$config_dir/tmp.xml
  success="OK"
  if grep -q $success $config_dir/tmp.xml
  then
    echo ""
    echo "$subdomain">>"$config_dir/hosts"
    echo "record successfully create: $subdomain.$domain_sld.$domain_tld is now available"
    rm $config_dir/tmp.xml
  else
    rm $config_dir/tmp.xml
    echo "0"
    if [ "$debug" = "1" ]; then
      echo $output>>"$config_dir/api_outputs.log"
      echo "API Call failed please contact admin"
    fi
  fi
}

# Xml parser
# by chad on stackoverflow.com
: 'function read_xml(){
  local IFS=\>
  read -d \< ENTITY CONTENT
  local ret=$?
  TAG_NAME=${ENTITY%% *}
  ATTRIBUTES=${ENTITY#* }
  return $ret
}

function parse_dom () {
  if [[ $TAG_NAME = "foo" ]] ; then
    eval local $ATTRIBUTES

  echo "foo size is: $size"

  elif [[ $TAG_NAME = "bar" ]] ; then
    eval local $ATTRIBUTES
    echo "bar type is: $type"
  fi
}

function xml_wrapper(){
  while read_dom; do
        parse_dom
    done
}'

# CheckExpect function input output
# Test a function output
function CheckExpect(){
  if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] && [ "$1" != "CheckDirectory" ]
  then
    echo "usage: CheckExpect function inputToFunction outputOfFunction"
  fi
  output=$($1 $2)
  if [ "$output" = "$3" ]
  then
    echo -ne "\e[1;32;40mSUCCESS:  "
    echo -e "\e[0;37;40m$1($2):\e[0m"
    echo -e "\e[1;33;40m SUPPOSED OUTPUT: $3\e[0m"
    echo -e "\e[1;33;40m OUTPUT: $output\e[0m"
    return 1
  else
    echo -ne "\e[1;31;40mFAILURE:  "
    echo -e "\e[0;37;40m$1($2):\e[0m"
    echo -e "\e[1;33;40m SUPPOSED OUTPUT: $3\e[0m"
    echo -e "\e[1;33;40m OUTPUT: $output\e[0m"
    return 0
  fi
}

SetRecord

if [ "CheckDomain "$subdomain"" = "1" ] || [ "CheckDirectory "$serverpath"" = "1" ]
then
  echo "vhostgen usage: vhostgen domain.tld /path/to/public/directory"
  exit 0;
else
  serverpath=$(EscapeDirectory $serverpath)
  echo $serverpath
  cp -v "$config_dir/default" "$vhost_directory/$subdomain.$domain_sld.$domain_tld"
  sed s@"defaultdomain"@$subdomain.$domain_sld.$domain_tld@ $vhost_directory/$subdomain.$domain_sld.$domain_tld > $vhost_directory/$subdomain.tmp && mv $vhost_directory/$subdomain.tmp $vhost_directory/$subdomain.$domain_sld.$domain_tld
  sed s@"defaultpath"@$serverpath@ $vhost_directory/$subdomain.$domain_sld.$domain_tld > $vhost_directory/$subdomain.tmp && mv $vhost_directory/$subdomain.tmp $vhost_directory/$subdomain.$domain_sld.$domain_tld
  a2ensite $subdomain.$domain_sld.$domain_tld
fi

#@ Tests:
if [ "$debug" = "1" ]
then
  #@ CheckDomain
    CheckExpect CheckDomain "test.com" 1
    CheckExpect CheckDomain "1234567.com" "1"
    CheckExpect CheckDomain "abc123.com" "1"
    CheckExpect CheckDomain "test..com" "0"
    CheckExpect CheckDomain "test_.com" "0"
    CheckExpect CheckDomain "1234567..com" "0"
    CheckExpect CheckDomain "1234567.1234" "0"
  #@
  #@ CheckDirectory
    CheckExpect CheckDirectory "/home" "1"
    CheckExpect CheckDirectory "" "1" # When input is empty the default value taken is "." i.e current directory
    CheckExpect CheckDirectory "/home/foobar" "0"
  #@
  #@ EscapeDirectory
    CheckExpect EscapeDirectory "/home" "\/home"
    CheckExpect EscapeDirectory "/home/foobar/" "\/home\/foobar\/"
    CheckExpect EscapeDirectory "/" "\/"
  #@
fi
#@

exit 0
