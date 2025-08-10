#!/usr/bin/python3

import RPi.GPIO as GPIO
import config # config stuff

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

#GPIO.setup(config.ingress_pin, GPIO.OUT)
#GPIO.setup(config.egress_pin, GPIO.OUT)
#GPIO.setup(config.relay3_pin, GPIO.OUT)

# Check to see the current state of the GPIO out pin.
# If not LOW, then we want to set it to LOW (relay closed)

#if GPIO.input(config.egress_pin):
  GPIO.output(config.egress_pin, GPIO.LOW) # relay closed

#if GPIO.input(config.ingress_pin):
#  GPIO.output(config.ingress_pin, GPIO.LOW) # relay closed

#if GPIO.input(config.relay3_pin):
#  GPIO.output(config.relay3_pin, GPIO.LOW) # relay closed

# Below command is not needed
# GPIO.cleanup() # Forces all ports back to default; relay will switch off!
