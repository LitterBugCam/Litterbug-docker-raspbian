FROM debian:9.6


#Start installing components for opencv2
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils 


RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion 
		
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils	
RUN apt-get install -y \
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
		) 

	
# Several retries is a workaround for flaky downloads
RUN packages="libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav curl python python-dev python-pip python3-pip unzip supervisor libzmq3-dev v4l-utils python3-dev python3-numpy python-numpy"\
    && apt-get -y update \
    && apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages 
    
    
    # Several retries is a workaround for flaky downloads
RUN packages="curl libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-bad1.0-0 libgstreamer-plugins-base1.0-0 gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-ugly"\
    && apt-get update \
    && apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages 

# List of packages causing issues at installation
run apt-get update
RUN apt-get install -y  gstreamer1.0-omx 
RUN apt-get install -y  libjasper-dev 
RUN apt-get install -y  libjasper1
RUN apt-get install -y  libpng12-dev
RUN apt-get install -y  libpng12-0

ENV INITSYSTEM on
# removed gstreamer1.0-omx    libjasper-dev libjasper1 libpng12-dev libpng12-0
RUN packages="curl libeigen3-dev libjpeg-dev libtiff5-dev libtiff5   libavcodec-dev libavformat-dev"\
    && apt-get update \
    && apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages \
    || apt-get -y install $packages 
    

RUN apt-get install -y \
        libswscale-dev\
	libv4l-dev\
	libv4l-0\
	libatlas-base-dev\
	libatlas3-base\
	gfortran\
	libblas-dev\
	libblas3\
	liblapack-dev\
	liblapack3\
	python3-dev\
	libpython3-dev\
	python-opencv\
	python-psycopg2 
	

RUN chmod 757 /tmp
RUN cd /tmp \
    && git clone git://github.com/opencv/opencv \
	&& cd opencv \
	&& git checkout tags/3.4.0 \
	&& cd .. \
    && git clone git://github.com/opencv/opencv_contrib \
	&& cd opencv_contrib \
	&& git checkout tags/3.4.0 \
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
    && make package 

# Install the application (Litterbug Client)
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN pip install  enum AWSIoTPythonSDK boto3 inotify_simple uuid 


WORKDIR /usr/src/app
# bin include lib are the folders that are required
COPY . /usr/src/app
RUN cd /usr/src/app

RUN git clone https://github.com/LitterBugCam/Litterbug-docker-raspbian.git
RUN cd Litterbug-docker-raspbian

# Configure the application
RUN mkdir live
RUN mkdir detections
RUN mkdir detectionss3
RUN mkdir lives3
#RUN mkdir .certifications
#RUN chmod 757 .certifications
Run cd ..
Run chmod 757 Litterbug-docker-raspbian


# Copy the certification files and AWS keys from the /home/pi folder to the app folder
#ENV HOME /home/pi 
#RUN cp $HOME/.certifications/*.* /usr/src/app/Litterbug-docker-raspbian/
#RUN cp $HOME/key.txt /usr/src/app/Litterbug-docker-raspbian/
#COPY $HOME/.certifications/*.* /usr/src/app/Litterbug-docker-raspbian/
#COPY $HOME/key.txt /usr/src/app/Litterbug-docker-raspbian/

# Compile the application
RUN cd Litterbug-docker-raspbian
RUN ldconfig
RUN  make
#Start the application
CMD  ["python","AWSIOT_Client.py"]
