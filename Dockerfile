FROM phusion/baseimage:0.9.22

MAINTAINER Michael M. Tiller  <michael.tiller@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
USER root

# Add OpenModelica stable build repo
RUN add-apt-repository 'deb http://build.openmodelica.org/apt xenial stable'
RUN curl -s http://build.openmodelica.org/apt/openmodelica.asc | apt-key add -

# Add recent nodejs repo
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Make sure apt is up to date
RUN apt-get update --fix-missing && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Now Install base Python
RUN apt-get update && apt-get install -y python python-dev python-pip python-virtualenv

# Install OpenModelica
RUN apt-get update && apt-get install -y omc=1.12.0-1 omlib-modelica-3.2.2
# omniorb python-omniorb omniidl omniidl-python

# Now a bunch of dependencies required for building the book
RUN apt-get update && apt-get install -y --no-install-recommends \
    calibre \
    git \
    latexmk \
    librsvg2-bin \
    nodejs \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-latex-extra \
    python-matplotlib \
    python-pip \
    python-scipy \
    python-sphinx \
    python-jinja2 \
    fonts-droid-fallback \
    # Install internationalization packages needed for the book
    latex-cjk-common \
    texlive-xetex \
    texlive-generic-extra \
    fonts-lmodern \
    fonts-arphic-gkai00mp fonts-arphic-ukai fonts-arphic-uming \
    fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Upgrade pip itself first
RUN pip install --upgrade pip
# Install specific tested Sphinx version + internationalization stuff
RUN pip install --upgrade 'sphinx==1.6.5'
RUN pip install --upgrade 'sphinx-intl==0.9.10'
# Because I was running into this: https://github.com/sphinx-doc/sphinx/issues/3212
# RUN pip install docutils==0.12
RUN pip install --upgrade 'docutils==0.14'
RUN pip install --upgrade 'matplotlib==2.1.0'

# Temporary: use the newest s3cmd
RUN pip install --upgrade s3cmd

# Install mathjax replacement script
RUN npm install -g mathjax-node-page@1.4.1 yarn@1.3.2

# Create a directory for all the book related stuff
RUN mkdir /opt/MBE

# The rest of this we do as a user
RUN useradd builder

COPY default_s3cfg /home/builder/.s3cfg
RUN chown builder:builder /home/builder/.s3cfg

RUN chown builder /opt/MBE
RUN chown -R builder /home/builder

USER builder

WORKDIR /opt/MBE

#RUN git clone https://github.com/xogeny/ModelicaBook.git
# Instead of checking this out from Git (because then we can
# only build *master*, we'll mount the repo as a volume)

# The default commands when run as a container
WORKDIR /opt/MBE/ModelicaBook/text
CMD ["/bin/bash"]
