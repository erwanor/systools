# Systools
====

**Systools is a collection of administration tools written in Bash for GNU Linux.**

## Summary

* compcrypt.sh: generate encrypted backups. 
* setperm.sh: set appropriate permissions for web directories
* checkexpect.sh: easy unit-testing in Bash
* vhostgen.sh: Generate Apache2 virtualhost and create a subdomain using Namecheap API. 

### Usage:

#### compcrypt.sh

```
  compcrypt.sh -ce /path/to/target
  -c : compress encrypted archive
  -e : decrypt and extract data
  
  expected output:
    success: ${target%.*} is a clear directory
    or
    success: $target.gsa is an encrypted archive
```

You will first need to generate a (private, public) key and set the variable GPG.
`gpg --gen-key`

#### setperm.sh

```
  setperm.sh /absolute/path/to/directory
  
  expected output:
    I've done my job now get me money $USER
```

#### checkexpect.sh

```
  CheckExpect function inputToFunction outputOfFunction
```

#### setperm.sh

###Contribute:
Feel free to contribute whether it is by creating an issue, asking for an enhancement or making a pull request.

We follow Google's Bash styleguide. I encourage you to read it first before making any pull request: 

https://google-styleguide.googlecode.com/svn/trunk/shell.xml

Todo list:

* checkexpect.sh
   * Implement recursive check of checkexpect: i.e the function should be able to test itself.
   * Handle array as arguments for function that have more than accept more than one parameter
