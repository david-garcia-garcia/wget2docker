FROM ubuntu:24.10 as build

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    cmake \
    doxygen \
    pandoc \
    gawk \
    sed \
    perl  \
    python3 \
    python-is-python3 \
    m4 \
    bison \
    flex \
    lzip \
    lcov \
    git \
    zlib1g-dev \
    libssl-dev  \
    libnghttp2-dev \
    autoconf \
    autoconf-archive \
    autogen \
    automake \
    autopoint \
    libtool \
    pkg-config \
    texinfo \
    nettle-dev \
    libunistring-dev \
    gettext \
    make \
    libbz2-dev \
    libbrotli-dev \
    libzstd-dev \
    liblz-dev \
    libpcre2-dev  \
    libmicrohttpd-dev \
    libgpgme-dev \
    liblzma-dev \
    libgnutls28-dev \
    libgcrypt20-dev \
    git-merge-changelog \
    libidn2-0 \
    wget \
    libpsl5

#libpsl-dev # libpcre3-dev nettle-bin lzma brotli zstd lzip

# Not in the system dist repo.
# libbrotlidec >= 1.0.0 (optional, if you want HTTP brotli decompression)

WORKDIR /usr/Downloads
RUN mkdir wget-dev
RUN cd wget-dev
RUN git clone https://gitlab.com/rockdaboot/libhsts
WORKDIR /usr/Downloads/libhsts
RUN autoreconf -fi
RUN ./configure
RUN make
RUN make check
RUN make install
#WORKDIR /usr
#RUN git clone https://github.com/rockdaboot/libpsl
#WORKDIR /usr/libpsl
#RUN ./autogen.sh
#RUN ./configure --disable-dependency-tracking
#RUN make
#RUN make check
#RUN make install
WORKDIR /usr
RUN git clone https://gitlab.com/gnuwget/wget2.git --depth 1 --branch v2.1.0
WORKDIR /usr/wget2
RUN ./bootstrap
RUN ./configure --with-lzma --with-bzip2
RUN make
RUN make check
RUN make install

# Stage 2: Final stage with a smaller image
FROM ubuntu:24.10

# Copy only the necessary files from the build stage
COPY --from=build /usr/local /usr/local

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
  wget \
  libpsl5 \
  libssl-dev \
  libnghttp2-dev \
  libbz2-dev \
  libbrotli-dev \
  libzstd-dev \
  liblz-dev \
  libpcre2-dev \
  libmicrohttpd-dev \
  libgpgme-dev \
  liblzma-dev \
  libgnutls28-dev \
  libgcrypt20-dev \
  libidn2-0

ENTRYPOINT ["stdbuf", "-o", "0", "wget2"]

