#!/bin/sh

# Usage:
#
#   ./did-it-for-the-vine.sh VINE_USERNAME VINE_PASSWORD
#
# You can also run it as
#
#   ./did-it-for-the-vine.sh
#
# and it will prompt for your username/password.
#
# After entering your username once, it won't ask again.

set -eo pipefail

set_vine_username_and_password(){
  if [ -z "$1" ] || [ -z "$2" ]; then
    if [ -f .vine-credentials ]; then
      vine_username=$(head -1 .vine-credentials)
      vine_password=$(tail -1 .vine-credentials)
    else
      read -rp "What is your Vine username? " vine_username
      read -rp "What is your Vine password? " vine_password
    fi
  else
    vine_username=$1
    vine_password=$2
  fi
}

set_vine_username_and_password "$@"
echo "$vine_username" > .vine-credentials
echo "$vine_password" >> .vine-credentials

# likes-vines.rb reads likes.json, so we can't write to it or it'll end up empty
# Fun fact: situations like this are exactly why `sponge` exists. It's available
# here: https://joeyh.name/code/moreutils/
# I won't use it though, because I want this to work out of the box.
if ./liked-vines.rb "$vine_username" "$vine_password" > newlikes.json; then
  mv newlikes.json likes.json
else
  rm newlikes.json
  exit 1
fi

./download-and-make-blog-posts.rb likes.json
