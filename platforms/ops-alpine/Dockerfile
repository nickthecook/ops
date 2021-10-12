FROM alpine:3

RUN apk update
# dependencies for installing ops
RUN apk add ruby-full ruby-dev alpine-sdk git
# dependencies for running ops
RUN apk add openssh keychain
# add gem bin path to PATH
RUN echo "PATH=\"$PATH:$(ruby -e 'puts Gem.user_dir')/bin\"" >> ~/.profile

WORKDIR /ops
RUN gem install --no-user-install ops_team

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
