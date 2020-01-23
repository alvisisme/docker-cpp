FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get -y install \
      git gnupg wget curl ca-certificates tar python3 python3-pip \
      g++ \
      autoconf automake make cmake \
      doxygen graphviz && \
    rm -rfv /var/lib/apt/lists/*

RUN pip install cpplint

ENV GTEST_VERSION 1.8.1
RUN curl -fsSLO --compressed "https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz" \
    && mkdir -p /opt \
    && tar -zxf release-${GTEST_VERSION}.tar.gz -C /opt \
    && cd /opt/googletest-release-${GTEST_VERSION} \
    && cmake . \
    && make \
    && make install \
    && ldconfig \
    && rm -rf release-${GTEST_VERSION}.tar.gz \
    && rm -rf /opt/googletest-release-${GTEST_VERSION}

