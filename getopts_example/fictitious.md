# Man Page for a fictitious command

## NAME
  fictitious – a fictitious command

## SYNOPSIS
  fictitious [options] [--] [ arg ... ]

## DESCRIPTION

  ```plain text
  A fictitious program to demonstrate command-line
  processing.  Refer to the implementation in the file
  'fictitious'.  The following options are available:

  Options with no arguments
    -x         Add a description for this option.
    -l         Add a description for this option.
    -t         Add a description for this option.

  Options with mandatory arguments
    -f file    Add a description for this option.

  Option with optional arguments
    -d[N]      Add a description for this option.
    -d N       Add a description for this option.

  Long Option with no arguments
    -i, --ignore-case
            Add a description for this option.
            Note that there is an equivalent short option.

  Long option with mandatory arguments (two styles)
    --dir path
    --dir=path
            Add a description for this option.

  Long option with option argument (two styles)
    --tag [pattern]
    --tag[=pattern]
            Add a description for this option.
  ```

## SEE ALSO
  getopts(1), getopt(1), gnu_getopt(1)

## ISSUES
  The first argument may be incorrectly determined to be the optional argument of the last option. Consider the following invocation of fictitious

  ```bash
  fictitious --tag arg1 arg2
  ```

  Is the optional argument for `--tag` null or is it `arg1`?  To resolve the ambiguity the programmer must include the "--" separator appropriately.

    - case 1: `fictitious --tag -- arg1 arg2`
    - case 2: `fictitious --tag arg1 -- arg2`

  Otherwise, the greedy principle is applied to resolve the ambiguity with `case 2` being the final interpretation. 

