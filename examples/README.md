# Examples Directory

This directory contains a number of implementations for the program `fictitious`.
The fictitious program is being used as a vehicle to implement command-line
options using various support utilities.  The following programs, for fictitious,
are:These support utilities include:

  1. getopts_example.bash
     - uses the `getopts` bash utility as the cornerstone for the implementation
     - 

  1. gnu_getopt_example.bash
     - uses the `getopt` gnu executable

  1. self_example.bash
     - all programing is performed directly via the programmer
     - lesson learned and the frame work of `getopts` and `getopt` is used

  1. clo: our experimental utility to provide an improved alternative to using
     getopts or getopt


# getopts description
  Use getopts to support the processing of option and their values

  Usage:  optstring name [arg ...]
    optstring: "xltif:d:-:"                <-- Note the difference from above
      - note each short-form option is included in the string
      - a single colon (:) denotes the proceeding character requires a value
        - the option -f requires a value
        - the option -- requires a value
      - to support optional values, i.e., -d
        - treat the option as if it does NOT have an argument
        - then perform special handling if this assumption proves to be wrong
      - to support long-form options, 
        - use - as an option with a required value
        - then perform special handling for its values
    name:      flag
    [arg ...]: "$@", which is equivalent to ${1}, ${2}, ... ${!#}
  