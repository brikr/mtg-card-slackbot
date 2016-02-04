#!/bin/bash

cd `dirname "${BASH_SOURCE[0]}"`

pkill -f mtg-card.rb
nohup ruby mtg-card.rb &

exit 0
