# MUSINGS

This file contains my musing and my notes as I think through what I want 
to accomplish in this repo.  Some parts of this file should be consider more
akin to notes taken during a class lecture as to opposed to well structured thoughts.

Over time, these musing should be transformed more into use notes.

As of 

# Next Steps/Work
  1. muse some more
  1. finish working on fictitious, an examplar for using getopts
  1. create a version of fictitious, as an examplar for using getopt
  1. reframe parse_option to be self_example.bash
     - use lessons learns to couch the program similar to the use of getopts/getopt
  1. create TDB specification for man git
  -
  1. Of course continually cleanup and document


# Current Recap
  1. getopts:
     - nice utility to simplify the use of condensed options -lst, as opposed to -l -s -t
     - its a hack to use the tool to use long options, e.g., --long value
     - views the option's name as the string _after_ the first hyphen (-)
       * given: -s and --long, the names are s and -long, respectively
     - the programmer's switch/case statement refers to these names, and special code is need for long options


     // ## getopts optstring flag [args]
     // ### optstring notes:
     // 
     //   - OPTSTRING="xy"   | two options without values
     //   - OPTSTRING="x:y"  | option x with value and option y without a value
     //   - OPTSTRING="x:y:" | both x and you has values
     // 
     //   - OPTSTRING=":x:y" | define the special char :, when an opt that is expected is missing
     //     
     //   - OPSTRING="x::"   | technically not supported, x has an option value
     // 
     // 
     // ### flag
     //    - one of the characters in OPTSTRING
     //    - : the special char to denote a option that requires a value does not
     //      * OPTARG contains the incomplete option
     //    - ? the special char to denote we say an invalid option, 
     //      * OPTARG contains the invalid option
     //    - + | - 

   - getup as a hack can do the same thing as getopt, but...

   - it is clear that getopt is an attempt to improve getopts
      * while getopts .... ; do 
      * args=$(getopt ....) ; 
        for i in $args  ; do


  1. Different programming approaches when using getopts
     1. Hypen "-" used to introduce long-form options, with Programmer parsing the "="
        ```bash
      
        : "set -- $args"
        while getopts -: option ; do
          case "${option}" in
            ( - ) case "${OPTARG}" in
                    ( init_file=* ) 
                      : programmer separates the argument
                      ARG=${OPTARG#init_file=}
                    ;;
                    ( init_file ) 
                      ARG=${!OPTIND} ; (( OPTIND++ ))
                    : ;;
                  esac
                  ;;
        ```
     1. With the splitting up an option base based upon an = 
        ```bash
         while getopts h489-: option ; do
           # case "${}option}${OPTARE}"     
           case "${option}" in
             ( -half ) : OPTARG="";;
             ( -some ) : OPTARG="value";;
             ( h )  roman_form_half_set FALSE   ;;
             ( 4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;;
             ( 8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;;
             ( 9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;;
           esac
       ``` 
     1. Introducing OPTNAME not including the - or --
        ```bash
        while getopts h489-: option ; do
          case "${OPTNAME}" in
            ( half ) : OPTARG="";;                # option == -
            ( some ) : OPTARG="value";;           # option == -
            ( h )  roman_form_half_set FALSE   ;; # option == h
            ( 4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;; # option == 4
            ( 8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;; # option == 8
            ( 9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;; # option == 9
          esac
        ```

     1. Introduction of OPTNAME that includes the OPTPREFIX, this seems more better
        ```bash
        while getopts h489-: option ; do
          case "${OPTNAME}" in
            ( --half ) : OPTARG="";;               # option == -
            ( --some ) : OPTARG="value";;          # option == -
            ( -h )  roman_form_half_set FALSE   ;; # option == h
            ( -4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;; # option == 4
            ( -8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;; # option == 8
            ( -9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;; # option == 9
          esac
        ```

   1. gnu getopt OPTSTRING notes
      - f:  denotes f has an associated value, -f value
      - f:: denotes f may have an associated value,  -f, -fvalue
      - initial character:
        * ":" : getopt returns ':' instead of '?'
        * "+" : scan stops after the first non-optional character
        * "-" : non-option parameter are outputted where they are found
        ```bash
        $ getopt -o "-C:a" -- -C . commit -a
        -C -C '.' 'commit' -a --
        $ getopt -o "+C:a" -- -C . commit -a
        -C '.' -- 'commit' '-a'

        ```
   1. getopt OPTSTRING
      - initial character:
        * ":" denotes silent mode


  1. getopt:
     - canonicalizes the presentation of options
     - leverage the getopts approach for support of condensed options
     - furthers error checking of missing arguments, etc., 
     - the naming of options is more using: i.e., its -l for -l and --long for --long
     - the programmer's switch/case statement is more uniform
       * moreover a single case pattern can more easily refer to both a long and short option
         ```bash
         ( -l | --list )   # place the code here associated
                           # with the here "list" option
         ```
     - the programmer's switch/case code falls into a recognized pattern

     - creates pairs of arguments for options that may and must have a requirement
       * '--option-require'  'value'  '--option-may' ''
       * but doesn't do this for those that DON't have an arg.
       * 'option-noarg'    '--option-require'  'value'  '--option-may' ''
       * should be
       * 'option-noarg' '' '--option-require'  'value'  '--option-may' ''


        // - getopt: a bash utility that standardize the presentation of command-line options
       //    * Definition of an option
       //      - a word that is proceed by a hypen (-), and is not exactly '-' or '--'
       //        * such a word may contain more than one option
       //        * such a word may have a suffix which is the argument to the last option
       //        * a valid option is denoted by being included within the optstring
       //        * a valid option is determined to have an argument if it is followed by a colon       // (:) within the optstring
       //    * getopt Usage:         getopt "optstring" {args}
       //    * Sample Command Line:  "command -a -o value -b arg1 -x"
       //    * Example Usage: 
       //      ```bash
       //      args=$(getopt "abo:c" -acovalue -b arg1 -x)
       //      returnval=$?
       //      set -- "$args"
       //      for i in $args ; do 
       //      ```
       //    * Process:
       //      - scans the command line until it finds the first non-option argument
       //      - validates that each option is valid
       //      - separates a string of options into single options
       //        * e.g., "-abc" --> "-a -b -c"
       //      - separates an option from its argument
       //         * e.g., "-otest" -> -o test
       //      - inserts "--" place after the _first_ non-option identified
       //    * Example Result:       ans == -a -c -o value -b -- arg1 -x


  1. clo: command line options

    I'm thinking of using compiler related approach to generate the code pattern for program.  This approach is based upon the tool "Lex/Flex". See clo_MUSING.md for my current thinking.

---

# Notes

  1. New utility
     1. No
        - Still not clear if a new utility is worth the benefits
        - It could be that
          * some standardized approaches to using getopt,
          * with a twist of thinking, and 
          * a standardize switch structure, processing two parameters at a time
        - would yield more readable code
     1. Yes
        - cleans up the "hack" used via the -- from the getopts approach
        - provides more unified environment names: OPT_PREFIX, OPT_VALUE, etc
        - treats "--" and "-" stdin more unifying

  1. The nomenclature for various things is both getopts and getopt is
     - not uniform
     - a bit muddle (especially when using getopts to mimic getopt)
     - the new tool use standardize these names in a more effective way
     - NOTE: much of the new nomenclature is being used as this repo is being fleshed out
     - Given:  
        | option        | -f value | --banner=value | 
        |---------------|----------|----------------|
        | name          | -f       | --banner       |
        | value         | value    | value          |
        | OPTPREFIX=    | -        | --             |
        | OPTNAME=      | -f       | --banner       | * Used in the code by the user
        | OPTVALUE=     | value    | value          | 


  1. Selection of long-form options in getopt
     - user can enter an abbreviated name for a long-form option
     - based upon specification of all options, disambiguation can occur
     - such pre-processing can easily support alternative long-form
       - alternative long-form are options that start with a single -
     - downside could be in a user program that calls the utility when
       - used a shorten long-form option
       - the utility adds an option that introduces ambiguity 
       - hence this is a support is
       - but maybe, it is what it is, so use !   <---

  1. Optional Values
     - getopts does not provide said support
     - getopt: optional values must be physically connected to the option
       ```
       $ getopt -l "dir::" "d::" --dir=hello -dhello  arg
       --dir 'hello' -d 'hello' -- 'arg'
       $ getopt -l "dir::" "d::" --dir hello  arg
       --dir '' -- 'hello' 'arg'
       $ getopt -l "dir::" "d::" -d hello  arg
       -d '' -- 'hello' 'arg'
       ```
      - revised program can either
        1. require optional args are physically connected (to be consistent with the past)
        1. remove this requirement in favor of defining the form of a value
           - i.e., a value is a parameter that does not start with a hyphen <---

      - providing support for default values adds value to optional values

  1. Optional Values with condensed options
      - the associated option must appear at the end of a option list
      - that is to say, you must treat it like a required value
      - if it is in the middle, there is too many possibilities for disambiguation
      - Consider:
        - optstring="d::hel::p"     # hypothetical 
        - \<prog\> -dhelp
        - Is this equivalent to: \<prog\> -d -h -e -l -p
        - Is this equivalent to: \<prog\> -d he -l p
        - Is this equivalent to: \<prog\> -d help


  1. OPT_PREFIX="-,--"
     - we should define what an option PREFIX is to generalize
       - short-form option, e.g., -f
       - long-form option, e.g., --banner

  1. Standalone prefixes
     - "--" should be interpreted special
     - "-" should be interpreted special
     - That is to say these are both arguments (and not options)
       * "--" is the null (lambda) argument
       * "-" can be used to denote stdin (as in `man cat`)

  1. Plus (+) as an option PREFIX
     - alternative short-form, e.g., +x
     - has the opposite meaning of -x
     - could be modeled as:  --x on,  --x off
     - the +x could be just a throw back to the shell

  1. Support for Subcommands
     * getopt is not good for use of programs with subcommands
       - E.g., 
       ```
        $ getopt "C:a" git -C . commit -a
        -C . -a -- git commit
        ```
     * Note the '-a' option for commit has become an option for `git`


# Thoughts:

  1. Can the value of an option betin with a '-'?
     * Consider -l being an option that requires a value
     * Are the following valid:  -l-help or -l -help
     * Answer: No, define a value to NOT begin with a prefix
     * But: Consider a way to escape the initial "-"

  1. Interpretation issue associated with require values
     - If the next command-line parameter begins with an "-"
       1. so what -- use it, it is required
       1. don't use it -- throw an error
       1. don't use it -- use a default value
          - this last option implies you should use an optional value
     - getopts does:
     - getopt does:


  1. Interpretation issues associated with optional values
     - It should be greedy in approach
     - Use the next command-line parameter as its value
     - Exception if said value begins with a hyphen
       - Use the defined default (see below)
     - getopt does:


  1. Can we programmatically define a default value for an option?
     - That is to say, if if the option is present, but not value is given, the specification that is provided via, say getopt, defines the value.
     - Current proper ways to assign a default value of '' to a long-form option
       * --{banner}=, --{banner}='', --{banner} ''
     - Example:
       - Let's say that we have option --debug to define the level of debugging
         | CLI Includes | Level |
         |--------------|-------|
         | \<none\>     |   0   |
         | --debug      |   1   |
         | --debug N    |   N   |
         | --debug=''   |   ''  |


