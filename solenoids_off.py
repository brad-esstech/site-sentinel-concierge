#!/usr/bin/python3

import RPi.GPIO as GPIO
import config # config stuff

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

#GPIO.setup(config.ingress_pin, GPIO.OUT)
#GPIO.setup(config.egress_pin, GPIO.OUT)
#GPIO.setup(config.relay3_pin, GPIO.OUT)

# set both ingress and egress to HIGH (relays open)
#GPIO.output(config.ingress_pin, GPIO.HIGH) # relay open
#GPIO.output(config.egress_pin, GPIO.HIGH) # relay open
#GPIO.output(config.relay3_pin, GPIO.HIGH) # relay open

GPIO.cleanup()
