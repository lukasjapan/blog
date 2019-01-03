#!/bin/bash

cd "$(dirname "$0")"

# build jekyll to _site
bundle exec jekyll build --source site

# copy to cvguy
scp -r _site/* cvguy.de:/var/www/blog/
