FROM debian:stable

# Install packages
RUN apt update && apt upgrade -y
RUN apt install -y \
	    build-essential fdisk file git git-lfs locales man-db sudo vim \
	    bash-completion bison clang gawk m4 terminfo texinfo tree wget
RUN apt clean

# Set bash as sh
RUN rm /bin/sh && ln -s bash /bin/sh
RUN mv /etc/bash.bashrc{,.NOUSE}

# Create user
RUN useradd -m -k /dev/null -s /bin/bash lfs \
	    && echo "lfs ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/lfs

# Set user and environment
USER lfs
WORKDIR /home/lfs

ENV USER=lfs
ENV TERM=xterm-256color
ENV LFS=/mnt/lfs

# Copy dotfiles
COPY --chown=lfs:lfs dotfiles/bashrc .bashrc
COPY --chown=lfs:lfs dotfiles/bash_profile .bash_profile
