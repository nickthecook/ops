FROM ruby:2.7-bullseye

RUN apt-get update
# dependencies for installing ops
RUN apt-get install -y ruby ruby-dev build-essential git
# dependencies for running ops
RUN apt-get install -y keychain

WORKDIR /ops
RUN git config --global --add safe.directory /ops
RUN gem install ops_team

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
