FROM ruby

WORKDIR /opt/blog

COPY Gemfile .

RUN bundle install 

COPY . /opt/blog

RUN jekyll build --source site

EXPOSE 4000

# Do not run jekyll, since it adds cache-control header and does other nasty stuff
# Our site is static html anyway
CMD [ "ruby", "-run", "-e", "httpd", "_site", "-b", "0.0.0.0", "-p", "4000" ]