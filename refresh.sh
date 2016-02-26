#!/bin/bash

cd `dirname "${BASH_SOURCE[0]}"`

git pull

pkill -f mtg_card.rb
sleep 10
nohup ruby mtg_card.rb &

exit 0
