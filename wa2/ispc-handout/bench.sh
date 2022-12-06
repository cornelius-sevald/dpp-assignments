#!/bin/bash

set -euo pipefail

RUNS_DEFAULT=100
DATA_SEP=':'

# Require 'cmd' is available
# Optionally takes different 'name' for 'cmd' as 2nd argument.
# Exits with code 1 if command is not available.
function require_cmd () {
  cmd="$1"
  name="$cmd"
  if [[ -n ${2+x} ]]
  then
    name="$2"
  fi

  if ! which "$cmd" >/dev/null 2>&1
  then
    echo "You need $name installed"
    exit 1
  fi
}

# Print usage and exits with exit code 1
function usage () {
  echo "Usage: $(basename "$0") [-n RUNS] PROG"
  echo
  echo "Run PROG RUNS times (default $RUNS_DEFAULT) and"
  echo "get the average of the C and ISPC runtimes."
  exit 1
}

function bench () {
  prog="$1"
  runs="$2"
  outfile="$3"
  for _ in $(seq "$runs")
  do
    ./"$prog" | sed 's/ *microseconds//' | sed 's/: */:/'
  done > "$outfile"
}

function process () {
  infile="$1"
  {   printf "type%savg. runtime (μs)\n" "$DATA_SEP";
      datamash -t"$DATA_SEP" --sort --group 1 mean 2 <"$infile";
  } | column -s "$DATA_SEP" -t
}

function main () {
  prog="$1"
  runs="$2"

  # dry run
  #bench "$prog" 1 /dev/null

  datafile="$(mktemp)"
  bench "$prog" "$runs" "$datafile"
  process "$datafile"
}

runs="$RUNS_DEFAULT"

while getopts ':n:' OPTION; do
  case "$OPTION" in
    n)
      runs="$OPTARG"
      ;;
    ?)
      usage
      ;;
  esac
done

shift $((OPTIND - 1))

if [ -z ${1+x} ]
then
  usage
else
  prog="$1"
fi

require_cmd "datamash" "GNU datamash"
require_cmd "column"

main "$prog" "$runs"
