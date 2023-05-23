#!/bin/bash

usage() {
  # shellcheck disable=SC2028
  echo "Usage:"
  echo "$0 [-r <rebuild image>]"
  exit
}

rebuild=false
clean=false

while getopts ':rch' opt ; do
   case $opt in
      r) rebuild=true
        ;;
      c) clean=true
        ;;
      h)
         usage
         exit
         ;;
      *)
         echo "Error: Invalid option"
         usage
         exit 1 ;;
   esac
done

shift "$((OPTIND - 1))"

docker compose down

if [ "$clean" ]; then
  docker volume rm grpc-exercise_data
fi

if [ "$rebuild" ]; then
  docker compose up --build -d
else
  docker compose up -d
fi
