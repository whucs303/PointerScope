FROM ubuntu:20.04

COPY src.tar.xz /
COPY examples.tar.xz /
COPY shell.sh /

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

WORKDIR /
RUN bash ./shell.sh