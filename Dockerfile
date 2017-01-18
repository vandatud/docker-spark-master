FROM phusion/baseimage:latest

MAINTAINER Thomas Gruender
LABEL version="spark-master-2.1"

# Install Python.
RUN \
  apt-get update && \
  apt-get install -y python3 python3-dev python3-pip python3-virtualenv && \
  apt-get install -y python3-numpy python3-wheel && \
  rm -rf /var/lib/apt/lists/*

# Install system tools
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip nano wget && \
  rm -rf /var/lib/apt/lists/*

ARG JAVA_MAJOR_VERSION=7

# Install Java
RUN \
  echo oracle-java${JAVA_MAJOR_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java${JAVA_MAJOR_VERSION}-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk${JAVA_MAJOR_VERSION}-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_MAJOR_VERSION}-oracle

ARG SPARK_VERSION=2.1.0
ARG MAJOR_HADOOP_VERSION=2.7

# download per hand because it cant compile
RUN wget http://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${MAJOR_HADOOP_VERSION}.tgz
RUN tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${MAJOR_HADOOP_VERSION}.tgz
RUN mv /spark-${SPARK_VERSION}-bin-hadoop${MAJOR_HADOOP_VERSION} /spark

WORKDIR spark

ENV SPARK_HOME /spark

expose 4040
expose 7077
expose 8080

RUN mkdir -p /etc/my_init.d
ADD spark-master.sh /etc/my_init.d/spark-master.sh
RUN chmod +x /etc/my_init.d/spark-master.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*