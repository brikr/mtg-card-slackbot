#!/bin/bash

cd `dirname "${BASH_SOURCE[0]}"`

git pull

pkill -f mtg-card.rb
nohup ruby mtg-card.rb &

exit 0
