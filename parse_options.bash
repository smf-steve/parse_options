#! /bin/bash
 

# ${character_options/*${opt}:*/${opt}:}    # Check for the option with an argument
# ${character_options/*${opt}*/${opt}}      # Check for the option without argument



# ${string_options/*${opt}:*/}    # Check for the option with separate argument 
# ${string_options/*${opt}=*/}    # Check for the option with combined argument
# ${string_options/*${opt}*/}     # Check for the option without argument


# {string_options/*${opt}[:=]*}
# --




# issue of a single -
#   which is a place holder for an input arg that is a file..
#   technically you would need to us -- before the arguments
#   or this signals that it is the first argument
#   Isn't this the same with a single +
#     i.e., not an option but an arg to be handled by the script
#
# quesion
#   what happens if there is a duplicate in the options spec
#     "s:mvea" verus "s:mveas"   notice two uses of "s"
#
# OPTIND
# OPTARG
# OPTPREFIX   ( - | + | -- )

# parse_options  character_options string_options name args
# 
#  example of character_options:   "ab:c:d"
#  example of string_options: "apple bear: char= debug"
# 
#  example usage:
# 
#    $0 -a -b value -c3 -d --apple --bear black --chair=red --debug
#


# This implementationon handles the identification of an option
# It does not determine is said option is valid
# Nor does it handle OPTARG

OPTPREFIX=""
OPTNAME=""
OPTARG=""
OPTERR=1
OPTIND=1


function parse_options() {
  [[ ${#} != 4 ]] && return 1

  local character_options=${1}
  declare -a string_options=( ${2} )
  local name="${3}"
  declare -a args=( ${4} )

  #declare -p character_options
  #declare -p string_options
  #declare -p name
  #declare -p args

  local current_arg=${args[OPTIND-1]}
  local option="\?"
  local retval=1

  OPTNAME=""
  OPTARG=""

  case "${current_arg}" in
    ( "--" )
        # This marks all options processed
        (( OPTIND ++ ))
        retval=1
        ;;

    ( "--"* ) 
        # This is a string_option
        OPTPREFIX="--"

        option="${current_arg:2}"
        OPTARG="double" 

        (( OPTIND ++ ))
        retval=0
        ;;

    ( "-"?* | "+"?* )
        # There must be at least one character after the OPTion PREFIX
        OPTPREFIX="${current_arg:0:1}"

        set -x
        option="${current_arg:1}"
        if [[ -z ${character_options/*${option}*/} ]]  ; then
           # Yes, the "option" is a defined option
           OPTARG="single" 

           echo ${option} is an defined option

           (( OPTIND ++ ))
           retval=0
        fi

   
        ;;

    ( * )  # can a single '-' be place here to denote stdin
        # This is the first argument
        OPTPREFIX=""

        # Don't increment OPTIND
        retval=1
        ;;
  esac

  eval "${name}=\${option}"
  OPTNAME=${option}
  return ${retval}
}



function test_parse_options () {
  local args="$@"

  while parse_options "abcd" "apple bear quit" smf "$args" ; do
    echo =======
    echo $OPTIND
    echo $OPTPREFIX
    echo $OPTNAME $smf
    echo $OPTARG
  done
  echo =======
  echo $OPTIND
  echo $OPTPREFIX
  echo $OPTNAME $smf
  echo $OPTARG
  echo =======
  echo 
  shift $(( OPTIND -1 ))
  for i in "$@" ; do
    echo $i
  done
}



