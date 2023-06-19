#!/bin/bash

usage() {
  echo "Usage:"
  echo "$0 [-r <rebuild image>]"
  exit
}

rebuild=false
clean=false
prod=false
DEL=false

while getopts ':rcdhp' opt ; do
   case $opt in
      r) rebuild=true
        ;;
      c) clean=true
        ;;
      d) DEL=true
        ;;
      p) prod=true
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

if "$clean" || "$DEL"; then
  docker volume rm sb_data
fi

if ! "$DEL"; then
  file=""

  if "$prod"; then
    file="-f docker-compose.yml -f docker-compose.prod.yml"
  else
    file="-f docker-compose.yml"
  fi

  if "$rebuild"; then
    docker compose $file up --build -d
  else
    docker compose $file up  -d
  fi
fi
