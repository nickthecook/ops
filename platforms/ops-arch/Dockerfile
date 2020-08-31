FROM archlinux:latest

RUN pacman -Syu --noconfirm
# dependencies for installing ops
RUN pacman -S --noconfirm ruby base-devel git
# dependencies for running ops
RUN pacman -S --noconfirm keychain openssh
# add gem bin path to PATH
RUN echo "PATH=\"$PATH:$(ruby -e 'puts Gem.user_dir')/bin\"" >> ~/.profile

WORKDIR /ops
RUN gem install --no-user-install --no-document bundler

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
