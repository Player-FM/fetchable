#!/bin/bash

if [ "$RAILS_ENV" != 'development' ] ; then
  echo 'whoa dont blat in this environment'
  exit
fi

cd `dirname $0`/..
bundle exec rake db:drop && rake db:create && rake db:migrate && rake db:schema:dump && rake db:fixtures:load && rake db:test:prepare
