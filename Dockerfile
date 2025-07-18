# ffmpeg - http://ffmpeg.org/download.html
#
# From https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
# https://hub.docker.com/r/jrottenberg/ffmpeg/
#
# https://github.com/smacke/ffsubsync
#



FROM        nextpvr/nextpvr_amd64:stable AS base

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends ca-certificates expat curl libgomp1 mediainfo libutf8proc2 tesseract-ocr curl libgomp1 \
        mediainfo libfreetype6 libutf8proc2 tesseract-ocr libva-drm2 libva2 libjansson4 python3 libargtable2-0 \
        libturbojpeg0 curl libunwind8 gettext apt-transport-https libgdiplus libc6-dev mediainfo libdvbv5-dev \
        ffmpeg hdhomerun-config dtv-scan-tables unzip i965-va-driver-shaders vainfo \
        libigdgmm12 libglu1-mesa libmad0 liba52-0.7.4 libfaad2

#RUN curl https://nextpvr.com/nextpvr-helper.deb -O && \
#    apt -yq install ./nextpvr-helper.deb --install-recommends

RUN     ln -s /usr/bin/python3 /usr/bin/python

ENV ASPNETCORE_URLS=http://+:80 DOTNET_RUNNING_IN_CONTAINER=true

FROM base AS build

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
                clang \
                dvb-apps \
                gi-docgen \
                gobject-introspection \
                gtk-doc-tools \
                liba52-0.7.4-dev \
                libargtable2-dev \
                libasound2-dev \
                libass-dev \
                libavcodec-dev \
                libavdevice-dev \
                libavformat-dev \
                libavutil-dev \
                libbluray2 \
                libbz2-dev \
                libcaca-dev \
                libchromaprint-dev \
                libchromaprint1 \
                libclang-dev \
                libcurl4-openssl-dev \
                libdrm-dev \
                libfaad-dev \
                libfontconfig1-dev \
                libfreetype6-dev \
                libfribidi-dev \
                libgl1-mesa-dev \
                libglu1-mesa-dev \
                libgme-dev \
                libharfbuzz-dev \
                libigdgmm-dev \
                libjack-jackd2-dev \
                libjansson-dev \
                libjpeg62-turbo-dev \
                liblzma-dev \
                libmad0-dev \
                libmp3lame-dev \
                libnghttp2-dev \
                libnuma-dev \
                libogg-dev \
                libopenjp2-7-dev \
                libopenmpt0 \
                libopus-dev \
                libpulse-dev \
                libsamplerate0-dev \
                libsdl1.2-dev \
                libsdl2-dev \
                libspeex-dev \
                libssl-dev \
                libswscale-dev \
                libtesseract-dev \
                libtheora-dev \
                libtool \
                libtool-bin \
                libturbojpeg0-dev \
                libva-dev \
                libvorbis-dev \
                libvpx-dev \
                libx264-dev \
                libxml2-dev \
                libxv-dev \
                libxvidcore-dev \
                mesa-utils \
                nasm \
                ninja-build \
                patch \
                pkg-config \
                python3-dev \
                python3-pip \
                python3-setuptools \
                python3-wheel \
                python3-xcbgen \
                unzip \
                x11proto-gl-dev \
                x11proto-video-dev \
                xcb-proto \
                xz-utils \
                yasm \
                zlib1g-dev \
        " && \
        apt-get -yqq update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends ${buildDeps} 

RUN     pip3 install --no-cache-dir --break-system-packages meson ffsubsync

ENV             FFMPEG_VERSION=7.0.2 \
                AOM_VERSION=v3.10.0 \
                FDKAAC_VERSION=2.0.3 \
                FONTCONFIG_VERSION=2.13.96 \
                FREETYPE_VERSION=2.13.2 \
                FRIBIDI_VERSION=1.0.11 \
                KVAZAAR_VERSION=2.3.1 \
                LAME_VERSION=3.100 \
                LIBASS_VERSION=0.15.2 \
                LIBPTHREAD_STUBS_VERSION=0.4 \
                LIBVIDSTAB_VERSION=1.1.0 \
                LIBXCB_VERSION=1.17.0 \
                XCBPROTO_VERSION=1.17.0 \
                OGG_VERSION=1.3.5 \
                OPENCOREAMR_VERSION=0.1.6 \
                OPUS_VERSION=1.3.1 \
                OPENJPEG_VERSION=2.4.0 \
                THEORA_VERSION=1.2.0 \
                VORBIS_VERSION=1.3.7 \
                VPX_VERSION=1.12.0 \
                WEBP_VERSION=1.2.4 \
                X264_VERSION=20191217-2245-stable \
                X265_VERSION=4.0 \
                LIBDAV1D_VERSION=1.5.0 \
                XAU_VERSION=1.0.9 \
                XORG_MACROS_VERSION=1.19.2 \
                XPROTO_VERSION=7.0.31 \
                XVID_VERSION=1.3.5 \
                LIBXML2_VERSION=2.9.11 \
                LIBBLURAY_VERSION=1.3.0 \
                LIBZMQ_VERSION=4.3.2 \
                LIBVMAF_VERSION=1.5.3 \
                HANDBRAKE_VERSION=1.9.2 \
                LIBSTVAV1_VERSION=v1.7.0 \
                SRC=/usr/local



FROM build AS updated_build

#https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html#x86-Options
#CFLAGS="-mtune=goldmont " \
#CXXFLAGS="-mtune=silvermont " \

ENV     MAKEFLAGS="-j `nproc`" \
        CFLAGS="-mtune=native " \
        CXXFLAGS="-mtune=native "


RUN gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | grep mtune


FROM updated_build AS rustlib_build

# install rust for ccextractor and Comskip
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs  | sh -s -- -y
ENV PATH="/app/.cargo/bin:/root/.cargo/bin:$PATH"


FROM rustlib_build AS extras_build

RUN set -x &&   cd /tmp && \
        git clone https://github.com/gpac/gpac.git gpac_public && \
        cd gpac_public && \
        ./configure && \
        make && \
        make install-lib

RUN  set -x &&   cd /tmp && \
        git clone https://github.com/CCExtractor/ccextractor && \
        cd ccextractor/linux && \
        ./autogen.sh && \
        ./configure --enable-ocr  && \
        make


# get comchap && comcut
RUN  set -x &&   cd /tmp && \
        git clone https://github.com/BrettSheleski/comchap


# Install yt-dlp because we can
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
        chmod a+rx /usr/local/bin/yt-dlp


FROM rustlib_build AS comskip_build

# compile comskip
RUN   set -x && cd /tmp && PREFIX= \
        git clone https://github.com/erikkaashoek/Comskip


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


FROM updated_build AS handbrake_build
#build HandBrakeCLI see https://handbrake.fr/docs/en/1.3.0/developer/install-dependencies-ubuntu.html
#https://www.reddit.com/r/handbrake/comments/bnadr6/guide_how_to_custom_build_handbrake_eg_fdk_aac/

RUN set -x &&   cd /tmp && \
        git clone https://github.com/HandBrake/HandBrake && \
        cd HandBrake && \
        git checkout tags/${HANDBRAKE_VERSION}

RUN cd /tmp/HandBrake && ./configure  --enable-x265 --enable-qsv --enable-vce --enable-fdk-aac --disable-gtk --launch-jobs=4 --launch



FROM        base AS release

LABEL maintainer="Mark Lambert <ranbato@gmail.com>"

ENV         LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:/lib:/lib64

## Copy everything from build images to final image

# Libraries too
COPY --from=extras_build /usr/local /usr/local/

#Add to lib path
ENV         LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:/lib:/lib64

#copy ccextractor, comskip, comcut, ffsubsync
COPY --from=extras_build /tmp/ccextractor/linux/ccextractor \
        /tmp/comchap/comchap  \
        /tmp/comchap/comcut  \
        /usr/local/bin/yt-dlp \
        /usr/local/bin/


# copy handbrakecli
COPY --from=handbrake_build  /tmp/HandBrake/build/HandBrakeCLI \
        /usr/local/bin/

RUN mkdir -p /usr/local/bin/comskiplibs
COPY --from=comskip_build /tmp/Comskip/comskip /usr/local/bin/patchelf /usr/local/bin/
COPY --from=comskip_build /tmp/Comskip/comskiplibs /usr/local/bin/comskiplibs


WORKDIR /app

RUN curl -sLO https://mirrors.xmission.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb && \
  dpkg -i libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb && \
  rm libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb


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
