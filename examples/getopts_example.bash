#! /usr/bin/env bash -u

# This file implements the `fictitious`` function as a exemplar of using the
# getopts builtin utility to process command-line options.

##########################################################
# The following variables are to alter the output
# of the program for the expected behavior.
# TEST= true | false
# ILLUSTRATE= true | false

TEST=${TEST:-false}
ILLUSTRATE=${ILLUSTRATE:-true}
if [[ ${TEST} == true ]] ; then
    ILLUSTRATE=false
fi

# Note that both should NOT be true at the same time
##########################################################

# Usage: fictitious [options] [--] arg1 arg2
# See:   fictitious.md
#
# Long-Form Options (introduced by the short-form option of '-:')
#   - with no value:         --ignore-case
#   - with required values:  --dir path, --dir=path
#   - with optional values:  --tag [pattern], --tag[=pattern]
#
# Desired Short-Form Option string:  "xlif:d::t::"
#    - with no value:       -x, -l, -i        ("xli")
#    - with required values: -f file          ("f:")
#    - with optional values: -d [N]           ("d:")
#      # Implemented as starting with HAVING a required value
#    - with optional values: -t [tag]         ("t")
#      # Implemented as starting with NOT having a value
#
# Actual short-form string for getopts: "xli" + "f:" + "d:" + "t" + "-:"
#
#
# NOTE:  getopts does not support either long-form options or
#        optional values for short-form options.
#
# HENCE: Special handling is required to handle these two cases.
#        In this implementation we implement optional values
#        in two different ways to gain a better understanding
#        of the preferred approach.
#


# The goal of our implementation is to show how to manage all possible variations
# of options using getopts.  Note that we diverge from getopts and getopt in the way
# we address options with optional values.  The syntactic forms that diverge are denoted
# by "<---" (see below).  These rules allow an optional value to be represented by
# a separate command-line parameter.  Note that such a command-line option must NOT
# be following by:
#
#   1. an value that begins with a hyphen (-)
#      - such a value will be deemed to be the next command-line option
#      - if the value does start with a hyphen, it needs to be escape (\-)
#      - NOTE: some programs, such as `cat` use a single hyphen (-) to denote stdin
#
#   1. the first command-line argument
#      - this argument will be deemed to be the value of the current command-line option
#      - the "--" string should be inserted before the first command-line argument
#

# For descriptive purposes we use the following nomenclature.  Note that this
# nomenclature differs from both getopts and getopts.
#
#   1. Definitions:
#      * A command-line parameter is used to change the behavior of a program
#      * An option is an parameter that starts with a hyphen (-) or double hyphens (--)
#      * An command-line parameter is specifies what the program operates over.
#      * A special case of an option may start with a plus (+) [NOT IMPLEMENTED]
#      * An option may be followed by an associated value
#      * Such a value may not begin with a hyphen (-) (nor a plus (+))
#      * Examples:  --file {file},  -d,  +x, --file={file}
#
#   1. Lexicon:
#      *  flag    | a single ASCII character (excluding: colon (:) and question (?))
#      *  flag:   | a flag that has an required value
#      *  flag::  | a flag that has an optional value
#      *  value   | a string of ASCII characters that does not start with a "-" (nor a plus (+)
#      *  banner  | a string of alpha-numeric characters
#
#   1. Option Syntax:
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
#     - Ending Option Sentinel
#       --
#
#   1. Notes
#      * a value can not start with a '-', unless the hyphen is appropriately escaped
#      * all options appear before the first ending option sentinel
#      * all program arguments appear after all options
#
#   1. Issues:
#      * Unification of variable names and usage between short-form and long-form options
#      * User is required to escape negative numbers used as values
#      * -d <eol>   (could address but then it move ALWAYS required to well maybe/not
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

  local SILENT=":"                             # We go into silent mode to have more control
  local SHORT_OPTIONS="xlif:d:t-:"
  local LONG_OPTIONS="ignore-case,dir:,tag::"


  # Set the Position Parameters to the Current Positional Parameters
  set -- "$@"    # This step is superfluous, but illustrative

  OPTIND=1                            # Set the index of the next parameter to process
  local _OPTIND_shadow=${OPTIND}      # Set a shadow index

  while echo ${OPTIND} ; getopts "${SILENT}${SHORT_OPTIONS}" flag "$@" ; do

    # New variables that may/will appear in final prototype utility
    local OPTFLAG=${flag}
    local OPTBANNER=
    local OPTVALUE=${OPTARG:-''}


    # These variables are defined solely for the purpose of diagnostic/descriptive output
    local flag_from=$(( _OPTIND_shadow ))
    local arg_from=$(( OPTIND - 1 ))
    _OPTIND_shadow=${OPTIND}


    case "${flag}" in

      ## ERROR: Invalid option detected
        ( \? )
          # From: $(man bash)
          # If getopts detects an invalid option, it places ? into name and, if not silent, prints
          # an error message and unsets OPTARG.  If getopts is silent, it assigns the option
          # character found to OPTARG and does not print a diagnostic message.
          #   STANDARD:   name=\?, unset OPTARG,  (( OPTERR==1 )) && echo error
          #   SILENT:     name=\?, OPTARG=name

          if (( OPTIND > $# )) ; then  ## Why is this NEEDED?
            continue   # break?
          fi

          local _option=${flag}
          if [[ -n "${OPTARG+set}" ]] ; then
            # We are in SILENT mode:
            _option=${OPTARG}
          fi
          if (( ${OPTERR} != 0 )) ; then
            echo ${0}: ---- illegal option -- ${_option} > /dev/stderr
          fi
          # Nothing related to ${ILLUSTRATE} nor ${TEST}


          # Insert User Code

          ;;


      ## ERROR: Required value is missing
        ( : )
          # From: $(man bash)
          # If a required argument is not found, and getopts is not silent, it sets the value of
          # name to a question mark (?), unsets OPTARG, and prints a diagnostic message.  If
          # getopts is silent, it sets the value of name to a colon (:) and sets OPTARG to the
          # option character found.
          #   STANDARD  name=\?, unset OPTARG   ((OPTERR==1 )) && echo error
          #   SILENT    OPTARG=name, name=:


          # For our fictitious program, we will only drop in here for the
          # the "f" and the "d" case when we are the end of the line.
          #
          # For the "f" case, the code here is correct.
          # For the "d" case, we should check if we are at the end of line.
          #
          # Doing so, effectively transforms "f" into This creates a problem with the way we handle the "d" may, via a required
          #   <prog> -d {eol}
          # 
          # Possible programming solutions are just workarounds
          #
          # This highlights either
          #   1) the limitation of getopts
          #   2) the implementation approach of "( d )" as a MAY but defined as required
          #
          if (( ${OPTERR} != 0 )) ; then
            echo ${0}: option requires an argument -- ${OPTARG} > /dev/stderr
          fi

          ;;


      ## Options without a value
        ( x | l )
          ${ILLUSTRATE} && {
            echo "The option '-${flag}' has been identified with no value."
            echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
            echo
          }
          ${TEST} && {
            echo -n "'-$flag' "
          }


          # Insert User Code

          ;;

      ## - Option without a required value
        ( i )
          ${ILLUSTRATE} && {
            echo "The option \`-${flag}\` has been identified with no value."
            echo "    \`-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
            echo
          }
          ${TEST} && {
            echo -n "'-${flag}' "
          }


          # Insert User Code
          #    This option was separated from similar options to highlight
          #    It should be paired with --ignore-case (see below)

          ;;

      ## -Option with a MUST value: 
        ( f )
          ######################################################################
          # The following code should be provided by the "system"
          #
          # If the required value is in a separate parameter,
          # which is an option---then its an error.
          #
          #  -f -{next}  that is to say $OPTARG == -{next} 
          #
          # Note that in the case of  "-f <eol>"
          #   within STANDARD mode: case is caught by "\?"
          #   within SILENT mode:   case is caught be ":"
          {
            # Validate that a following required value is not an option (our definition)
            #
            if [[ ${flag_from} != ${arg_from} ]] ; then
              if [[ ${OPTARG} == -* ]] ; then
                echo ${0}: option requires an valid value -${flag}
                echo ${0}:    ${OPTARG} has been identified as an option
                unset OPTARG
                continue   # or break to signify an error
              fi
            fi
            OPTARG=${OPTARG/\\-/-}
          }
          ######################################################################
          ${ILLUSTRATE} && {
            echo "The option \`-${flag}\` has been identified with the value '${OPTARG}'."
            echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'."
            echo "    '${OPTARG}' stems from \${${arg_from}} == '${!arg_from}'."
            echo
          }
          ${TEST} && {
            echo -n "'-${flag}' '${OPTARG/#-/\\-}' "
          }


          # Insert User Code

          ;;


      ## -Option that MAY require a value, but defined as DOES require a value
        ( d )  # "d::" <- "d:"
          ######################################################################
          # The following code should be provided by the "system"
          #
          # -d{value}    --> leave it alone
          # -d-{value}   --> leave it alone
          # -d -{option} --> put -{option} back
          # -d {value}   --> leave it along, un-escape the "-"
          # -d <EOL>     --> ISSUE
          #
          # Note that in the case of "-d <eol>"
          #   within STANDARD mode: this case is caught by "\?"
          #   within SILENT mode:   this case is caught be ":"
          # But we can't be effectively handled so it is left as a noted issue

          { # The following code should be provided by the "system"
            if [[ ${flag_from} != ${arg_from} ]] ; then
              ## Need to ensure the next parameter is NOT an option
              if [[ ${OPTARG} == -* ]] ; then
                unset OPTARG
                (( OPTIND -- ))
                _OPTIND_shadow=${OPTIND}
              else
                OPTARG=${OPTARG/\\-/-}    # Un-Escape the "-"
              fi
            fi
          }
          ######################################################################
          ${ILLUSTRATE} && {
            if [[ -z ${OPTARG:-''} ]] then
              echo "The option '-${flag}' has been identified without a value."
              echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'"
            else
              echo "The option '-${flag}' has been identified with the value '${OPTARG}'".
              echo "    '-${flag}' stems from \${$((flag_from))} == '${!flag_from}'"
              echo "    '${OPTARG}' stems from \${${arg_from}} == '${!arg_from}'."
            fi
            echo
          }
          ${TEST} && {
            echo -n "'-$flag' '${OPTARG/#-/\\-}' "
          }


          # Insert User Code

          ;;

      ## -Option that MAY require a value, but defined as having NO value:
        ( t )  # "t::" <- "t"
          ######################################################################
          # The following code should be provided by the "system"
          #
          # -t{value}    --> make OPTARG="value"   ; Consume current parameter
          # -t-{value}   --> make OPTARG="-value"  ; Consume current parameter
          #
          # -t <EOL>     --> leave it alone
          # -t -{option} --> leave it alone
          # -t {value}   --> make OPTARG={value}   ; Consume next parameter, un-escape "-"
          {

            local _old_flag_from=${!flag_from}

            # The value is connected to the option
            if [[ ${!flag_from} != *t ]] ; then
              OPTARG=${!flag_from}
              OPTARG=${OPTARG#*t}
              arg_from=${flag_from}
              (( OPTIND = OPTIND + ${#OPTARG} + 1 ))
            fi

            # The value is a separate word or EOL
            if [[ ${!flag_from} == *t ]] ; then
              (( arg_from = arg_from + 1 ))
              if [[ ${flag_from} == ${#} ]] || [[ ${!arg_from} == -* ]] ; then
                # Leave it alone
                :
              else
                OPTARG=${!arg_from}
                (( OPTIND ++ ))
                OPTARG=${OPTARG/\\-/-}    # Un-Escape the "-"
              fi
            fi
            (( _OPTIND_shadow = OPTIND ))
          }
          ######################################################################
          ${ILLUSTRATE} && {
            if [[ -z ${OPTARG:-''} ]] then
            echo "The option '-${flag}' has been identified without a value."
            echo "    '-${flag}' stems from \${${flag_from}} == '${!flag_from}'"
            else
              echo "The option '-${flag}' has been identified with the value '${OPTARG}'".
              echo "    '-${flag}' stems from \${$((flag_from))} == '${_old_flag_from}'"
              echo "    '${OPTARG}' stems from \${${arg_from}} == '${!arg_from}'."
            fi
            echo
          }
          ${TEST} && {
             echo "-${flag}' '${OPTARG/#-/\\-}' "
          }

          # Insert User Code

          ;;

      ## Manage long-form options via the "--" prefix
        ( - )
          ######################################################################
          # The following code should be provided by the "system"
          #
          {
            [[ -z ${OPTARG} ]] && break                # Special case of "--"

            # At this point:
            #   OPTARG     ==  {banner}[=value]
            OPTBANNER=${OPTARG/%=*/}                   # strip off: [=value]
            OPTBANNERIND=$(( OPTIND - 1 ))

            OPTVALUE=${OPTARG/#*=/}                    # strip off: {banner}=
            OPTVALUEIND=$(( OPTIND - 1 ))


            # If OPTARG does not contain an equal ('=')
            # then OPTVALUE is undefined. Hence, unset it
            [[ ${OPTARG} != *=* ]] && unset OPTVALUE OPTVALUEIND


            # Classify the LOOKAHEAD
            OPTLOOKAHEAD=NON_VALUE
            (( $OPTIND <= ${#} )) && [[ ${!OPTIND} != -* ]] && \
              OPTLOOKAHEAD="VALUE"
          }
          ######################################################################

          case "${OPTBANNER}" in


            ## --Option that does NOT have a value
              ( ignore-case )

                ${ILLUSTRATE} && {
                  echo "The option '--${OPTBANNER}' has been identified."
                  echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                  echo
                }
                ${TEST} && {
                  echo -n "'--${OPT_BANNER}' "
                }


                # Insert User's Code Here
                #   e.g., turn case insensitivity (see option "i" above)

                ;;

            ## --Option that MUST have a value
              ( dir )

                #######################################################
                # The following code should be provided by the "system"
                # If the look ahead is VALUE consume it
                {
                  if [[ -z "${OPTVALUE+set}" ]] ; then
                    # Get the value from the LOOKAHEAD and consume it
                    if [[ ${OPTLOOKAHEAD} == "VALUE" ]] ; then
                      # ADVANCE
                      OPTVALUEIND=${OPTIND}
                      OPTVALUE=${!OPTIND}
                      OPTVALUE=${OPTVALUE/\\-/-}    # Un-Escape the "-"
                      (( OPTIND ++ ))
                    else
                      if (( ${OPTERR} != 0 )) ; then
                        echo ${0}: option requires an argument --${OPTBANNER} > /dev/stderr
                        break
                      fi
                    fi
                  fi

                  if [[ -z "${OPTVALUE+set}" ]] ; then
                    # By definition OPTVALUE needs to be defined
                    # This is here to show what a programmer should do if
                    # OPTERR != 0
                    :
                    echo ${0}: option requires an argument --${OPTBANNER} > /dev/stderr
                    break
                  fi
                }
                #######################################################
                ${ILLUSTRATE} && {
                  echo "The option '--${OPTBANNER}' has been identified with the value '${OPTVALUE}'."
                  echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                  echo "    '${OPTVALUE}' stems from \${${OPTVALUEIND}} == '${!OPTVALUEIND}'."
                  echo
                }
                ${TEST} && {
                    echo -n "'--${OPT_BANNER}' '${OPTVALUE/#-/\\-}' "
                }


                # Insert User's Code Here

                ;;


             ## --Option that MAY have a value
             ( tag )
                ######################################################################
                { # The following code should be provided by the "system"

                  if [[ -z "${OPTVALUE+set}" ]] && [[ ${OPTLOOKAHEAD} == "VALUE" ]] ; then
                    # ADVANCE
                    OPTVALUEIND=${OPTIND}
                    OPTVALUE=${!OPTIND} 
                    OPTVALUE=${OPTVALUE/\\-/-}    # Un-Escape the "-"
                    (( OPTIND ++ ))
                  fi
                }
                ######################################################################
                ${ILLUSTRATE} && {
                  if [[ ! -z ${OPTVALUE+set} ]] ; then
                    echo "The option '--${OPTBANNER}' has been identified with the value '${OPTVALUE}'."
                    echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                    echo "    '${OPTVALUE}' stems from \${${OPTVALUEIND}} == '${!OPTVALUEIND}'."
                  else
                    echo "The option '--${OPTBANNER}' has been identified without a value."
                    echo "    '--${OPTBANNER}' stems from \${${OPTBANNERIND}} == '${!OPTBANNERIND}'."
                  fi
                  echo
                }
                ${TEST} && {
                  if [[ ! -z ${OPTVALUE+set} ]] ; then
                    echo -n "'--${OPTBANNER}' '${OPTVALUE/#-/\\-}' "
                  else
                    echo -n "'--${OPTBANNER}' "
                  fi
                }


                # Insert User's Code Here

                ;;

            ## Invalid options
             ( * )
                (( ${OPTERR} != 0 )) &&
                  echo ${0}: illegal option --${OPTBANNER} > /dev/stderr
                ;;
          esac
          ;;
    ## Invalid options
     ( * )
      (( ${OPTERR} != 0 )) &&
        echo ${0}: illegal option --${OPTBANNER} > /dev/stderr
      ;;
    esac
  done
  shift $(( OPTIND -1 ))

  ${ILLUSTRATE} && {
    if [[ $# == 0 ]] ; then
      echo "There are no remaining arguments to fictitious."
    else
      echo -n "The arguments to fictitious are: "
      for i in "$@" ; do
         echo -n "'$i' "
      done
    fi
    echo
  }
  ${TEST} && {
    echo -n "'--'' "
    for i in "$@" ; do
      echo -n "'$i' "
    done
    echo
  }

  # Step 2: Continue with the processing of `fictitious`

  return
}



## Main:

if [[ "$#" == 0 ]] ; then
  set -- --dir --dir=/usr/bin  --dir /local/sbin -d arg1 arg2
fi
${ILLUSTRATE} && {
  echo fictitious "$@"
  echo
}
fictitious "$@"



# Lessons Learned:
#
#   Programming Clarity:
#
#     1. It would be better if the option of -i and -ignore-case were together
#        in the same switch case
#
#     2. Management of values for long form options must be managed by the programmer.
#        It would be better if a double switch case was not require
#
#     3. It would be better if there was way to "mark" long-form option as to their
#        argument type as is the case with short-form options
#        (Note this is provided by getopt)
#
#     4. Although all can be done using getopts, a much cleaner approach would
#        be better.
#
#     5. Terminology is muddle with using getopts with long dash forms
#        The implementation here hints at how to frame within a "better" utility
#
#     6. Case options are more readable if the options are presented more fully
#        e.g.,     ( -l | --long )

# Getopts loses fidelity when in silent mode
#   - silent mode is initiated with a ":" prepended to OPTSTRING
#   - in regular mode, the name is set to \? for both
#     1. invalid option: illegal option -- x
#     1. missing value: option requires an argument -- f
#   - in silent mode, the name is set to \:
#     1. only if missing an argument
#   * As such, in regular mode,
#     - programmer needs to more analysis with OPTSTRING to determine the root of the error
#




   # -xd-tag is valid

