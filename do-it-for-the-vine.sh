#!/bin/sh

# Usage:
#
#   ./do-it-for-the-vine.sh VINE_USERNAME VINE_PASSWORD
#
# You can also run it as
#
#   ./do-it-for-the-vine.sh
#
# and it will prompt for your username/password.
#
# You can re-run it at any time and it will pick up where it left off.

set -eo pipefail

if [ ! -f likes.json ]; then
  if [ -z "$1" ] || [ -z "$2" ]; then
    read -p "What is your Vine username? " vine_username
    read -p "What is your Vine password? " vine_password
  else
    vine_username=$1
    vine_password=$2
  fi

  ./liked-vines.rb "$vine_username" "$vine_password" > likes.json
fi

./download-and-make-blog-posts.rb likes.json
