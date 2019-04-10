FROM ubuntu:18.04

LABEL \
    name="Feries's JDK8-TOMCAT8-Dev Image" \
    image="jdk8-tomcat8-ant-ruby-sass-node" \
    license="GPLv3" \
    vendor="feries" \
    build-date="2019-15-03"

# Prepare to build
RUN apt-get update
RUN apt-get -y install git curl

# Install Open JDK 8
RUN apt-get -y install openjdk-8-jdk ttf-dejavu 

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Install Tomcat
ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.30 \
    CATALINA_HOME=/opt/tomcat

RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME

# Install Ant
RUN apt-get -y install ant

# Install Ruby & SASS & Compass
RUN apt-get -y install curl g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev
RUN apt-get -y install gnupg software-properties-common

RUN apt-add-repository -y ppa:rael-gc/rvm
RUN apt-get update
RUN apt-get -y install rvm
RUN /bin/bash -l -c "rvm install 2.4.2"
RUN /bin/bash -l -c "gem install sass -v 3.4.25"
RUN /bin/bash -l -c "gem install compass -v 1.0.3"

# Install NVM/Node
ENV NODE_VERSION "10.15.3"
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && source /root/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Install ImageMagick
RUN apt-get update
RUN apt-get -y install imagemagick

# Clean up
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 8080
COPY startup.sh /opt/startup.sh
ENTRYPOINT /opt/startup.sh
WORKDIR $CATALINA_HOME
