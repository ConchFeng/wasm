FROM trzeci/emscripten:1.38.45 AS baseBuild

ARG packages="build-essential git cmake \
python3 \
python \
ninja-build \
build-essential \
wget \
"
# Required for non-interactive timezone installation
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN apt-get update && apt-get install -q -yy $packages

RUN mkdir -p /root/dev
WORKDIR /root/dev

# RUN git clone https://github.com/emscripten-core/emsdk.git
# WORKDIR /root/dev/emsdk

# RUN ./emsdk install sdk-fastcomp-1.38.30-64bit
# RUN ./emsdk activate --embedded sdk-fastcomp-1.38.30-64bit

# ENV PATH="/root/dev/emsdk:/root/dev/emsdk/fastcomp-clang/e1.38.30_64bit:/root/dev/emsdk/node/8.9.1_64bit/bin:/root/dev/emsdk/emscripten/1.38.30:${PATH}"

FROM baseBuild AS qtbuilder
# ARG targetBranch=5.14.1
RUN mkdir -p /development
WORKDIR /development

# RUN git clone --branch=$targetBranch git://code.qt.io/qt/qt5.git
RUN wget https://download.qt.io/archive/qt/5.14/5.14.1/single/qt-everywhere-src-5.14.1.tar.xz
RUN tar -xvJf qt-everywhere-src-5.14.1.tar.xz

WORKDIR /development/qt5

RUN mkdir -p /development/qt5_build
WORKDIR /development/qt5_build

RUN /development/qt-everywhere-src-5.14.1/configure -xplatform wasm-emscripten -nomake examples -nomake tests -opensource -feature-thread --confirm-license -prefix /usr/local/Qt
RUN make module-qtbase module-qtdeclarative -j `grep -c '^processor' /proc/cpuinfo`
# RUN make -j `grep -c '^processor' /proc/cpuinfo`
RUN make install

# Construct the build image from user perspective
FROM baseBuild AS userbuild

COPY --from=qtbuilder /usr/local/Qt /usr/local/Qt
ENV PATH="/usr/local/Qt/bin:${PATH}"

WORKDIR /project/build
# CMD qmake /project/source && make -j `grep -c '^processor' /proc/cpuinfo`
CMD /usr/local/Qt/bin/qmake /project/source && make -j `grep -c '^processor' /proc/cpuinfo`
