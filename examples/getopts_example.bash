#! /usr/bin/env bash
set -u

# Usage: fictitious [options] [--] arg1 arg2
# See:   fictitious.md
#
# Short-Form Options: "xltif:d::"                   <-- Note technically wrong
#    - with no value:       -x, -l, -t, -i
#    - with required values: -f file
#    - with optional values: -d [N]
#
# Long-Form Options (introduced by the short-form option of '-')
#   - with no value:         --ignore-case
#   - with required values:  --dir path, --dir=path
#   - with optional values:  --tag [pattern], --tag[=pattern]
#
# NOTE:  getopts does not support either long-form options or 
#        optional values for short-form options.
# HENCE: Special handling is required to handle these two cases.
#


# This file implements the `fictitious`` function as a examplar of using the
# getopts builtin utility to process command-line options.


# The goal of this implementation is to show how to manage all possible variations 
# of options using getopts.  Note that the we diverge from getopts and getopt in 
# the way we address options with optional values.  The syntax forms that diverge
# are denoted by "<---".  These rules allow an optional value to be represented by 
# a separate command-line parameter.  Note that such a command-line option must NOT 
# be following by:
#
#   1. an value that begins with a hyphen (-)
#      - such a value will be deemed to be the next command-line option 
#      - NOTE: som
#   1. the first command-line argument
#      - this argument will be deemed to be the value of the current command-line option
#      - the "--" string should be inserted before the first command-line argument
#

# For descriptive purposes we use the following nomenclature.  Note that this 
# nomenclature differs from both getopts and getopts.
#
#   1. Definitions:
#      * A command-line argument that is used to change the behavior of a program
#      * An option my appear starting with a hyphen (-) or double hyphens (--)
#      * A special case of an option may start with a plus (+) [NOT IMPLEMENTED AT THIS TIME]
#      * An option may be followed by an associated value
#      * Such a value may not begin with a hyphen (-) (nor a plus (+))
#      * Examples:  --file {file},  -d,  +x, --file={file}
#
#   1. Lexicon:
#      *  flag    | a single ASCII character (excluding: colon (:) and question (?))
#      *  flag:   | a flag that has an required value
#      *  flag::  | a flag that has an optional value
#      *  value   | a string of ASCII characters, a word in BASH parlance
#      *  banner  | a string of alpha-numeric characters
#  
#   1. Syntax:
#     - Single option with/without a required value
#       *  -{flag} [{value}]           OPTARG="{value} or OPTARG="" 
#      
#     - Sequence of flags with the last flag having a required value
#       *  -{flag}*{flag:}[value]      
#       *  -{flag}*{flag:} [value]  
#
#     - Sequence of flags with the last flag having an optional value
#       *  -{flag}*{flag::}[value]                         <---- 
#       *  -{flag}*{flag::} [value]                        <----
#
#     - Banner with without a value
#       --{banner}                     OPTARG=""
#
#     - Banner with a required value
#       --{banner} {value}             OPTARG={value}
#
#     - Banner with an optional value
#       --{banner}={value}             OPTARG={value}
#       --{banner} {value}             OPTARG={value}      <----
#
#   1. Notes
#      * a value can not start with a '-'  
#      * a value can be quoted but the second character cannot be a '-'
#        - should some type of escape mechanism be provided to support such a value?
#      * a banner can't not be quoted and needs to be a simple word
#        - Are we sure about this one?
#
#   1. Issues:
# 
# Missing required value:
#   Need to determine what to do when an option is missing a required value.
#   E.g.,  --dir --{banner}
#   
#   Options:
#     1. report error and stop.  This is what we currently do
#     1. report error and set value to ''
#     1. report error and remove the option
#
# Optional argument for short-form opts
#   This description and its validity
#
#   E.g., short-form option spec:  "xf::"
#
#   ./fictitious -xf yes -fhello -xfx   <<-- actual
#     -f yes   : valid
#     -fhello  : valid, equivalent to: -f hello
#     -xfx     : valid --> -f x
#
#   If "d"
#
#   ./fictitious -xd yes -dhello -xdx   <<- conjecture
#     -xd yes  --> -d yes    # same process as --dir 
#     -dhello  --> -d hello  # but getops will return just d
#                            # need to play with ${OPTIND - 1}
#                            # two assumptions:
#                            #  1. h is an option, --> d has not option
#                            #  1. h is not an option --> d has hell as the option
#     -xdx                   #  this is the case above where h is an option
#             


function fictitious() {
  # Usage: fictitious [options] [--] arg1 arg2


  ## Step 1: The only step, Process Command line arguments using getopts
  
  # Global variables associated with getopts
  # ${OPTIND}    # The index of the next parameter to be processed
  # ${OPTARG}    # The optional argument associated with current option being processed
  # ${OPTERR}    # A value of 1 indicates that error messages are to be displayed

  # Additional variables to correspond with the nomenclature above
  # ${OPTFLAG}
  # ${OPTBANNER}
  # ${OPTVALUE}

  # Set the Position Parameters to the Current Positional Parameters
  set -- "$@"    # This step is superfluous, but illustrative

  OPTIND=1           # Set the index of the next parameter to process
  _OPTIND_shadow=1   # Set a shadow index 
  SHORT_OPTIONS="hxltif:d-:"

  while getopts "${SHORT_OPTIONS}" flag "$@" ; do
    local OPTFLAG=${flag}
    local OPTBANNER=
    local OPTVALUE=${OPTARG:-''}

    local flag_from=$(( _OPTIND_shadow ))
    local arg_from=$(( OPTIND - 1 ))       
    _OPTIND_shadow=${OPTIND}


   case "${flag}" in

     # These options do NOT have a value
     ( x | l | t | h )
         echo "The option '-${flag}' has been identified with no value."
         echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
         echo
         
         # Insert User Code

         ;;

     # This option does NOT have a value, but is separated out from the above options
     # ideally, it should be paired with --ignore-case
     ( i )
         echo "The option \`-${flag}\` has been identified with no value."
         echo "    \`-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
         echo

         # Insert User Code
         #    for case insensitivity (see option "ignore-case" below)

         ;;

     # This option MUST have a value, this value could be connected to or follows the option
     ( f )
         echo "The option \`-${flag}\` has been identified with the value '${OPTARG}'."
         echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
         echo "    '${OPTARG}' stems from \${${arg_from}} == '${!arg_from}'."
         echo 

         # Insert User Code

         ;;

     ## This option MAY have a value

     # Treat as if it is required to have a value
     # "d:" and -dvalue  -->  "value" is $OPTARG"
     #                        if v was intended to be the next option, no way to handle it
     # "d:" and -d value -->  then "value" is the $OPTARG
     # "d:" and -d -next -->  then $OPTARG needs to be put back, (( OPTIND -- ))

     ## Treat as if doe NOT have a value  <<--
     #  "d" and -dvalue  -->  if "v" is the next option -- I.e., no way to undo
     #  "d" and -d value -->  "value" is ${!OPTIND}
     #                        if value does not begin with -. (( OPTIND ++ ))


     ## This option MAY have a value
     ( d )

         ## Check to see if the next word is valid argument

         if [[ -z ${OPTARG:-''} ]] then
           echo "The option '-${flag}' has been identified without a value."
           echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'"
         else
           echo "The option '-${flag}' has been identified with the value '${OPTARG}'".
           echo "    '-${flag}' stems from \${$((flag_from))} == '${!flag_from}'"
           echo "    '${OPTARG}' stems from \${${arg_from}} == '${!arg_from}'."
         fi
         echo

         # Insert User Code

         ;;

     ## Manage long-form options via the "--" option
     ( - )
         # NOTE BUG:  either of the following can be used 
         #   --tag    // correct
         #   - -tag   // buggy

         [[ -z ${OPTARG} ]] && break        # Special case of "--"

         # At this point:
         #   flag   == -
         #   OPTARG == -banner[=value]

         OPTBANNER=${OPTARG/%=*/}           # strip off the option [=value]
         OPTVALUE=${OPTARG/#*=/}            # strip off the option {banner}= 

         [[ ${OPTVALUE} == ${OPTARG} ]]  && OPTVALUE=""

         OPTBANNERIND=$(( OPTIND - 1 ))
         OPTVALUEIND=$(( OPTIND - 1 ))

         local _solo_value=false

         case "${OPTBANNER}" in
             ## This option does NOT have a value
             ( ignore-case )
                 echo "The option '--${OPTBANNER}' has been identified."
                 echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}}."

                 # Insert User's Code Here
                 #   e.g., turn case insensitivity (see option "i" above)
                 ;;

             ## This option MUST have a value
             ( dir )

                 # alternatively... if it is a MUST
                 # always take the next value and if it starts with a -
                 # Put it back

                 { # The following code should be provided by the "system"
                   if [[ -z "${OPTVALUE}" ]] ; then
                     # Put the next non-option parameter into $OPTVALUE
                     if [[ ${!OPTIND} != -* ]] ; then
                       OPTVALUEIND=${OPTIND}
                       OPTVALUE=${!OPTIND}
                       (( OPTIND ++ ))
                     fi
                   fi
                   if [[ -z "${OPTVALUE}" ]] ; then 
                      echo ${0}: option requires an argument -- ${OPTBANNER} > /dev/stderr
                      break ;  # What should happen in SILIENT MODE
                   fi
                 }

                 echo "The option '--${OPTBANNER}' has been identified with the value '${OPTVALUE}'."
                 echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                 echo "    '${OPTVALUE}' stems from \${${OPTVALUEIND}} == ${!OPTVALUEIND}."
                 echo 

                 # Insert User's Code Here
                 ;;


             ## This option may have a value
             ( tag )
                { # The following code should be provided by the "system"
                   if [[ -z "${OPTVALUE}" ]] ; then
                     # Put the next non-option parameter into $OPTVALUE
                     if [[ ${!OPTIND} != -* ]] ; then
                       OPTVALUEIND=${OPTIND}
                       OPTVALUE=${!OPTIND}
                       (( OPTIND ++ ))
                     fi
                   fi
                 }


                 if [[ -z "${OPTVALUE}" ]] ; then 
                   echo "The option '--${OPTBANNER}' has been identified without a value."
                   echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                 else
                   echo "The option '--${OPTBANNER}' has been identified with the value '${OPTVALUE}'."
                   echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                   echo "    '${OPTVALUE}' stems from \${${OPTVALUEIND}} == ${!OPTVALUEIND}."
                 fi
                 echo 

                 # Insert User's Code Here
                 ;;

             ( * )
               # Invalid option detected
               echo ${0}: illegal option -- ${OPTBANNER} > /dev/stderr
               ;;
         esac
         ;;

     ( \? )
         # Invalid option detected
         continue  # We have processed all options  
         ;;
    esac
  done
  shift $(( OPTIND -1 ))

  if [[ $# == 0 ]] ; then 
    echo "There are no remaining arguments to fictitious."
  else 
    echo -n "The arguments to fictitious are: "
    for i in "$@" ; do
       echo -n \'$i\' 
       echo -n ' '
    done
  fi
  echo
  # Step 2: Continue with the processing of `fictitious`

  return
}


if [[ "$#" != 0 ]] ; then
  fictitious "$@"
else
  #echo fictitious -d --tag -xffile --dir=/usr/bin  --dir /local/sbin -d arg1 arg2
  echo 
  echo fictitious --dir --dir=/usr/bin  --dir /local/sbin -d arg1 arg2
  echo
  fictitious --dir --dir=/usr/bin  --dir /local/sbin -d arg1 arg2
  echo
fi

   # Programming Clarity:
   #
   # 1. It would be better if the option of -i and -ignore-case were together
   # in the same switch class
   # 
   # 2. It would be better if a double switch case was not require
   #
   # 3. It would be better if there was way to "mark" long-form option as to their
   #     argument type as is the case with short-form options

#management of values for long form options must be managed by the programmer

   # Exceptions:
   #   * use of a single -
   #     - must be a argument typical to denote stdin
   #     - be not be the first argument, or it must follow "--"
   #   * "--" be supported, and is trigger as "-::"

   # -xd-tag is valid

