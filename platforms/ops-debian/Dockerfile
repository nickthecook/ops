FROM debian:buster

RUN apt-get update
# dependencies for installing ops
RUN apt-get install -y ruby ruby-dev build-essential git
# dependencies for running ops
RUN apt-get install -y keychain

WORKDIR /ops
RUN gem install --no-ri --no-rdoc bundler

CMD eval `ssh-agent` && bundle install --quiet && bin/ops up && bin/ops test
