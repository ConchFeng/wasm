FROM trzeci/emscripten:1.39.8-upstream AS baseBuild
ARG packages="build-essential git cmake \
python3 \
python \
ninja-build \
build-essential \
wget \
"
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN apt-get update && apt-get install -q -yy $packages
RUN mkdir -p /root/dev
WORKDIR /root/dev

FROM baseBuild AS qtbuilder
RUN mkdir -p /development
WORKDIR /development
# RUN git clone --branch=$targetBranch git://code.qt.io/qt/qt5.git
RUN wget https://download.qt.io/archive/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz
RUN tar -xvJf qt-everywhere-src-5.15.0.tar.xz
WORKDIR /development/qt5
RUN mkdir -p /development/qt5_build
WORKDIR /development/qt5_build
RUN /development/qt-everywhere-src-5.15.0/configure -xplatform wasm-emscripten -nomake examples -nomake tests -opensource -feature-thread --confirm-license -prefix /usr/local/Qt
RUN make module-qtbase module-qtdeclarative -j `grep -c '^processor' /proc/cpuinfo`
RUN make install
FROM baseBuild AS userbuild
COPY --from=qtbuilder /usr/local/Qt /usr/local/Qt
ENV PATH="/usr/local/Qt/bin:${PATH}"
WORKDIR /project/build
CMD /usr/local/Qt/bin/qmake /project/source && make -j `grep -c '^processor' /proc/cpuinfo`
