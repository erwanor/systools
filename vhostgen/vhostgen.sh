#!/bin/bash

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
debug="0"
#############

# CheckDomain string
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

# CheckDirectory $string
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

# EscapeDirectory string
# Escape slashes from $string to make it usable by sed
function EscapeDirectory(){
  echo "$1" > tmp.in
  directory=$(sed 's@/@\\\/@g' tmp.in)
  rm tmp.in
  echo "$directory"
}

# Sanitize string
# Escape all non-alphanumerical characters

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
  #@ CheckDirectory
    CheckExpect CheckDirectory "/home" "1"
    CheckExpect CheckDirectory "" "1" # When input is empty the default value taken is "." i.e current directory
    CheckExpect CheckDirectory "/home/foobar" "0"
  #@ EscapeDirectory
    CheckExpect EscapeDirectory "/home" "\/home"
    CheckExpect EscapeDirectory "/home/foobar/" "\/home\/foobar\/"
    CheckExpect EscapeDirectory "/" "\/"
fi
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
