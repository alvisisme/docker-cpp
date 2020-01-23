FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get -y install \
      git gnupg wget curl ca-certificates tar python3 \
      g++ \
      autoconf automake make cmake \
      doxygen graphviz && \
    rm -rfv /var/lib/apt/lists/*


RUN cd /usr/bin \
	&& ln -s python3 python

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 19.3.1
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/ffe826207a010164265d9cc807978e3604d18ca0/get-pip.py
ENV PYTHON_GET_PIP_SHA256 b86f36cc4345ae87bfd4f10ef6b2dbfa7a872fbff70608a1e43944d283fd0eee

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
    pip install cpplint; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py


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

