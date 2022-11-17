#!/usr/bin/env bash

# Copyright 2022  Ziang Zhou
# Adapted From:
# Copyright 2014  Johns Hopkins University (author: Daniel Povey)
# Apache 2.0

remove_archive=false

if [ "$1" == --remove-archive ]; then
  remove_archive=true
  shift
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 [--remove-archive] <data-base> <url-base>"
  echo "With --remove-archive it will remove the archive after successfully un-tarring it."
  exit 0;
fi

data=$1
url=$2

if [ ! -d "$data" ]; then
  echo "$0: no such directory $data"
  exit 1;
fi

if [ -z "$url" ]; then
  echo "$0: empty URL base."
  exit 1;
fi

if [ -d $data/MELD.Raw ]; then
  echo "$0: meld directory already exists in $data"
  exit 0;
fi

if [ -f $data/MELD.Raw.tar.gz ]; then
  echo "$data/MELD.Raw.tar.gz exists"
fi

if [ ! -f $data/MELD.Raw.tar.gz ]; then
  if ! which wget >/dev/null; then
    echo "$0: wget is not installed."
    exit 1;
  fi
  full_url=$url/MELD.Raw.tar.gz
  echo "$0: downloading data (11 GB) from $full_url."

  cd $data
  if ! wget --no-check-certificate $full_url; then
    echo "$0: error executing wget $full_url"
    exit 1;
  fi
fi

cd $data

if ! tar -xvzf MELD.Raw.tar.gz; then
  echo "$0: error un-tarring archive $data/MELD.Raw.tar.gz"
  exit 1;
fi

echo "$0: Successfully downloaded and un-tarred $data/MELD.Raw.tar.gz"

if $remove_archive; then
  echo "$0: removing $data/MELD.Raw.tar.gz file since --remove-archive option was supplied."
  rm $data/MELD.Raw.tar.gz
fi
