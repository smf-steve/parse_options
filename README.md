# Processing Command-Line Arguments

## Repository Objective

This repository has been created for the following purposes:

  1. to review and describe the design of command-line utilities of _getopts_.

  2. to provide an example of using long-form options via _getopts_ 

  1. to provide an example of command line processing that includes long-form options.

  3. to provide the alternative command-line utility, called {TBD}, that provides a more {insert adjective} utility


## Musing
  See [MUSING.md](MUSING.md) to see my current thinking.

---

Below is a work-in-progress framing of the future README.md file



## Command Line Discussion


## Utilities for Command-line Processing

  * getopts: a bash builtin utility
    * Benefits:
      - processing of condense options: e.g., -xdf file or -xdffile
      - effectively canonicalizes the options for the program: -x -d -f file
      - performs error checking and reporting
    * Detriments
      - you can't have options with optional arguments as does getopt
      - does not easily support multi-character options, e.g., --banner
      - the -f options are referenced in the code as "f"
        - the --banner would be referenced in the code as -banner


   * getopt: a gnu utility
      - Benefits:
        - leverages getopts for short options
          - adds the ability to do optional arguments -- but such an argument MUST be connected to the option:  e.g. -dfile but not -d file
        - add support for multi-character options
        - multi-character options can have optional arguments
          - but MUST also be connected to the option via an '='
        - user code refers to the --banner or -flag in the program
        - Long options may be abbreviated, as long as the abbreviation is not ambiguous.
          - BUT what about backward compatibility if additional options are created

      - Detriments
        - attempt to "shuffle" the arguments
          - hence command with subcommands don't work well
            - getopt "C:a" git -C . commit -a
        - even though handles multi-character options,
          * program's code still must manage which have arguments or not
            - (My getops with --banner support address this by the introduction of the OPTVALUE variable)

      - Notes:
        * supports alternative presentation of long options which begin with a single "-"
        * Shuffling of args can be turned off... with the use of a + 
          - does it, what value is there in shuffling
          - +, - as the first character in the shortops, but with the correct usage
            - getopts -o "+d::" -- params
              ```
              $ getopt -o "+xd::" --  -xd one done -xdtwo -dthree -d four -x arg1
                 -x -d '' -- 'one' 'done' '-xdtwo' '-dthree' '-d' 'four' '-x' 'arg1'

              $ getopt "xd::"  -xd one done -xdtwo -dthree -d four -x arg1
                 -x -d  -x -d two -d three -d  -x -- one done four arg1
              ```
            - notice the extract of the first -d, no shuffle
         

        * If the option has an optional argument, it must be written directly after the long option name, separated by '=', if present (if you add the '=' but nothing behind it, it is interpreted as if no argument was present; this is a slight bug, see the BUGS)
          - I.e.,  --banner=  is determined to be a "slight bug"
          - Note   --banner='' is equivalent to --banner=
            - Possible change, is if you can define a default
              -  --banner='${default}'  -->  --banner '${default}'
              -  --banner='${lambda}'  -->  --banner '${lambda}'

        * Each parameter not starting with a '-', and not a required argument of a previous option, is a non-option parameter.  
          - hence   -f -file    , -file is deemed to be a non-option parameter
          - this is the difference between gnu getopts definition and mine. 


  * getopt: a bash utility that standardize the presentation of command-line options
    * Definition of an option
      - a word that is proceed by a hyphen (-), and is not exactly '-' or '--'
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



### Description of the Command Line

#### Components of the Command Line


#### Dictionary
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

## References

  * man page for getopts:
    - https://linuxcommandlibrary.com/man/getopts
    -  A leading colon `:` in `optstring` enables "silent error reporting", preventing `getopts` from printing error messages for unknown options or missing arguments; 
  * man page for getopt(3)
    - https://linux.die.net/man/3/getopt
    * Note this is a C lib
 
   * man page for GNUs-getopt

   * https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/

   * https://kodekloud.com/blog/bash-getopts/

   * https://www.gnu.org/software/gawk/manual/gawk.html#Processing-Command_002dLine-Options
   10.4 Processing Command-Line Options