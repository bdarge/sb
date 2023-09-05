#!/bin/bash

# shellcheck disable=SC2120
usage() {
  echo "Usage:"
  echo "$0 [-t <tag> ] $1 [-o <owner> ] $3 [-s <new sha1>]"
  echo "example move-tag.sh -t v0.0.1-alpha -o origin -s 5f6ad1f"
  exit
}

tag=''
owner=''
sha=''

while getopts ':t:o:s:h:' opt ; do
   case $opt in
      t) tag=$OPTARG
        ;;
      o) owner=$OPTARG
        ;;
      s) sha=$OPTARG
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

echo "$owner"

if [[ -z $tag  || -z $owner || -x $sha ]]
then
  # shellcheck disable=SC2028
  echo "ERROR: -o, -t  and -s are mandatory arguments. See usage:";
  # shellcheck disable=SC2119
  usage
  exit 1;
fi

#delete tag
git tag -d "$tag"

#push changes
git push "$owner" :refs/tags/"$tag"

#create a new tag
git tag "$tag" "$sha"

#push
git push "$owner" "$tag"


