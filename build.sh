#!/bin/bash

usage() {
  echo ""
  echo "A script to kill all containers and re-run them again except option -d which removes contains and volumes only."
  echo ""
  echo "Usage:"
  echo "$0 [-d <delete containers, and volumes> -r <rebuild image> -c <clean volume> -p <deploy prod images>]"
  echo "Note: The other flags have no effect, if -d is set"
  echo ""
  exit
}

rebuild=false
clean=false
prod=false
del=false

while [ "$1" != "" ] ; do
    case $1 in
        -r | --rebuild )
                                rebuild=true
                                ;;
        -c | --clean )          clean=true
                                ;;
        -p | --prod )           prod=true
                                ;;
        -d | --del )            del=true
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

docker compose down

if "$clean" || "$del"; then
  docker volume rm sb_data
fi

if ! "$del"; then
  file=""

  if "$prod"; then
    file="-f docker-compose.yml -f docker-compose.prod.yml"
  else
    file="-f docker-compose.yml"
  fi

  if [ "$rebuild" ] && [ -z "$prod" ]; then
    docker compose $file up --build -d
  else
    echo "creating for production ..."
    docker compose $file up  -d
  fi
fi
