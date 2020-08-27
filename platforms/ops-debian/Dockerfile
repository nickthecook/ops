FROM debian:buster

RUN apt-get update
RUN apt-get install -y ruby ruby-dev build-essential git

# COPY ops/* /ops/
WORKDIR /ops
RUN gem install --no-ri --no-rdoc bundler

CMD bundle && bin/ops up && bin/ops test
