FROM ruby:alpine3.13

USER root
RUN apk update
# dependencies for installing ops
RUN apk add ruby-dev alpine-sdk git
# dependencies for running ops
RUN apk add openssh keychain
# add gem bin path to PATH
RUN echo "PATH=\"$PATH:$(ruby -e 'puts Gem.user_dir')/bin\"" >> ~/.profile

WORKDIR /ops
RUN gem install ops_team

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
