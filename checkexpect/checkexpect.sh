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
