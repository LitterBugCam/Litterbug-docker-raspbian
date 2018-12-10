import subprocess
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTShadowClient

import boto3
from inotify_simple import INotify, flags
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
from time import sleep
from datetime import date, datetime
import json
import cv2
from uuid import getnode as get_mac
import time
import psycopg2


import fnmatch, os




class shadowCallbackContainer:
    def __init__(self, deviceShadowInstance):
        self.deviceShadowInstance = deviceShadowInstance

    # Custom Shadow callback
    def customShadowCallback_Delta(self, payload, responseStatus, token):
        # payload is a JSON string ready to be parsed using json.loads(...)
        # in both Py2.x and Py3.x
        print("Received a delta message:")
        payloadDict = json.loads(payload)
        deltaMessage = json.dumps(payloadDict["state"])
        print(deltaMessage)
        print("Request to update the reported state...")
        newPayload = '{"state":{"reported":' + deltaMessage + '}}'

        self.deviceShadowInstance.shadowUpdate(newPayload, None, 5)
        print("Sent.")
def customShadowCallback_Update(payload, responseStatus, token):
    # payload is a JSON string ready to be parsed using json.loads(...)
    # in both Py2.x and Py3.x
    if responseStatus == "timeout":
        print("Update request " + token + " time out!")
    if responseStatus == "accepted":
        payloadDict = json.loads(payload)
        print("~~~~~~~~~~~~~~~~~~~~~~~")
        print("Update request with token: " + token + " accepted!")
        print("property: " + str(payloadDict["state"]["desired"]["live"]))
        print("~~~~~~~~~~~~~~~~~~~~~~~\n\n")
    if responseStatus == "rejected":
        print("Update request " + token + " rejected!")

def customShadowCallback_Delete(payload, responseStatus, token):

 # payload is a JSON string ready to be parsed using json.loads(...)
    # in both Py2.x and Py3.x
    if responseStatus == "timeout":
        print("Update request " + token + " time out!")
    if responseStatus == "accepted":
        payloadDict = json.loads(payload)
        print("~~~~~~~~~~~~~~~~~~~~~~~")
        print("Update request with token: " + token + " accepted!")
        print("property: " + str(payloadDict["state"]["desired"]["live"]))
        print("~~~~~~~~~~~~~~~~~~~~~~~\n\n")
    if responseStatus == "rejected":
        print("Update request " + token + " rejected!")

def customShadowCallback_Delete(payload, responseStatus, token):
    if responseStatus == "timeout":
        print("Delete request " + token + " time out!")
    if responseStatus == "accepted":
        print("~~~~~~~~~~~~~~~~~~~~~~~")
        print("Delete request with token: " + token + " accepted!")
        print("~~~~~~~~~~~~~~~~~~~~~~~\n\n")
    if responseStatus == "rejected":
        print("Delete request " + token + " rejected!")

def customCallback(client, userdata, message):

    print("Received a new message: ")
    print(message.payload)
    print("from topic: ")
    print(message.topic)
    print("--------------\n\n")

def get_rootca():

	for file in os.listdir('.certifications/'):
	    if fnmatch.fnmatch(file, "*.pem"):
	    	print (".certifications/"+file)
	    	return (".certifications/"+file)
def get_cert():

	for file in os.listdir('.certifications/'):
	    if fnmatch.fnmatch(file, '*.pem.crt'):
	    	print (".certifications/"+file)
	    	return (".certifications/"+file)
def get_private():

	for file in os.listdir('.certifications/'):
	    if fnmatch.fnmatch(file, '*.pem.key'):
	    	print (".certifications/"+file)
	    	return (".certifications/"+file)


os.system(' tvservice -o')
os.system(' mkdir detections')
os.system(' mkdir live')
#For docker on raspbian, a different MAC address is set each time the container is started
# As the MAC address needs to be registered in the App, we will hard code the MAC address for now.
# The address read directly from the hardware  - e.g. docker MAC or Raspberrypi MAC if not using docker
mac1 = get_mac()
print (mac1)
#mac = 2485377892354

s3 = boto3.client('s3', aws_access_key_id= open('keys.txt').readline().split(None, 1)[0],
aws_secret_access_key= open('keys.txt').readlines()[1].split(None, 1)[0])
mac = open('keys.txt').readlines()[2].split(None, 1)[0]

s3.download_file('littercam','device-'+str(mac)+'/devicename.txt', 'devicename.txt')
devicename = open('devicename.txt').readline().split(None, 1)[0]


print(devicename)

ShadowClient = AWSIoTMQTTShadowClient("")

ShadowClient.configureEndpoint("a1oa9tg9lcso0.iot.eu-west-1.amazonaws.com", 8883)
ShadowClient.configureCredentials(get_rootca(),
get_private(),get_cert())
ShadowClient.configureAutoReconnectBackoffTime(1, 32, 20)
ShadowClient.configureConnectDisconnectTimeout(30)  # 10 sec
ShadowClient.configureMQTTOperationTimeout(10)  # 5 sec
ShadowClient.connect()
deviceShadowHandler = ShadowClient.createShadowHandlerWithName(devicename, True)
#shadowCallbackContainer_Bot = shadowCallbackContainer(deviceShadowHandler)
#deviceShadowHandler.shadowRegisterDeltaCallback(shadowCallbackContainer_Bot.customShadowCallback_Delta)




# MQTT Connection establishement
myMQTTClient = AWSIoTMQTTClient(devicename)
myMQTTClient.configureEndpoint("a1oa9tg9lcso0.iot.eu-west-1.amazonaws.com", 8883)
myMQTTClient.configureCredentials(get_rootca(),
get_private(),get_cert())


myMQTTClient.configureOfflinePublishQueueing(-1)  # Infinite offline Publish queueing
myMQTTClient.configureDrainingFrequency(2)  # Draining: 2 Hz
myMQTTClient.configureConnectDisconnectTimeout(10)  # 10 sec
myMQTTClient.configureMQTTOperationTimeout(5)  # 5 sec
#connect and publish
myMQTTClient.connect()


con = psycopg2.connect("host='litterbugdb.c1ekrfqx70oj.eu-west-1.rds.amazonaws.com' dbname='littering' user='ilias' password='Algeria7201990'")
cur = con.cursor()
cur.execute("SELECT id FROM devices where mac_addr=%s",[mac])
row = cur.fetchone()
device_id=row[0]
print (device_id)
s3.download_file('littercam','device-'+str(mac)+'/parameters.txt', 'parameters.txt')


subprocess.Popen(["./Litter_detect"])
myMQTTClient.publish("topic", "connected", 0)

timestr = time.strftime("%Y-%m-%d-%H:%M:%S")

#timestr = time.strftime("%Y-%m-%d-%H:%M:%S")

#s3.upload_file("/home/pi/detections/litter.jpg", "littercam", "device-"+str(mac)+"/litter"+str(timestr)+".jpg")

# inotify initialization
inotify = INotify()
inotify_live = INotify()
watch_flags = flags.CREATE | flags.MODIFY
wd = inotify.add_watch('detections', watch_flags)
wd_live = inotify_live.add_watch('live', watch_flags)
#time.sleep(3)   # Delays for 5 seconds. You can also use a float value.

while 1:
       timestr = time.strftime("%Y-%m-%d-%H:%M:%S")
       JSONPayload = '{"state":{"desired":{"live": \"'+timestr+'\" }}}'
       deviceShadowHandler.shadowUpdate(JSONPayload,customShadowCallback_Update, 5)
       events= inotify.read(5000,2000)
       events_live= inotify_live.read(5000,2000)

       print ("evnets "+ str(events))
       print ("evnets_live "+ str(events_live))
       if events_live:
            image=cv2.imread("live/live.bmp");
            cv2.imwrite('lives3/live.jpg',image,[int(cv2.IMWRITE_JPEG_QUALITY), 50])
            s3.upload_file("lives3/live.jpg", "littercam", "device-"+str(mac)+"/live3.jpg")
       if events:
           #if litter event send detection image to S3 bucket "littercam"
            image=cv2.imread("detections/litter.bmp");
            cv2.imwrite('detectionss3/litter.jpg',image,[int(cv2.IMWRITE_JPEG_QUALITY), 50])
            timestr = time.strftime("%Y-%m-%d-%H:%M:%S")

            s3.upload_file("detectionss3/litter.jpg", "littercam", "device-"+str(mac)+"/litter"+str(timestr)+".jpg")
            s3.upload_file("detectionss3/litter.jpg", "littercam", "device-"+str(mac)+"/litter.jpg")
           # and send message to the MQTT topic
            detection= "device-"+str(mac)+"/litter"+str(timestr)+".jpg"
            message = {}
            message['message'] = " A littering event is detected"
            message['imageKey'] = events[-1].name
            message['device_id'] = "ID_1"
            with open('litterlog.txt', 'a') as the_file:
                    the_file.write("A littering is detected at "+timestr+"\n")
            s3.upload_file("litterlog.txt", "littercam", "device-"+str(mac)+"/log.txt")
            messageJson = json.dumps(message)
            myMQTTClient.publish("topic", messageJson, 1)
            cur.execute("INSERT INTO events ( detection, confidence, device_id) VALUES (%s,%s,%s) ",(detection,95,device_id))
            con.commit()
            event=events[-1]
            print(event)
           # for flag in flags.from_mask(event.mask):
            #   print('    ' + str(flag))
            del events
            del events_live
            time.sleep(2)   # Delays for 5 seconds. You can also use a float value.
