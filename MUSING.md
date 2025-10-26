# MUSINGS

This file contains my musing and my notes as I think through what I want 
to accomplish in this repo.  Some parts of this file should be consider more
akin to notes taken during a class lecture as to opposed to well structured thoughts.

Over time, these musing should be transformed more into use notes.

## Completed
  1. Musing to determine getopts/getopt and a possible new utility
     - more musing to come
  1. A new definition of the lexicographical form of an option
     1. all options begin with a hyphen
     1. all values can not begin with a (unescaped) hyphen
     1. options can have represented as
        - short-form
        - condensed short-form
        - long-form
  1. An implementation of a fictitious function, within getopts_example.bash, 
     that illustrates the handling of these options using bash's builtin
     `getopts` command



# Next Steps/Work
  1. muse some more
  1. create a version of fictitious, as an exemplar for using getopt
     - determined that getopt's definition of an option presents a number of problems
       - rather than working around getopt, we shall
       - refrain from implementing options with optional values -- that are not directly connected
     - after said implementation is complete, next step will be determined

## Future Steps
  1. reframe parse_option to be self_example.bash
     - use lessons learns to couch the program similar to the use of getopts/getopt
  1. create TBD specification for man git
     - ...
  1. Of course continually cleanup and document


## Current Recap

  1. Definition of an option
     - a command-line argument that is used to change the behavior of a program
     - a word that is proceed by a hyphen (-), and is not exactly '-' or '--'
     - there are three types of options:
       - short-form option, with and without a value: e.g., -l, -f file
       - condensed-form option, a sequence of short-form options
         - only the last one may have a value: e.g., -lsf file
       - long-form option, with and without a value
         - begin with a double hyphen (--)
         - the name of the option follows the double hyphen
         - the value is follows the name by either an equal sign (=) or space
           - e.g., --name value, --name=value
      - limitations for getopts & getopt
        - optional values must be physical connect to the option name
          e.g.,   -ffile and not -f file, --long=value and not --long file
  1. Refined definition -- not recognized by getopts nor getopt
     - a value associated with an option with an optional value may NOT begin
       with a hyphen
     - a value that begins with a hyphen can be escaped, e.g., '\-value'
     - an optional value for an option need to be directly connected to the option


  1. Bash builtin `getopts`:
     - a utility to simplify the use of command line options
     - input example:  -ls -t file -d arg1 arg2
     - general usage: 
       ```
       OPTIND=1
       while getopts ${OPTIONS} name $@""
         # $OPTIONS: a list of command lines options, e.g., "lst"
         # name: the value set by getopts on subsequent calls, the name of the option
         # $@: the parameter list to be processed
         case $name in 
            ( l ) : ; ;;
            ( s ) : ; ;;
            ( t ) : ; ;;
          asac
          shift $OPTIND
       ```
     - supports condensed options -lst, as opposed to -l -s -t
     - short-form options with optional values is not supported
     - long-form options (--long value) are not supported directly
       * programmer can implement around this limitation -- but its lack luster
       * one can views the option's name as the string _after_ the first hyphen (-)
         - given: -s and --long, the names are s and -long, respectively
     - A program needs to do a lot of work if they need to have either
       * optional values with short-form options
       * long-form options
     - The programming style to use all forms of options is cumbersome


  1. Gnu `getopt`:
      - a supplemental program used to canonicalize the presentation of command-line options
      - I/O example:
        - input:  -ls -t file --long=value arg1 arg2 
        - output: -l -s -t 'file' --long 'value' -- arg1 arg2
      - general usage:
        ```bash
        args=$(getopt --longoptions ${LONGOPS} -o ${SHORTOPS} -- $@ ) ; 
        for i in $args ; do
          case $i in 
            ( -s          ) : ; ;;
            ( -l | --list ) : ; ;;
            ( --long      ) : ; ;;
          esac
        done
        shift ${num_options}
        ```
        - programming style appears to be much cleaner

      - supports condensed short-form options
      - supports short-form options with optional values
        - but said values must be connected to the option, e.g., -ffile
      - supports long-form options:
      - supports long form options with values:  --long=value --long value
      - supports long-form options with optional values
        - but said values must be connected to the option, e.g., --option=value


   1. SHORTOPS notes:
      - example: "+:f:d::"
      - f:  denotes f has an associated value, -f value
      - f:: denotes f may have an associated value,  -d, -dvalue
      - initial character:
        * ":" : getopts returns ':' instead of '?' for missing value, silent mode
        * "+" : scan stops after the first non-optional character
        * "-" : non-option parameter are emitted where they are found

   1. LONGOPTS notes:
      - example: "long,form:,optional::"
      - usage:  --long  --form=hello1 --form hello2 --optional=value


   1. Issues with and getopt (and getopts)
      - short-form options that require values must be connected
      - output of getopts for optional values is a null string ''
        - a default value might be better
      - pairs of tokens (name, value) are output for options with values
        - null '' string is used for non-existing optional value
      - single token is output for options defined not to have values
        - for uniformity it might be best to output pairs


## Programming Style for Using `getopts`
  1. Programming clarity with using getopts with long-form options
     - Note a hyphen (-) is used introduce long-form options

     1. Separate Case for long-form options
        - duplicative long-form options with and without the '='
        ```bash
        while getopts d-: option ; do
          case "${option}" in
            ( - ) case "${OPTARG}" in
                    ( init_file=* ) 
                      : programmer separates the argument
                      OPTARG=${OPTARG#init_file=}
                    ;;
                    ( init_file ) 
                      OPTARG=${!OPTIND} ; (( OPTIND++ ))
                    : ;;
                  esac
                  ;;
            ( d ) ...
        ```
        - Issue need to manager required vs optional values differently
        - The above is for required values

      1. Combined case for short- and long-form options
        - introducing OPTNAME that does not include the - or --
        - need to ensure we don't have -l and --l as valid options
        ```bash
        while getopts h489-: option ; do
          OPTNAME=${option%-}
          case "${OPTNAME}" in
            ( half ) ;;
            ( some ) ;;
            ( h )    ;;
            ( 4 )    ;;
          esac
        ```
        - Issue need to deal with OPTVAR

     1. Splitting up an attached valued based upon an = 
        ```bash
         while getopts h489-: option ; do
           if [[ ${OPTVAR+set} == -* ]] ; then
              option=${option%=*}
              OPTARG=${option#*=}
           fi
           case "${option}" in
             ( -half ) ;;
             ( -some ) ;;
             ( h )     ;;
             ( 4 )     ;;
           esac
       ``` 
       - Issue: if the value is in a separate parameter
       - The above is for values that are directly connected

     1. Introduction of OPTNAME that includes the - and -- 
        - Appears to be the cleanest
        ```bash
        while getopts h489-: option ; do
          OPNAME=-${option%=*}
          if [[ ${OPTVAR+set} == -* ]] ; then
            OPTARG=${option#*=}
          fi
          case "${OPTNAME}" in
            ( --half ) ;;
            ( --some ) ;;
            ( -h )     ;;
            ( -4 )     ;;
          esac
        ```
        - Issue: if the value is in a separate parameter
        - The above is for values that are directly conected


---

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

  1. Stand-alone prefixes
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
     * getopt can be used for subcommands
       - final syntax:
         ```
         command [options] -- subcommand [options] -- [args]
         ```

       - but NO shuffling needs to be employed
       - moreover, a secondary call needs to made
         1. call getopt to process (with no shuffle)
         1. find the subcommand
         1. call getops for the params after the subcommand
       - you could argue that it is up to the subcommand to
         process its command line args.


# Thoughts:

  1. Banner with a null equals value. E.g., --tag=, the possible meanings are:
     1. '' is the meaning of --tag=  <---
     2. the defined default (well that would be --tag )
     3. the value of the LOOKAHEAD (well that would be --tag)
     4. unset because there is no value (but that would be the non use of --tag


         
  1. It appears the short-form options and long-form options with 1 char are treated as different things
     - should they be unified
     - perform some tests to validate


  1. We have a rule that states that all options start with a hyphen (-), which differs from getopts/getopts
     - one issue is options with optional values, in which said value can be a negative number.  (We can also include explicit positive numbers, i.e., +45.)
     - to address this, the lookahead of a option can be used identify that -45 should be a value and not an option.
     * possible implication is that the {TBD}\_tool is that yylex should return two tokens: option and value
       - --option=value
       - --option={default}, --option={lambda}, --option={value}
       - --option='' ('' is a value, a null string) == --option=
       - --option, --option={lambda},

      * we could add multiple values for an option. consider
        - git log -L<start>,<end>:<file>
        - "-L={start} {end} {file}"

  1. Just added TEST and ILLUSTRATE process, need to determine
     how to present the command-line.  Right now it is similar 
     to getopt
     1. how to present errors
     1. how to present optional args, that are meant NOT to be there (in the future, it could be the default)
        - e.g., '-f' <default>, '-f' {default}
     1. how to present errors
        - e.g., '-f' <error>,  '-f' {error}
     1. how to present long options, e.g.,
        - given:  --dir /usr/log
        - --> '--dir=/usr/log' , '--dir' '/usr/log'
        - given:  --tag --
        - --> '--tag=' , '--tag={default}', '--tag' --tag {lambda}
     1. how to present the prefix appropriate: +,-,++


  1. what to do with reporting an error if a required value is missing its
     required value;;  
     - currently:  '-l' {error} 



  1. We have an issue with regard to how options are used throughout industry
     - consider git and openssl  AND getopt --alternative 
     - getopt:
       - short-form options with optional values: must be physically connected
       - long-form options with optional/required values: must be physically connected
     - getopt --alternative  and/or openssl
       - we have long-form with required values NOT physically connected
       - openssl example:  -writerand file
       - but we don't have OPTIONAL values

===
So where are we:  current getopt can support openssl
$ getopt -o "-" -a -l "tag:" -- -tag hello
 --tag '' 'hello' --



For the examples below, why is -t ambiguous
  -- is this the case for all one letter options

$ getopt -o "" -a -l "tag:" -- --tag -tag hello --tag=hello -t=hello
getopt: option `-t' is ambiguous
 --tag '' --tag '' --tag 'hello' -- 'hello'

Here tag is an option that requires a value, via openssl
  -tag hello should be valid but it is not

====
$ getopt -o "-" -a -l "tag:" -- --tag -tag hello --tag=hello -t=hello
getopt: option `-t' is ambiguous
 --tag '' --tag '' 'hello' --tag 'hello' --

here the value stays in the right spot but still not associated with --tag

====

$ getopt -o "-t:" -a -l "tag:" -- --tag -tag hello --tag=hello -t=hello -t hello
 --tag '' --tag '' 'hello' --tag 'hello' -t '=hello' -t 'hello' --


====

     // ## getopts optstring flag [args]
     // ### optstring notes:
     // 
     //   - OPTSTRING="xy"   | two options without values
     //   - OPTSTRING="x:y"  | option x with value and option y without a value
     //   - OPTSTRING="x:y:" | both x and you has values
     //   - OPSTRING="x::"   | not supported, x has an option value
     // 
     //   - OPTSTRING=":xy"  | if the first char is an :
     //                      | we are in silent mode
     // 
     // ### flag
     //    - one of the characters in OPTSTRING
     //    - : the special char to denote a option that requires a value does not
     //      * OPTARG contains the flag
     //    - ? the special char to denote we say an invalid option, 
     //      * OPTARG contains the flag

   - getopts as a hack can do the same thing as getopt, but...




## Musing on the Definition of an Option

  1. Can the value of an option begin with a '-'?
     * Consider -l being an option that requires a value
     * Are the following valid:  -l-help or -l -help
     * Answer: No, define a value to NOT begin with a prefix
     * But: Consider a way to escape the initial "-"

  1. Interpretation issue associated with require values
     - If the next command-line parameter begins with an "-"
       1. so what -- use it, it is required
       1. don't use it -- throw an error,      because it is the next option
       1. don't use it -- use a default value, because it is the next option
          - this last option implies you should use an optional value
     - getopts does: uses it, because it is required
     - getopt does:  uses it, because it is required
     - my view: it looks like an option, so treat it like an option
       * this implies that values can't start with a -, 
       * escape the value to ensure things are '\-45' correct

  1. Interpretation issue associated with optional values
     - If the next command-line parameter begins with an "-"
       1. so what -- it is there use it --- very bad choice
       1. don't use it -- use a default value, because it is the next option
     - getopts does not support this
     - getopt does NOT use it, is inserts a default value
       * optional values must be directly connected to the option ("f::")
         - -ffile  : valid
         - -f file : invalid


  1. Interpretation issues associated with optional values
     - It should be greedy in approach
     - Use the next command-line parameter as its value
     - Exception if said value begins with a hyphen
       - Use the defined default (see below)
     - getopt does:


  1. Can we programmatically define a default value for an option?
     - That is to say, if if the option is present, but no value is given, the specification that is provided via, say getopt, defines the value.
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



     // ## getopts optstring flag [args]
     // ### optstring notes:
     // 
     //   - OPTSTRING="xy"   | two options without values
     //   - OPTSTRING="x:y"  | option x with value and option y without a value
     //   - OPTSTRING="x:y:" | both x and you has values
     //   - OPSTRING="x::"   | not supported, x has an option value
     // 
     //   - OPTSTRING=":xy"  | if the first char is an :
     //                      | we are in silent mode
     // 
     // ### flag
     //    - one of the characters in OPTSTRING
     //    - : the special char to denote a option that requires a value does not
     //      * OPTARG contains the flag
     //    - ? the special char to denote we say an invalid option, 
     //      * OPTARG contains the flag

   - getopts as a hack can do the same thing as getopt, but...

## Lessons Learn

  1. Unset variables in Bash
     - you can use the "set -u" or "bash -u"
       - to have bash check for the use of unset variables
     - you can use [[ -v $VAR ]] to test for an unset variable
       - but NOT when "set -u" had been issued
     - You can then use ... [[ -z "${V+word}" ]] to make the check
       - If V is unset, "word" is added to the string


  1. The Bash "case" command as each arm terminated with one of the following
     - ;;  : normal termination
     - ;&  : continue to the next arm without testing the associated pattern
     - ;;& : continue to the next ares in sequence testing the associated patter
     * the order of your case arms becomes very important
     * you can't alter the value of the name in : 'case name in'
       - each pattern uses the original value of name when performing test
       - this was unexpected but in reflection this should be the semantics



  1. getopts (a bash builtin) has a very special variable, very special
     1. getopts has an internal variable that is used to manage condensed options
     1. the variable OPTIND is monitored to determined if the value is updated
        - said update is NOT related to a change in value
        - the change of value could be OPTIND=${OPTIND}
     ```bash
     set -- -ab -cd -a
     for (( OPTIND=1, x=1; x <= 3; x++ )) ; do
       getopts :abcd flag
       echo $flag '; ' $OPTIND
  
       OPTIND=${OPTIND}
     done
     ```
     ```
     a ;  1
     a ;  1
     a ;  1
     a ;  1
     a ;  1
     ```
     ```bash
     set -- -ab -cd -ab 
     for (( OPTIND=1, x=1; x <= 5 ; x++ )) ; do
     
       getopts :abcd flag
       echo $flag '; ' $OPTIND
     
       # OPTIND=${OPTIND}
     done
     ```
     ```
     a ;  1
     b ;  1
     c ;  2
     d ;  2
     a ;  3
     ```
     - the above code illustrates the behavior change in getopts when
       * you don't update the value of OPTIND
       * you update the value OPTIND *BUT* you don't change the value
       

