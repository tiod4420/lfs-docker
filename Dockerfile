FROM debian:stable

# Install packages
RUN apt update && apt upgrade -y
RUN apt install -y \
	    build-essential git git-lfs man-db sudo vim \
	    bash-completion bison clang gawk m4 terminfo texinfo tree wget
RUN apt clean

# Set bash as sh
RUN rm /bin/sh && ln -s bash /bin/sh

# Set user
RUN useradd -m -s /bin/bash lfs \
	    && echo "lfs ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/lfs
USER lfs
WORKDIR /home/lfs

# Set environment
ENV TERM=xterm-256color
ENV USER=lfs

# Deploy dotfiles
RUN git clone https://github.com/tiod4420/dotfiles \
	    && cd dotfiles \
	    && git checkout update \
	    && git submodule update --init --recursive \
	    && yes | ./deploy.sh
