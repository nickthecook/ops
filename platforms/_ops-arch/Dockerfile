# old version of arch because anything from mid-Feb 2021 on is broken
# https://bbs.archlinux.org/viewtopic.php?id=263630
FROM archlinux:base-20210120.0.13969

# don't use -u or the above bug will appear
RUN pacman -Sy --noconfirm
# dependencies for installing ops
RUN pacman -S --noconfirm ruby base-devel git  keychain openssh inetutils
# dependencies for running ops
# this won't run without GLIBC 2.33, so we're kind of screwed
RUN pacman -S --noconfirm
# add gem bin path to PATH
RUN echo "export PATH=\"\$PATH:$(ruby -e 'puts Gem.user_dir')/bin\"" >> /root/.profile

WORKDIR /ops
RUN gem install --no-user-install --no-document ops_team

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
