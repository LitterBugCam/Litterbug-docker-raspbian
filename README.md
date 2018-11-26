#  LitterBug Project
This program is part of the LitterBug project, a battery powered camera system for litter prevention.

For more information, please visit our website https://litterbug.cam/
# Prerequisites
## Raspberrypi
### Hardware
1. Raspberry Pi (RPi)
2. SD card (64GB recommended)
3. Raspberry Pi 3 Power Adapter
4. Access to Ethernet and ethernet cable
5. PC monitor, power supply cable and HDMI cable
6. Keyboard and mouse
7. PC or Laptop
8. RPi Camera or webcam

### Prepare the SD card with RPi OS
On PC/Laptop connected to Internet you will need
a) Slot to read SD card<br/>
b) Disk formatter on PC e.g. https://www.raspberrypi.org/documentation/installation/sdxc_formatting.md<br/>
c) Sha256 checker on PC e.g. https://download.cnet.com/MD5-SHA-Checksum-Utility/3000-2092_4-10911445.html<br/>
d) File extracter on PC  e.g http://www.winzip.com/win/en<br/>
e) Disk imager on PC e.g. https://sourceforge.net/projects/win32diskimager/<br/>

Insert SD card into slot in PC/Laptop and format the SD card.
If the card is new, choose quick format. Otherwise choose Overwrite format.

Download Raspbian Stretch Lite to MicroSD card
1.	Download Raspian Stretch Lite (2018-04-18-raspbian-stretch-lite) to the PC from https://www.raspberrypi.org/downloads/
2.	Using c above, check the SHA256 to ensure that the download is not corrupt 
3.	Using d above, extract the Raspian Lite image file from the .zip, .tar on the PC
4.	Using e above, write the image to the SD card
5.	Exit the imager and eject the SD card.

### Install OS on RPi
On the Raspberry Pi 
Place the RPI in its casing. Connect a monitor to power with power off. Connect to a monitor using hdmi to usb cable, and to a keyboard and mouse via the USB ports. Connect to the internet via the Ethernet port. Connect to power via the micro USB power port. The power is off. 
Starting the Raspberry pi
1.	With the power off, insert the microSD card into the Raspberry pi
2.	Turn on the RPI and monitor powers on. 
3.	Log onto pi (default username: pi, password: raspberry)


### Increase the SWAP size of Raspberry pi
$sudo chmod 757 /etc/dphys-swapfile
$sudo nano /etc/dphys-swapfile
Change as follows
1.CONF_SWAPSIZE = 2650
Uncomment
2. CONF_SWAPFACTOR=2
Ctrl x and Yes to save and exit.

### Enable RPi features
1. RPi Camera. This step is only needed for the RPi Camera. It is not required for a USB webcam. 
$sudo raspi-config
Move down/up arrow keys to highlight “Interfacing options” and arrow right arrow key to highlight select. Press enter
2. SSH
$sudo raspi-config
Move down/up arrow keys to highlight “Interfacing options” and arrow right arrow key to highlight select. Choose SSH. Press enter
3. Wifi (Optional)
$sudo raspi-config
Move down/up arrow keys to highlight "Network options” and arrow right arrow key to highlight select. Choose Wifi. Enter SSID and password of WiFi network. Press enter
4. $sudo reboot

### Test the camera
1. Still picture  $raspistill -o imagename.jpg
2. Video $raspivid -o videoname.h264
3. For more commands see https://www.raspberrypi.org/documentation/usage/camera/raspicam/README.md

### View image/video - Desktop version of Raspian
This only works if you have installed the Desktop version
1. To play the image/video $omxplayer -o hdmi /path/to/imagename.jpg

### View image/video - Lite version of Raspian

#### Install OMXPLAYER (for Video)
Raspbian lite installations do not include omxplayer. If you installed the full version of e.g. Stretch, you can skip these steps
1. $sudo apt-get update
2. $sudo apt-get install omxplayer

#### Install FBI (for images)
Raspbian lite installations do not include omxplayer. If you installed the full version of e.g. Stretch, you can skip these steps
1. $sudo apt-get install fbi

#### View image/video
1. To play the image/video $omxplayer -o hdmi /path/to/videoname.jpg
2. Issue command on RPi terminal (it does not work using SSH) $sudo fbi -T 2 /path/to/imagename.jpg

### Open SSH Session (Optional) 
With the SSH session, it will be easier to input the commands by cut and paste instead of typing. 

On the RPi
$ifconfig 
Make a note of the IP address and MAC address of the RPi

On the PC
SSH to the RPi using e.g. putty on a windows PC and the IP address above.

You can now disconnect the Monitor, Keyboard and Mouse from the RPi. And if you are using wifi, you can also disconnect the Ethernet cable.

### Install Docker client
Using the SSH terminal (or the terminal of the RPi)
1. Install docker
$curl –sSL https://get.docker.com | sh
2. Allow use of docker without sudo
$sudo usermod –aG docker pi where pi is the username
3. Reboot
$sudo reboot


### Copy certificates
Using e.g. Filezilla copy the .certications folder to the /home/pi/ directory
Todo How to generate certs
### Copy keys
Using e.g. Filezilla copy the keys.txt file the /home/pi/ directory
Todo How to generate certs

### Install Litterbug
1. $sudo apt-get update
2. $sudo apt-get install git
3. Clone this repository $git clone https://github.com/LitterBugCam/Litterbug-docker-raspbian.git



### Start the build
1. $cd Litterbug-docker-raspbian
2. $./build.sh
Possibly remove the following
2. $sudo docker build -t litterbugclient . 

## Start the container
1. $sudo docker run -i -t litterbugclient /bin/bash 
