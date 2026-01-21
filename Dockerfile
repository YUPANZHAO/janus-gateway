FROM centos:centos7

RUN rm -f /etc/yum.repos.d/CentOS-Base.repo \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && yum clean all \
    && yum makecache

RUN yum -y install epel-release
RUN yum -y install jansson-devel \
    openssl-devel libsrtp-devel glib2-devel \
    opus-devel libogg-devel libcurl-devel pkgconfig \
    libconfig-devel libtool autoconf automake \
    git gcc gcc-c++ cmake \
    meson wget make net-tools which

WORKDIR /tmp
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz \
    && tar xfv v2.2.0.tar.gz \
    && cd libsrtp-2.2.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make -j4 shared_library && make install

WORKDIR /tmp
RUN git clone https://github.com/sctplab/usrsctp.git \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 \
    && make -j4 && make install

WORKDIR /tmp
RUN git clone https://libwebsockets.org/repo/libwebsockets \
    && cd libwebsockets \
    && git checkout v4.3-stable \
    && mkdir build \
    && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make -j4 && make install

WORKDIR /tmp
RUN git clone https://github.com/eclipse/paho.mqtt.c.git \
    && cd paho.mqtt.c \
    && make -j4 && make install

WORKDIR /tmp
RUN git clone https://gitlab.freedesktop.org/libnice/libnice.git \
    && cd libnice \
    && meson --prefix=/usr build && ninja -C build && ninja -C build install

WORKDIR /tmp
RUN git clone https://github.com/freeswitch/sofia-sip.git \
    && cd sofia-sip \
    && git checkout v1.13.17 \
    && sh autogen.sh \
    && ./configure \
    && make -j4 && make install

WORKDIR /tmp
RUN wget https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest.tar.gz \
    && tar -zxvf libmicrohttpd-latest.tar.gz \
    && cd libmicrohttpd-1.0.2 \
    && ./configure \
    && make -j4 && make install

ENV PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig

# WORKDIR /tmp
# RUN git clone https://github.com/YUPANZHAO/janus-gateway.git \
#     && cd janus-gateway \
#     && git checkout zyp-dev \
#     && ./autogen.sh \
#     && ./configure --prefix=/opt/janus \
#     && make -j4 \
#     && make install \
#     && make configs