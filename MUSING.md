# MUSINGS

This file contains my musing as a work throw what I want to accomplish in this repo.
These should be consider akin notes that you take during a class lecture.
One might say, more ramblings as opposed to musing

# Current Recap
  1. getopts:
     - nice utility to simplify the use of condensed options -lst, as opposed to -l -s -t
     - its a hack to use the tool to use long options, e.g., --long value
     - views the option's name as the string _after_ the first hyphen (-)
       * given: -s and --long, the names are s and -long, respectively
     - the programmer's switch/case statement refers to these names, and special is need  for long options

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
     - the programmer's switch/case code fails into a recognized pattern

  1. {TBD}:
    I'm thinking of using compiler related approach to generate the code pattern for program.  This approach is based upon the tool "Lex/Flex". If you are familiar with Lex, perhaps the following musing give you some insight to what I'm thinking.

    ```tbd
    # This section holds variable definitions
    style="early modern apostrophus vinculum"

    boolean="true false"
    number=[0-9]+

    %%
    # This section holds option specifications

    -l | --list            { # insert code for the list option
                             # "list" option has no arguments
                             ;
                           }

    -h :                   {
                             # "h" option requires a value
                             # said can be anything
                             # perhaps we should use "*" instead of :
                           }

    -d {boolean}           { 
                             # "d" option requires an argument
                             ;
                           }

  
    -n {number}            { 
                             # "n" option requires a number
                             ;
                           }

    --{style}              { 
                             # create an option for each value of ${style}
                             # i.e., early, modern, apostrophus, and vinculum 
                             # use the same code to support the option
                             ;
                           }

    # Options that have an optional value

    --debug     ::         {
                             # "debug" option has an optional value
                             # the default value is ""
                             #   --i.e., no default value is provide
                           }




    --highlight :true {boolean}
                           {
                            # highlight has a optional value.
                            # if NOT provided the default is "true"
                            # if provided it must be either "true" or "false"
                            ;
                           }

    # Now for a more complex example

    -{style:0:1}     |     # use the first letter in each style to create an option
    --{style}        |
    --style {style}        { 
                             # insert code the style option
                             # this option can be expressed in a number of ways
                             ;
                            }

    ```

    1. The use of ":" and "::" are used, maybe, to conform to the usage in getopts/getops
    1. However, it might be a useless throwback



# Current Work
A bash script to extend 'getopts'



# Similar Utilities
  - getopt: a bash utility that standardize the presentation of command-line options
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

  - getopt: a bash builtin utility

# References


# Notes
  * define canonical  command line
    - option_spec "abc"    : "-abc" is not transformed to "-a -b -c"
    - option_spec "o:"     : "-oarg" is transformed to "-o arg"
    - option_spec "ao:"    : "-o -a" is transformed to "-o \? -a"
    - option_spec ":ao:"   : "-o -a" is transformed to "-o : -a"
    - option_spec "ao::"   : "-o -a" is transformed to "-o -a"  --dif from mac
    - long_spec   "hello:" : "--hello=value" --> --hello value
  * getopt is called once, and returns a string
  * getopts is call multiple times

  * need to think about output quoting to preserve input
  * possible updates
    - double colon

  * If  the  first  character  is a '-', non-option parameters are outputted at the place
       where they are found; in normal operation, they are all collected at the end of output after a '--' parameter has been generated.  Note
       that this '--' parameter is still generated, but it will always be the last parameter in this mode.
    - getopt should be collecting the non-option to the end; but this does not happen
    - nor does the use of - or + at the beginning
    - THIS IS AS IS ON MY MAC

  * -l, --longoptions longopts
              The long (multi-character) options to be recognized.  More than one option name  may  be  specified  at
              once,  by  separating the names with commas.  This option may be given more than once, the longopts are
              cumulative.  Each long option name in longopts may be followed by  one  colon  to  indicate  it  has  a
              required argument, and by two colons to indicate it has an optional argument.
   -  we could use this to indicate how to interpret the optstring rather than provideing tow input strings
      * getopts "abd" "apple,bear,dog"
      * getopts ---longopts "a,apple,b,bear,dog"  
        - possible sort alphabetically? to do long matching?

  * man https://linuxcommandlibrary.com/man/getopts
    -  A leading colon `:` in `optstring` enables "silent error reporting", preventing `getopts` from printing error messages for unknown options or missing arguments; 
  * https://linux.die.net/man/3/getopt
    * Note this is a C lib
    * Returns the option character.
    -  An element of argv that starts with '-' (and is not exactly "-" or "--") is an option element. 
    - getopt_long() and getopt_long_only()
    -  The optreset variable was added to make it possible to call the getopt() function multiple times.
    - getopt() permutes the contents of argv as it scans, 
      - + as the first char in optstring denotes be aggressive with finding options
      - - as the first char in optstring denotes stop upon first nooption
      * But this creates a potential problem in commands with subcommands
        - e.g., git -C path commit -m
        - this would be transformed into git -C path commit
      * quote: This is used by programs that were written to expect options and other argv-elements in any order and that care about the ordering of the two.)

    - : denotes option has argument
    - :: denotes an optional argument
      - maybe only if -oarg as opposed to -o arg
      - issue -o arg non-option -->
        * -o -- arg non-option
        - -o arg -- non-option
      - quote: If the first character (following any optional '+' or '-' described above) of optstring is a colon (':'), then getopt() returns ':' instead of '?' to indicate a missing option argument

    - ; is a GNU extension
      - "W;"  -W foo -->  --foo

    - Long option names may be abbreviated if the abbreviation is unique or is an exact match for some defined option. A long option may take a parameter, of the form --arg=param or --arg param.


  * my BASH
    - comma used to separate each option in optstring: not on mac bash
      - acts an any other "character" for an option
    - :: denotes that the argument is option in the considensed form
      - appears that a sequence of ":" cancels out the first ":"
      ```bash
      # Optional
      $ ans=$(getopt "a::b"  -aopt -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a opt -b -- foo -b hello this --b arg1 -x   # "opt" argument is repositioned

      $ ans=$(getopt "a::b"  -a opt -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a -- opt -b foo -b hello this --b arg1 -x   # "opt" determined to be first non-option

      $ ans=$(getopt "a::b"  -a -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a -b -- foo -b hello this --b arg1 -x       # missing arg correctly skipped

      # Required
      $ ans=$(getopt "a:b"  -aopt -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a opt -b -- foo -b hello this --b arg1 -x    # "opt" argument is repositioned

      $ ans=$(getopt "a:b"  -a opt -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a opt -b -- foo -b hello this --b arg1 -x    # "opt" argument is detected
 
      $ ans=$(getopt "a:b"  -a -b foo -b  hello this --b arg1 -x) ; echo $ans
      -a -b -- foo -b hello this --b arg1 -x        # missing required arg is NOT detected
       ```

    - ":option:" 
      - the initial : denotes silent mode, so no error is reported
        - illegal options are denoted as -- 
        ```bash
        ans=$(getopt ":a+-" -+ --bluecolor --red arg1 -x) ; echo $ans
        -+ -- -- -- arg1 -x
        # -+: valid, --bluecolor invalid, --red invalid, -- end of optioins
        ```
      - the initial : allows a -: option but it is removed
        ```bash
        ans=$(getopt ":ab"  -a -:b -b  hello this --b arg1 -x) ; echo $ans
        -a -b -b -- hello this --b arg1 -x
        $ ans=$(getopt "ab"  -a -:b -b  hello this --b arg1 -x)
        getopt: illegal option -- :
        ```
      - the option 'n' has an associated argument
    
    - "-:" is recognized as a option with an argument
        ```bash
        $ ans=$(getopt "-:" --blue --red arg1 -x)
        $ echo $ans
        -- blue -- red -- arg1 -x
       ```
      * note the space between -- and the value, this is just the canonical form
      * but now we don't know the start of the args proper


HMM...
  - getopt canonicalizes the string to ensure every option is a single letter, and
    its optional argument is a separate word

  - getopts expects the "-" option (with a specification of '-:') to NOT be canonicalized

  - would it be better for getopt/getopts/etc use the '=' to separate the OPTNAME and OPTARG
    - e.g.,          --name=arg  -->  OPTNAME=name     OPTARG=arg
      * treats -- as it would treat -
    - as opposed to  --name=arg  -->  OPTNAME=-        OPTARG=name=arg
       * treats -- as the option flag followed by the "-" option  as treated by getop
    - or as to       --name=arg  -->  OPTNAME=-name    OPTARG=arg
       * treats the = sign special, which then would be treated by getopts as
         -           -name=arg   -->  -n ame=arg, with OPTNAME=n OPTARG=( ame arg)

I think, in short, there is not a huge benefit to providing a separate utility
  - you can use the current getopts function but
    - with a small twisted interpretation of what you are doing
    - with the need of the user to do a secondary operation to split the ARG from the name
      * i.e., the "option" is composed 

So new utility
  - cleans up the "hack" used via the --
    - but how to identify it in the opt string, perhaps it is just the double of OPTIFS
  - continues to treat -- as a special marker to split options from args
  - adds the notion of: OPTPREFIX :  -, +, and --
    - should -- be valid OPTPREFIX, if so a special case
  - adds the notion of: OPTNAME
  - retains the notion of "option", the first character after the OPTPREFIX -- what about --
  IFS_PREFIX, OPTIFS
    -OPTIFS=-+

  ++ would be special then

--
Found examples of 
  --init-file file  
as opposed to
  --init-file=file

with the = sign option no need to introduce a ":" if you will for long options
without the = sign, you need to deal with the ambiguity of "file" being
  - an optional argument to --init-file
  - the first argument

  -- you could leave it up to the programmer, to "skip" over the option

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
    # but I can't do this with the current version of getopts
    # i.e., manipulate OPTIND, or obtain the arg
    # -- or can I  YES you CAN  -- B U T not with the condense short options
    # $ set -- -bac arg
    # $ getopts "abc" option  ; echo $option : $OPTARG : $OPTIND
    # b : : 1
    # dwarf:parse_options steve$ getopts "abc" option  ; echo $option : $OPTARG : $OPTIND
    # a : : 1
    # dwarf:parse_options steve$ getopts "abc" option  ; echo $option : $OPTARG : $OPTIND
    # c : : 2
    # $ echo ${1}
    # -bac



  ```
  so really we are saying the : is really  to deal with
    - the presense of multi, condense options:
      -  "abc"  : -abc ->  -a -b -c
      -  "a:bc" : -abc ->  -a bc
  this is NOT needed with long arguments

  so then getopts is really
    - expending condense options to a cononical form
    - defining an ARG  for a single char option
    - but we can define the ARG for the user for long options, 
      - unless we have a marker, i.e., =
      - or the user handles it
---

# 
Thoughts on arguments with shorten input

valid long option   "something someone test"
then:
   * --some is an error
   * --somet expands to something
   * --someo expands to someone

To implement
  - we need a list of valid long options and we need to pre process
  - could cause backward comp if a new option is added
  - does not lend itself to readability -- which is parament

--
Anser:  I don't think its worth it...

Thoughts on a compiler compiler for options
1. provide a list of options
cat <<EOF
-a
-a option
--long
--long=arg
--longer=arg
EOF
2. generate a code template
cat <<EOF
while getops "a:" option ; do
  case $option in
     a ) 
         if [[ -z $OPARG ]] ; then 
            :
         else
             :
         fi

         ;;
     
    long )
         if [[ -z $OPARG ]] ; then 
            :
         else
             :
         fi
         ;;

    longe* )
         if [[ -z $OPARG ]] ; then 
            :
         else
            :
         fi
         ;;

---
Thoughts on ++
  - nice to have +x   to turn things on/off
  - but with --, you could have  -x on , -x off
  - seems to be a throw back to the shell opts

Thoughs on : versues ::  -- don't think there is much value on the optional due to potential ambiguity

-- is an - followed by the option -, hence
  -- arg should be valid but the ambiguity

for example
```bash
# AS IT IS
while getopts h489-: option ; do
    case "${option}" in
      ( - ) case "${OPTARG}" in
              ( half ) : ;;
              ( some=value  ) : ;;
            esac
            ;;
      ( h )  roman_form_half_set FALSE   ;;
      ( 4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;;
      ( 8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;;
      ( 9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;;
    esac

# With the splitting based upon the = in the special case of --
# with revising the value of "option"
while getopts h489-: option ; do
    case "${option}" in
      ( -half ) : OPTARG=="";;
      ( -some ) : OPTARG=="value";;
      ( h )  roman_form_half_set FALSE   ;;
      ( 4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;;
      ( 8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;;
      ( 9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;;
     esac

# With introducing OPTNAME that is defined as the prefix to the original OPTARG
# with the value of "option" staying the same -- i.e., backward compatible, but not for OPTARG 
while getopts h489-: option ; do
    case "${OPTNAME}" in
      ( half ) : OPTARG=="";;               # option == -
      ( some ) : OPTARG=="value";;          # option == -
      ( h )  roman_form_half_set FALSE   ;; # option == h
      ( 4 )  RN_SUBTRACTIVE_FORM_4=FALSE ;; # option == 4
      ( 8 )  RN_SUBTRACTIVE_FORM_8=TRUE  ;; # option == 8
      ( 9 )  RN_SUBTRACTIVE_FORM_9=FALSE ;; # option == 9
     esac

  ```
  The last form keeps getops the same w.r.t. option
  adds the notion of the OPTNAME which excludes the - and --





getopts "a+-:" option -+ --blue=color --red arg1 -x ; echo $option $OPTARG

-->
+ ""
- blue=color
- red
"" \?

getopts "a+-:" option -+ --blue color --red arg1 -x ; echo $option $OPTARG
+ ""
- blue OPTIND==3
"" \?  #color -- now increment OPTIND, OPTIND==4
- red
"" \?  OPTIND==5



dwarf:parse_options steve$ /opt/homebrew/opt/gnu-getopt/bin/getopt --help



Usage:
 getopt <optstring> <parameters>
 getopt [options] [--] <optstring> <parameters>
 getopt [options] -o|--options <optstring> [options] [--] <parameters>

Parse command options.

Options:
 -a, --alternative             allow long options starting with single -
 -l, --longoptions <longopts>  the long options to be recognized
 -n, --name <progname>         the name under which errors are reported
 -o, --options <optstring>     the short options to be recognized
 -q, --quiet                   disable error reporting by getopt(3)
 -Q, --quiet-output            no normal output
 -s, --shell <shell>           set quoting conventions to those of <shell>
 -T, --test                    test for getopt(1) version
 -u, --unquoted                do not quote the output

 -h, --help                    display this help
 -V, --version                 display version


