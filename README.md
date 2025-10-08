# Processing Command-Line Arguments

# Repository Objective

This repository has been created for the following purposes:

  1. to review and describe the design of command-line utilities of _getopts_ and _getopt_.

  2. to exemplify the use of long-form options using _getopts_ provide an example of command line processing that includes long-form options.

  3. to provide the alternative command-line utility, called {TBD}, that provides a more {insert adjective} utility

# Command Line Discussion

## Description of the Command Line

### Components of the Command Line
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
  1. command
  1. option
  1. short option:
  1. 