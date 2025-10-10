# Processing Command-Line Arguments

# Repository Objective

This repository has been created for the following purposes:

  1. to review and describe the design of command-line utilities of _getopts_.

  2. to provide an example of using long-form options via _getopts_ 

  1. to provide an example of command line processing that includes long-form options.

  3. to provide the alternative command-line utility, called {TBD}, that provides a more {insert adjective} utility


# Command Line Discussion


# Utilities for Command-line Processing

  * getopts: a bash builtin utility


  * getopt: a bash utility that standardize the presentation of command-line options
    * Definition of an option
      - a word that is proceed by a hypen (-), and is not exactly '-' or '--'
        * such a word may contain more than one option
        * such a word may have a suffix which is the argument to the last option
        * a valid option is denoted by being included within the optstring
        * a valid option is determined to have an argument if it is followed by a colon (:) within the optstring
    * getopt Usage:         getopt "optstring" {args}
    * Sample Command Line:  "command -a -o value -b arg1 -x"
    * Example Usage:        ans=$(getopt "abo:c" -acovalue -b arg1 -x)
    * Process:
      - scans the command line until it finds the first non-option argument
      - validates that each option is valid
      - separates a string of options into single options
        * e.g., "-abc" --> "-a -b -c"
      - separates an option from its argument
         * e.g., "-otest" -> -o test
      - inserts "--" place after the _first_ non-option identified
    * Example Result:       ans == -a -c -o value -b -- arg1 -x



## Description of the Command Line

### Components of the Command Line

### Dictionary
  1. word:
     - A sequence of characters considered as a single unit by the shell.  Also know as a token.

  1. control operator
     - A token that performs a control function.  It is one of the following symbols:
              || & && ; ;; ;& ;;& ( ) | |& <newline>

  1. parameters:
     - a sequence of words terminated by a control operator 

     - parameters can be identified as ${0}, ${1}, ... ${!#}

  1. command
     - the first parameter, i.e., ${0}

  1. option
     - a word that begins with a "-" or a "+"
     - e.g.,  -a

  1. flag
     * -
     * 
  1. option
     flag followed be a sequence of characters

  1. short option:
     - an option that contains a sequence 
     - syntax:
       *  -{char} [option]
       *  -{char}[option]

  1. short option sequence
     - syntax
       *  -{char}+ [option]
       * -{char}+[option]

  1. long option:
     - an option that 
     - syntax
       * --{name} [{value}]
       * --{name}={value}
     - technical its
       * -{-name} [{value}]
       * -{-name}={value}

# References

  * man page for getopts:
    - https://linuxcommandlibrary.com/man/getopts
    -  A leading colon `:` in `optstring` enables "silent error reporting", preventing `getopts` from printing error messages for unknown options or missing arguments; 
  * man page for getopt(3)
    - https://linux.die.net/man/3/getopt
    * Note this is a C lib
 
   * man page for GNUs-getopt

   * https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
