#!/bin/bash

USAGE="./tf <statename> ...terraform arguments"

if [ "$#" == "0" ]; then
  echo "$USAGE"
  exit 1
fi

cd $1

shift

terraform "$@"
