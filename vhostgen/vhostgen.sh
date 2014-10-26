#!/bin/bash

# TODO:
: '
IMPORTANT::::: 1. Before commiting changes erase API KEYS values
2. write xml_read function
3. Include a debug condition in Namecheap API functions
a) check if everything was good using read xml
b) if everything was good and we are not debugging then output 1
c) if we are on debugging and something went wrong then print XML error code + output error
d) if something went wrong and not on debuging then just output 0
4) Write a Sanitize function
5) Generate Apache2 virtualhost

6) BUG: When add a new record with SetRecord
a) make sure this record doesnt exist already
b) handle the fact that the whole record is overwritten'

############################
#        By adnorth        #
#           2014           #
#       MIT LICENSE        #
############################

# The purpose of this script is to allow the generation of subdomains using Namecheap API (c) and Apache2

# To be deleted
vhost_directory="/home/ad/tools/vhostgen/sites-available"
config_dir="/home/ad/tools/vhostgen/config"
subdomain=$1
serverpath=$2
debug="1"
api_user="waterfrog"
api_key="aa8d4586d58042efbb61ea4e117a477d"
nc_user="waterfrog"
client_ip="104.131.51.237"
target_ip="104.131.51.237"
domain_sld="rely"
domain_tld="io"
#############

# CheckDomain string -> boolean
# Check if $string is an allowed domain name (alphanumerical characters)(dot)(alpha characters)
function CheckDomain(){
  echo $1 > in.tmp
  input=$(grep -P '^[a-zA-Z0-9]*[.][a-zA-Z]*$' in.tmp)
  rm in.tmp
  if [ -z "$input" ]
  then
    if [ "$debug" = 0 ]
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
function CheckAPI(){
  api_command="namecheap.domains.getList"
  call="https://api.sandbox.namecheap.com/xml.response?ApiUser=$api_user&ApiKey=$api_key&UserName=$nc_user&ClientIp=$client_ip&Command=$api_command"
  read_xml "curl $call"
}

# AddRecord string , string -> boolean
# Add subdomain to host records
: 'function SetRecord(){
  api_command="namecheap.domains.dns.setHosts"
  call="http://api.namecheap.com/xml.response?apiuser=$nc_user&apikey=$api_key&username=$nc_user&Command=$api_command&ClientIp=$client_ip&SLD=$domain_sld&TLD=$domain_tld&HostName1=$subdomain&RecordType1=A&Address1=$target_ip"
  output="curl $call"
}'

# Xml parser
# User: chad on stackoverflow.com
function read_xml(){
  file="$1"
  local IFS="\>"
  read -d \> ENTITY CONTENT
  while read_dom; do
    echo "$ENTITY => $CONTENT"
  done<$file
}

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

#@ Tests:
if [ "$debug" = "0" ]
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

SetRecord "test"
: '
if CheckDomain "$subdomain" || CheckDirectory "$serverpath"
then
  echo "vhostgen usage: vhostgen domain.tld /path/to/public/directory"
  exit 0;
else
  cp -v "$config_dir/default" "$vhost_directory/$subdomain"
  sed s@"defaultdomain"@$subdomain@ $vhost_directory/$subdomain > $vhost_directory/$subdomain.tmp && mv $vhost_directory/$subdomain.tmp $vhost_directory/$subdomain
  sed s@"defaultpath"@$serverpath@ $vhost_directory/$subdomain > $vhost_directory/$subdomain.tmp && mv $vhost_directory/$subdomain.tmp $vhost_directory/$subdomain
fi'
