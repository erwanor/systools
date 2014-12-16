# Systools
====

## Systools is a collection of administration tools written in Bash for GNU Linux. 

## Summary

* compcrypt.sh:
* checkexpect.sh:
* setperm.sh:
* vhostgen.sh:

### Usage:

#### compcrypt.sh

`compcrypt.sh -ce /path/to/target`

You will first need to generate a (private, public) key. You can do that by firing:
`gpg --gen-key`

###Contribute:
Feel free to contribute whether it is by creating an issue, asking for an enhancement or making a pull request.

We follow Google's Bash styleguide. I encourage you to read it first before making any pull request: 

https://google-styleguide.googlecode.com/svn/trunk/shell.xml

Todo list:

* checkexpect.sh
   * Implement recursive check of checkexpect: i.e the function should be able to test itself.
   * Handle array as arguments for function that have more than accept more than one parameter
