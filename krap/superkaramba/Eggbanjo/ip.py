#!/usr/bin/python
# Script from Adrien Vermeulen made for Aero-AIO superkaramba theme

import urllib
import re
import sys

#This output the external IP address
# usage: getExternalIP.py

def getExtIP():
	f = urllib.urlopen("http://www.whatismyip.com/")
	a = f.read()
	f.close()
	match = re.search("[0-9]+.[0-9]+.[0-9]+.[0-9]+", a)
	return match.group()

try:
	out = getExtIP()
except:
	print "Unable to connect or to get IP address form server."
else:
	print out
