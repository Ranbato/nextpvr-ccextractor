# ffmpeg - http://ffmpeg.org/download.html
#
# From https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
# https://hub.docker.com/r/jrottenberg/ffmpeg/
#
# https://github.com/smacke/ffsubsync
#

#####
# 18.04, bionic-20220401, bionic
# 20.04, focal-20220404, focal, latest
# 21.10, impish-20220404, impish, rolling
# 22.04, jammy-20220404, jammy, devel

FROM        ubuntu:jammy AS base

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat curl libgomp1 mediainfo libutf8proc2 tesseract-ocr curl libgomp1 \
        mediainfo libfreetype6 libutf8proc2 tesseract-ocr libva-drm2 libva2 libjansson4 python3 libargtable2-0 \
        libjpeg-turbo8 libturbojpeg curl libunwind8 gettext apt-transport-https libgdiplus libc6-dev mediainfo libdvbv5-dev \
        ffmpeg hdhomerun-config dtv-scan-tables unzip i965-va-driver-shaders vainfo

#RUN curl https://nextpvr.com/nextpvr-helper.deb -O && \
#    apt -yq install ./nextpvr-helper.deb --install-recommends

RUN     ln -s /usr/bin/python3 /usr/bin/python

ENV ASPNETCORE_URLS=http://+:80 DOTNET_RUNNING_IN_CONTAINER=true

RUN dotnet_version=3.1.23 && \
  curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$dotnet_version/dotnet-runtime-$dotnet_version-linux-x64.tar.gz     && \
  mkdir -p /usr/share/dotnet && \
  tar -ozxf dotnet.tar.gz -C /usr/share/dotnet && \
  rm dotnet.tar.gz && \
  ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN aspnetcore_version=3.1.23     && \
curl -SL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-x64.tar.gz     && \
tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App     && \
rm aspnetcore.tar.gz

FROM base as build

WORKDIR     /tmp/workdir

RUN buildDeps="autoconf \
                automake \
                cmake \
                build-essential \
                curl \
                bzip2 \
                libexpat1-dev \
                g++ \
                gcc \
                git \
                gperf \
                libtool \
                make \
                nasm \
                perl \
                pkg-config \
                libssl-dev \
                yasm \
                libva-dev \
                libargtable2-dev \
                libavutil-dev \
                libavformat-dev \
                libavcodec-dev \
                libsdl1.2-dev \
                libtool \
                nasm \
                yasm \
                ninja-build \
                pkg-config \
                libnuma-dev \
                python3-pip \
                python3-setuptools \
                python3-wheel \
                libtool-bin \
                libva-dev \
                libdrm-dev \
                libass-dev \
                libbz2-dev \
                libfontconfig1-dev \
                libfreetype6-dev \
                libfribidi-dev \
                libharfbuzz-dev \
                libjansson-dev \
                liblzma-dev \
                libmp3lame-dev \
                libnuma-dev \
                libogg-dev \
                libopus-dev \
                libsamplerate-dev \
                libspeex-dev \
                libtheora-dev \
                libtool \
                libtool-bin \
                libvorbis-dev \
                libx264-dev \
                libxml2-dev \
                libvpx-dev \
                libtesseract-dev \
                zlib1g-dev \
                clang \
                libclang-dev \
                libjpeg-turbo8-dev \
                libturbojpeg0-dev \
                python3-dev \
                unzip \
                patch \
                xz-utils \
                libswscale-dev \
                libgme-dev \
                libopenmpt0 \
                libchromaprint-dev \
                libchromaprint1 \
                libbluray2 \
                gi-docgen \
                gtk-doc-tools \
                gobject-introspection \
                xcb-proto \
                python3-xcbgen \
                " && \
        apt-get -yqq update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends ${buildDeps} && \
        pip3 install --no-cache-dir meson ffsubsync

ENV             FFMPEG_VERSION=5.1.1 \
                AOM_VERSION=v3.2.0 \
                FDKAAC_VERSION=2.0.2 \
                FONTCONFIG_VERSION=2.13.96 \
                FREETYPE_VERSION=2.11.1 \
                FRIBIDI_VERSION=1.0.11 \
                KVAZAAR_VERSION=2.1.0 \
                LAME_VERSION=3.100 \
                LIBASS_VERSION=0.15.2 \
                LIBPTHREAD_STUBS_VERSION=0.4 \
                LIBVIDSTAB_VERSION=1.1.0 \
                LIBXCB_VERSION=1.14 \
                XCBPROTO_VERSION=1.14 \
                OGG_VERSION=1.3.5 \
                OPENCOREAMR_VERSION=0.1.6 \
                OPUS_VERSION=1.3.1 \
                OPENJPEG_VERSION=2.4.0 \
                THEORA_VERSION=1.2.0 \
                VORBIS_VERSION=1.3.7 \
                VPX_VERSION=1.12.0 \
                WEBP_VERSION=1.2.4 \
                X264_VERSION=20191217-2245-stable \
                X265_VERSION=3.5 \
                LIBDAV1D_VERSION=0.9.2 \
                XAU_VERSION=1.0.9 \
                XORG_MACROS_VERSION=1.19.2 \
                XPROTO_VERSION=7.0.31 \
                XVID_VERSION=1.3.5 \
                LIBXML2_VERSION=2.9.11 \
                LIBBLURAY_VERSION=1.3.0 \
                LIBZMQ_VERSION=4.3.2 \
                LIBVMAF_VERSION=1.5.3 \
                HANDBRAKE_VERSION=1.5.1 \
                LIBSTVAV1_VERSION=v0.9.0 \
                SRC=/usr/local



# # Update cmake for HandBrake
# RUN set -x && \
#         DIR=/tmp/cmake && \
#         mkdir -p ${DIR} && \
#         cd ${DIR} && \
#         curl -sL https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2.tar.gz | \
#         tar -zx --strip-components=1 && \
#         ls -al && \
#         cmake .  && \
#         make && \
#         make install



FROM build as updated_build

#https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html#x86-Options
#CFLAGS="-mtune=goldmont " \
#CXXFLAGS="-mtune=silvermont " \

ENV     MAKEFLAGS="-j 4" \
        PKG_CONFIG_PATH="/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig:${PKG_CONFIG_PATH}" \
        PREFIX=/opt/ffmpeg \
        LD_LIBRARY_PATH="/opt/ffmpeg/lib:/opt/ffmpeg/lib64:/usr/lib64:/usr/lib:/lib64:/lib:${LD_LIBRARY_PATH}" \
        CFLAGS="-mtune=native " \
        CXXFLAGS="-mtune=native "


RUN gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | grep mtune

FROM updated_build as library_build

## opencore-amr https://sourceforge.net/projects/opencore-amr/
RUN set -x && \
        DIR=/tmp/opencore-amr && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://versaweb.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --enable-shared && \
        make && \
        make install

## x264 http://www.videolan.org/developers/x264.html
RUN set -x && \
        DIR=/tmp/x264 && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        git clone https://git.videolan.org/git/x264.git --depth 1 && \
        cd x264 && \
        ./configure --prefix="${PREFIX}" --enable-shared --enable-pic --disable-cli && \
        make && \
        make install
### x265 http://x265.org/
RUN set -x && \
        DIR=/tmp/x265 && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://bitbucket.org/multicoreware/x265_git/downloads/x265_${X265_VERSION}.tar.gz  | \
        tar -zx && \
        cd x265_${X265_VERSION}/build/linux && \
        sed -i "/-DEXTRA_LIB/ s/$/ -DCMAKE_INSTALL_PREFIX=\${PREFIX}/" multilib.sh && \
        sed -i "/^cmake/ s/$/ -DENABLE_CLI=OFF/" multilib.sh && \
        ./multilib.sh && \
        make -C 8bit install
### libogg https://www.xiph.org/ogg/
RUN set -x && \
        DIR=/tmp/ogg && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLOv https://github.com/xiph/ogg/releases/download/v${OGG_VERSION}/libogg-${OGG_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f libogg-${OGG_VERSION}.tar.gz && \
        ./configure --prefix="${PREFIX}" --enable-shared  && \
        make && \
        make install
### libopus https://www.opus-codec.org/
RUN set -x && \
        DIR=/tmp/opus && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/xiph/opus/archive/refs/tags/v${OPUS_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f v${OPUS_VERSION}.tar.gz && \
        autoreconf -fiv && \
        ./configure --prefix="${PREFIX}" --enable-shared && \
        make && \
        make install
### libvorbis https://xiph.org/vorbis/
RUN set -x && \
        DIR=/tmp/vorbis && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/xiph/vorbis/archive/v${VORBIS_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f v${VORBIS_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure --prefix="${PREFIX}" --with-ogg="${PREFIX}" --enable-shared && \
        make && \
        make install
### libtheora http://www.theora.org/
RUN set -x && \
        DIR=/tmp/theora && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        git clone https://github.com/xiph/theora && \
        cd ./theora && \
        ./autogen.sh && \
        ./configure --prefix="${PREFIX}" --with-ogg="${PREFIX}" --enable-shared && \
        make && \
        make install


### libvpx https://www.webmproject.org/code/
RUN set -x && \
        DIR=/tmp/vpx && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://codeload.github.com/webmproject/libvpx/tar.gz/v${VPX_VERSION} | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --as=yasm --enable-vp8 --enable-vp9 --enable-vp9-highbitdepth --enable-pic --enable-shared \
        --disable-debug --disable-examples --disable-docs --disable-install-bins --enable-runtime-cpu-detect && \
        make && \
        make install
### libwebp https://developers.google.com/speed/webp/
RUN set -x && \
        DIR=/tmp/webp && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --enable-shared  && \
        make && \
        make install

### libmp3lame http://lame.sourceforge.net/
RUN set -x && \
        DIR=/tmp/lame && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://versaweb.dl.sourceforge.net/project/lame/lame/$(echo ${LAME_VERSION} | sed -e 's/[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)/\1.\2/')/lame-${LAME_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        ./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" --enable-shared --enable-nasm --disable-frontend && \
        make && \
        make install
### xvid https://www.xvid.com/
RUN set -x && \
        DIR=/tmp/xvid && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz && \
        tar -zx -f xvidcore-${XVID_VERSION}.tar.gz && \
        cd xvidcore/build/generic && \
        ./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" && \
        make && \
        make install
### fdk-aac https://github.com/mstorsjo/fdk-aac
RUN set -x && \
        DIR=/tmp/fdk-aac && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        autoreconf -fiv && \
        ./configure --prefix="${PREFIX}" --enable-shared --datadir="${DIR}" && \
        make && \
        make install
## openjpeg https://github.com/uclouvain/openjpeg
RUN set -x && \
        DIR=/tmp/openjpeg && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | \
        tar -zx --strip-components=1 && \
        cmake -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
        make && \
        make install
## freetype https://www.freetype.org/
RUN  \
        DIR=/tmp/freetype && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f freetype-${FREETYPE_VERSION}.tar.gz && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install
## libvstab https://github.com/georgmartius/vid.stab
RUN  \
        DIR=/tmp/vid.stab && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f v${LIBVIDSTAB_VERSION}.tar.gz && \
        cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
        make && \
        make install
## fridibi https://www.fribidi.org/
RUN  \
        DIR=/tmp/fribidi && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.xz && \
        tar -Jx --strip-components=1 -f fribidi-${FRIBIDI_VERSION}.tar.xz && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make -j1 && \
        make install
## fontconfig https://www.freedesktop.org/wiki/Software/fontconfig/
RUN  \
        DIR=/tmp/fontconfig && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.xz && \
        tar -Jx --strip-components=1 -f fontconfig-${FONTCONFIG_VERSION}.tar.xz && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install
## libass https://github.com/libass/libass
RUN  \
        DIR=/tmp/libass && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f ${LIBASS_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install
## kvazaar https://github.com/ultravideo/kvazaar
RUN set -x && \
        DIR=/tmp/kvazaar && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/ultravideo/kvazaar/releases/download/v${KVAZAAR_VERSION}/kvazaar-${KVAZAAR_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f kvazaar-${KVAZAAR_VERSION}.tar.gz && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install

RUN set -x && \
        DIR=/tmp/aom && \
        git clone --branch ${AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom ${DIR} ; \
        cd ${DIR} ; \
        rm -rf CMakeCache.txt CMakeFiles ; \
        mkdir -p ./aom_build ; \
        cd ./aom_build ; \
        cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DENABLE_TESTS=OFF -DENABLE_NASM=on -DBUILD_SHARED_LIBS=1 ..; \
        make ; \
        make install ; \
        rm -rf ${DIR}

## libxcb (and supporting libraries) for screen capture https://xcb.freedesktop.org/
RUN set -x && \
        DIR=/tmp/xproto && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://www.x.org/archive/individual/proto/xproto-${XPROTO_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f xproto-${XPROTO_VERSION}.tar.gz && \
        ./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
        make && \
        make install

RUN set -x && \
        DIR=/tmp/xorg-macros && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://www.x.org/archive//individual/util/util-macros-${XORG_MACROS_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f util-macros-${XORG_MACROS_VERSION}.tar.gz && \
        ./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
        make && \
        make install


RUN set -x && \
        DIR=/tmp/libXau && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://www.x.org/archive/individual/lib/libXau-${XAU_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f libXau-${XAU_VERSION}.tar.gz && \
        ./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
        make && \
        make install

RUN set -x && \
        DIR=/tmp/libpthread-stubs && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://xcb.freedesktop.org/dist/libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.gz && \
        ./configure --prefix="${PREFIX}" && \
        make && \
        make install

# RUN set -x && \
#         DIR=/tmp/libxcb-proto && \
#         mkdir -p ${DIR} && \
#         cd ${DIR} && \
#         curl -sLO https://xcb.freedesktop.org/dist/xcb-proto-${XCBPROTO_VERSION}.tar.gz && \
#         tar -zx --strip-components=1 -f xcb-proto-${XCBPROTO_VERSION}.tar.gz && \
#         ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
#         ./configure --prefix="${PREFIX}" && \
#         make && \
#        make install

RUN set -x && \
        DIR=/tmp/libxcb && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://xcb.freedesktop.org/dist/libxcb-${LIBXCB_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f libxcb-${LIBXCB_VERSION}.tar.gz && \
        ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
        ./configure --prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install

## libxml2 - for libbluray
RUN set -x && \
        DIR=/tmp/libxml2 && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${LIBXML2_VERSION}/libxml2-v${LIBXML2_VERSION}.tar.gz && \
        tar -xz --strip-components=1 -f libxml2-v${LIBXML2_VERSION}.tar.gz && \
        ./autogen.sh --prefix="${PREFIX}" --with-ftp=no --with-http=no --with-python=no && \
        make && \
        make install

## libbluray - Requires libxml, freetype, and fontconfig
RUN set -x && \
        DIR=/tmp/libbluray && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://download.videolan.org/pub/videolan/libbluray/${LIBBLURAY_VERSION}/libbluray-${LIBBLURAY_VERSION}.tar.bz2 && \
        tar -jx --strip-components=1 -f libbluray-${LIBBLURAY_VERSION}.tar.bz2 && \
        ./configure --prefix="${PREFIX}" --disable-examples --disable-bdjava-jar --disable-static --enable-shared && \
        make && \
        make install


## libvmaf
RUN set -x && \
        DIR=/tmp/libvmaf  && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        git clone https://github.com/Netflix/vmaf && \
        cd vmaf/libvmaf && \
        meson  --prefix ${PREFIX} --buildtype release build && \
        ninja -vC build && \
        ninja -vC build install


## av1  https://code.videolan.org/videolan/dav1d
RUN set -x && \
        DIR=/tmp/dav1d && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sL https://code.videolan.org/videolan/dav1d/-/archive/${LIBDAV1D_VERSION}/dav1d-${LIBDAV1D_VERSION}.tar.gz |  \
        tar -zx --strip-components=1  && \
        meson --prefix ${PREFIX} --default-library both --buildtype release build && \
        ninja -vC build && \
        ninja install -vC build

## libsvtav1  https://gitlab.com/AOMediaCodec/SVT-AV1/-/tags
RUN \
        DIR=/tmp/svtav1 && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git ${DIR} --depth=1 -b ${LIBSTVAV1_VERSION} &&\
        cd Build && \
        cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" && \
        make  && \
        make install

FROM library_build as rustlib_build

# install rust for ccextractor and Comskip
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="$HOME/.cargo/bin:/root/.cargo/bin:$PATH"


# RUN find / -name cargo && false

FROM library_build as ffmpeg_build

## ffmpeg https://ffmpeg.org/
RUN  \
        DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
        curl -sLO https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
        tar -jx --strip-components=1 -f ffmpeg-${FFMPEG_VERSION}.tar.bz2

RUN \
cp /opt/ffmpeg/lib/x86_64-linux-gnu/pkgconfig/* /opt/ffmpeg/lib/pkgconfig && \
cp -v /opt/ffmpeg/lib/x86_64-linux-gnu/lib* /usr/local/lib/
#RUN find / -name libvmaf.so.1 && false

RUN set -x && \
        DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
        ./configure \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --enable-shared \
        --enable-libopencore-amrnb \
        --enable-libopencore-amrwb \
        --enable-gpl \
        --enable-libass \
        --enable-fontconfig \
        --enable-libfreetype \
        --enable-libvidstab \
        --enable-libdav1d \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libxcb \
        --enable-libx265 \
        --enable-libxvid \
        --enable-libx264 \
        --enable-nonfree \
        --enable-openssl \
        --enable-libfdk_aac \
        --enable-postproc \
        --enable-small \
        --enable-version3 \
        --enable-libbluray \
        --extra-libs=-ldl \
        --prefix="${PREFIX}" \
        --enable-libopenjpeg \
        --enable-libkvazaar \
        --enable-libaom \
        --extra-libs=-lpthread \
        --enable-vaapi \
        --enable-libvmaf \
        --enable-libsvtav1 \
        --extra-cflags="-I${PREFIX}/include" \
        --extra-ldflags="-L${PREFIX}/lib" && \
        make && \
        make install && \
        make distclean && \
        hash -r && \
        cd tools && \
        make qt-faststart && cp qt-faststart ${PREFIX}/bin/

## ffmpeg cleanup
RUN set -x && \
        ldd ${PREFIX}/bin/ffmpeg | grep opt/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} /usr/local/lib/ && \
        cp ${PREFIX}/bin/* /usr/local/bin/ && \
        cp -r ${PREFIX}/share/ffmpeg /usr/local/share/ && \
        LD_LIBRARY_PATH=/usr/local/lib ffmpeg -buildconf


FROM rustlib_build as extras_build


RUN  set -x &&   cd /tmp && \
        git clone https://github.com/CCExtractor/ccextractor && \
        cd ccextractor/linux && \
        ./autogen.sh && \
        ./configure --enable-ocr  && \
        make


# get comchap && comcut
RUN  set -x &&   cd /tmp && \
        git clone https://github.com/BrettSheleski/comchap


#build HandBrakeCLI see https://handbrake.fr/docs/en/1.3.0/developer/install-dependencies-ubuntu.html
#https://www.reddit.com/r/handbrake/comments/bnadr6/guide_how_to_custom_build_handbrake_eg_fdk_aac/

RUN set -x &&   cd /tmp && \
        git clone https://github.com/HandBrake/HandBrake && \
        cd HandBrake && \
        git checkout tags/${HANDBRAKE_VERSION}

RUN cd /tmp/HandBrake && ./configure  --enable-x265 --enable-qsv --enable-vce --enable-fdk-aac --disable-gtk --launch-jobs=4 --launch


# Install youtube-dl because we can
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && \
        chmod a+rx /usr/local/bin/youtube-dl

# Install yt-dlp because we can
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
        chmod a+rx /usr/local/bin/yt-dlp


FROM rustlib_build as comskip_build

# compile comskip
RUN   set -x && cd /tmp && PREFIX= \
        git clone https://github.com/erikkaashoek/Comskip


# RUN cd /tmp/libbluray && \
#     ./configure --enable-static --disable-bdjava-jar && \
#     make install
#
# RUN cd /tmp/webp && \
#     ./configure  --enable-static  && \
#     make clean && \
#     make install
#
#
# RUN cd /tmp && \
#     curl -sLO https://www.libssh.org/files/0.9/libssh-0.9.6.tar.xz && \
#     tar -xJf libssh-0.9.6.tar.xz && \
#     mkdir -p libssh-0.9.6/build && \
#     cd libssh-0.9.6/build && \
#     cmake -DBUILD_SHARED_LIBS=OFF .. && \
#     make install
#
# RUN cd /tmp && \
#     curl -sLO https://bitbucket.org/mpyne/game-music-emu/downloads/game-music-emu-0.6.3.tar.xz && \
#     tar -xJf game-music-emu-0.6.3.tar.xz && \
#     mkdir -p game-music-emu-0.6.3/build && \
#     cd game-music-emu-0.6.3/build && \
#     cmake -DBUILD_SHARED_LIBS=OFF .. && \
#     make install
#
#
# RUN cd /tmp && \
#     curl -sLO https://github.com/OpenMPT/openmpt/archive/refs/tags/OpenMPT-1.30.03.00.tar.gz && \
#     tar -xf OpenMPT-1.30.03.00.tar.gz && \
#     cd openmpt-OpenMPT-1.30.03.00 && \
#     STATIC_LIB=1 && EXAMPLES=0 && TEST=0 && PREFIX= && make clean && make install
#
#
# RUN cd /tmp && \
#     curl -sLO https://github.com/acoustid/chromaprint/releases/download/v1.5.1/chromaprint-1.5.1.tar.gz && \
#     tar -xf chromaprint-1.5.1.tar.gz && \
#     cd chromaprint-1.5.1 && \
#     cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_TOOLS=ON -DBUILD_TESTS=OFF . && \
#     make install
#
# RUN apt-get install -y python3-cairo-dev libcairo-gobject2 gdk-pixbuf-2.0-0 libgdk-pixbuf-2.0-dev libpango1.0-dev libpangoft2-1.0-0 libgirepository1.0-dev \
# libgnutls28-dev libgnutls30 librabbitmq-dev libsrt-gnutls-dev libczmq-dev && \
#     cp /opt/ffmpeg/lib/x86_64-linux-gnu/pkgconfig/* /opt/ffmpeg/lib/pkgconfig && \
#     cp /opt/ffmpeg/lib/x86_64-linux-gnu/lib* /usr/local/lib/
#
# RUN cd /tmp && \
#     curl -sLO https://gitlab.gnome.org/GNOME/librsvg/-/archive/2.52.8/librsvg-2.52.8.tar.gz && \
#     tar -xf librsvg-2.52.8.tar.gz && \
#     cd librsvg-2.52.8 && \
#     PATH="$PATH:/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0" ./autogen.sh --enable-static && \
#     make install
#
# RUN cd /tmp && \
#     curl -sLO https://cfhcable.dl.sourceforge.net/project/zapping/zvbi/0.2.35/zvbi-0.2.35.tar.bz2 && \
#     tar -xf zvbi-0.2.35.tar.bz2 && \
#     cd zvbi-0.2.35 && \
#     ./configure --enable-static && \
#     make install
#
#
# RUN mkdir -p /usr/lib/gdk_pixbuf-2.0 && \
#     cp -R /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/* /usr/lib/gdk_pixbuf-2.0 && \
# #    find / -name 'gdk-pixbuf-2.0' && \
#   pkg-config --list-all && \
#     whereis gdk_pixbuf-2.0 && whereis gdk-pixbuf-2.0 && ls -l /usr/lib/gdk_pixbuf-2.0/2.10.0/loaders && false


RUN   cd /tmp/Comskip && \
        ./autogen.sh && \
        ./configure --enable-donator && \
        make && make install

RUN cd /tmp && \
    curl -sLO https://github.com/NixOS/patchelf/archive/refs/tags/0.14.5.tar.gz && \
    tar -xf 0.14.5.tar.gz && \
    cd patchelf-0.14.5 && \
    ./bootstrap.sh && ./configure && \
    make install

RUN which patchelf
RUN mkdir -p /tmp/Comskip/comskiplibs && \
  ldd /tmp/Comskip/comskip | cut -d ' ' -f 3 | xargs -i cp {} /tmp/Comskip/comskiplibs && \
  patchelf --set-rpath \$ORIGIN/comskiplibs /tmp/Comskip/comskip

FROM        base AS release

LABEL maintainer="Mark Lambert <ranbato@gmail.com>"

ENV         LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:/lib:/lib64

## Copy everything from build images to final image

COPY --from=ffmpeg_build /usr/local /usr/local/

#copy ccextractor, comskip, comcut, ffsubsync, and HandBrakeCLI
COPY --from=extras_build /tmp/ccextractor/linux/ccextractor \
        /tmp/comchap/comchap  \
        /tmp/comchap/comcut  \
        /tmp/HandBrake/build/HandBrakeCLI \
        /usr/local/bin/youtube-dl \
        /usr/local/bin/yt-dlp \
        /usr/local/bin/

RUN mkdir -p /usr/local/bin/comskiplibs
COPY --from=comskip_build /tmp/Comskip/comskip /usr/local/bin/patchelf /usr/local/bin/
COPY --from=comskip_build /tmp/Comskip/comskiplibs /usr/local/bin/comskiplibs


WORKDIR /app

RUN curl -sLO https://mirrors.xmission.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb && \
  dpkg -i libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb && \
  rm libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb

RUN curl -sLO http://nextpvr.com/stable/linux/NPVR.zip && \
  unzip NPVR.zip && \
  ls -al && \
  find . -name DeviceHostLinux -exec chmod 755 {} \; && \
  rm NPVR.zip

RUN  hash -r && \
        apt-get autoremove -y && \
        apt-get clean -y && \
        rm -rf /var/lib/apt/lists/*


# Let's make sure the app built correctly
ENV NEXTPVR_DATADIR=/app/data/
ENV NEXTPVR_DATADIR_USERDATA=/config/

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/bin/bash", "-c", "dotnet /app/NextPVRServer.dll"]
