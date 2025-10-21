# CLO MUSINGS

This file contains my current musing about a new tool associated with the 
process of command-line options (CLO). 


I'm thinking of using a compiler related approach to generate the code pattern for a program.  This approach is based upon the tool "Lex/Flex". If you are familiar with Lex, perhaps the following musing give you some insight to what I'm thinking.

## Refined Definitions related to options
   - Option: must start with either "-", "--", "+"
   - Short-Form Option:
     * may not contain -, :, ;, \?
   - Condensed Option List:
     - must start with a "-"
     - an number of options with NO arguments my be present
     - only one option that requires or may have a value can be present
       - said option MUST be the last in the condensed list
    - Value
      - must NOT start with a "-"
      - can be escaped with \-
      - given shell quote the value can be presented as
        * \\-
        * '\-'
        * "\-"
      - the escape is removed during the processing of the command line
    - long options may start with a single '-'. (when -a, --alternative)
    
    - long form options are preferred.
      - getopt -o "dir" --longoptions "dir" -a -- -dir
        --> --dir, and not -d -i -r
    - give a long form and short form that match, prefer the short form
      - getopt -o "dir" --longoptions "dir" -a --  -d
        -->   -d --


1. Lex-Based skeleton specification   

  ```lex
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

  -h .*                  {
                           # "h" option requires a value
                           # you can use either ":" or ".*"
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


# Questions:
- Can I use awk instead of lex?
- Should I build a separate tool altogether
- How aggressive should I be in "parsing" values
  - is there a utility just to do regular expression matching on the fly
  - the shell can do regular expression matches
- How should the build process work?

    - .spec

      -n {number}  { {action} } ==>

      .def "-n" ""  { {support} ; OPTION_VALUE=${2} ; shift ; {action} ; }

      .lex "-n  \*{number}"  { printf "-n", $2; }


# Notes on Specification File
1. Use ":" and "::"  to conform to the usage in getopts/getops
1. Use ":" is really stating that the options is followed by anything, .*
1. Use ":{default}"  to define a default value
   - hence "::" defines an option value with a wildcard default value
1. each variable is considered a regular expression
1. a list of things can be separated by either a pipe (|) or a space
   - e.g.,
     - style="early modern apostrophus vinculum"
     - style="early | modern | apostrophus | vinculum"

1. Perhaps we can add some type of argument after the code to provide a description
    - said description code be used as part of "usage" or man page

    ```TBD
     -v | --version    { ; }
           [
             Prints the Git suite version that the git program came from.
             This option is internally converted to git version ... and accepts
              the same options as the git-version(1) command. If --help is also
              given, it takes precedence over --version.
            ]
    ```

1. Format of the format file:    TRIGGER VALUE ACTION DOC
   * example .spec line:  --file file {...} ```doc string```
     * TRIGGER="--file"
     * OPTION="--file"
     * VALUE=file
     * ACTION="{...}"
     * DOC="doc string"
   * example .spec line: (-f | --file) file {...} ```doc string ```
     * TRIGGER="--file"
     * OPTION=< either -f or --file >
     * VALUE=file
     * ACTION="{...}"
     * DOC="doc string"

1. For the output of the tool, we could canonicalize the options
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

1. alternatively for the tool to emit the canonicalize the options,
   the tool could iterative call a user defined program.
   1. given the "git log -L example"
      1. emit "-L={start} {end} {file}"
      1. "userprog" -L {start} {end} {file}
         - user program access the values via ${1}, ${2}, ${3}
