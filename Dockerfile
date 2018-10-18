FROM debian:jessie

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils 


RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget \
	&& rm -rf /var/lib/apt/lists/*
	

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
	&& rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils		
RUN apt-get update && apt-get install -y \
		autoconf \
		build-essential \
		cmake \
		imagemagick \
		libbz2-dev \
		libcurl4-openssl-dev \
		libevent-dev \
		libffi-dev \
		libglib2.0-dev \
		libjpeg-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libncurses-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		zlib1g-dev \
		$( \
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
	libgstreamer-plugins-base1.0-0 \
	libgstreamer1.0-0 \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-libav 


	
ENV INITSYSTEM on

# GStreamer  and openCV deps
# Several retries is a workaround for flaky downloads
RUN packages="curl cmake python  python-dev  python-pip python3-pip unzip supervisor libzmq3 libzmq3-dev v4l-utils python3-dev python3-numpy python-numpy libgstreamer1.0-dev libgstreamer1.0-0 libgstreamer-vaapi1.0-dev libgstreamer-vaapi1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-bad1.0-0 libgstreamer-plugins-base1.0-0 gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-omx build-essential cmake libeigen3-dev libjpeg-dev libtiff5-dev libtiff5 libjasper-dev libjasper1 libpng12-dev libpng12-0 libavcodec-dev  libavcodec56 libavformat-dev libavformat56 libswscale-dev libswscale3 libv4l-dev libv4l-0 libatlas-base-dev libatlas3-base gfortran libblas-dev libblas3 liblapack-dev liblapack3 python3-dev libpython3-dev python-opencv numpy python-psycopg2" \
    && apt-get -y update \
    && apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get clean && rm -rf /var/lib/apt/lists/*



# We might consider installing pip, pip3, pip numpy here
# if it provides any performance/bug fixes

# OpenCV installation
# this says it can't find lots of stuff, but VideoCapture(0) and Python3 bindings work.
# IDK if LAPACK/BLAS/etc works, or gstreamer backend
# TODO: Where are the build logs?
# PYTHON_DEFAULT_EXECUTABLE
RUN chmod 757 /tmp
RUN cd /tmp \
    && git clone git://github.com/opencv/opencv \
	&& cd opencv \
	&& git checkout tags/3.2.0 \
	&& cd .. \
    && git clone git://github.com/opencv/opencv_contrib \
	&& cd opencv_contrib \
	&& git checkout tags/3.2.0 \
	&& cd .. \
	&& cd opencv \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DINSTALL_C_EXAMPLES=OFF \
    -DINSTALL_PYTHON_EXAMPLES=OFF \
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DBUILD_EXAMPLES=OFF \
    -DENABLE_VFPV3=ON \
  -DENABLE_NEON=ON \
   -DHARDFP=ON \
    -DWITH_CAROTENE=OFF \
    -DBUILD_NEW_PYTHON_SUPPORT=ON \
    -DWITH_FFMPEG=OFF \
    -DWITH_GSTREAMER=ON \
    -DWITH_CUDA=OFF \
    -DWITH_CUFFT=OFF \
    -DWITH_CUBLAS=OFF \
    -DWITH_LAPACK=ON \
    .. \
    && make -j`nproc` \
    && make install \
    && make package \
    && make clean \
    && cd /

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN pip install  enum AWSIoTPythonSDK boto3 inotify_simple uuid 
WORKDIR /usr/src/app

COPY . /usr/src/app
RUN mkdir live
RUN mkdir detections
RUN mkdir detectionss3
RUN mkdir lives3



RUN ldconfig

RUN  make


CMD  ["python","AWSIOT_Client.py"]
