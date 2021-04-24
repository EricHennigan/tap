#!/usr/bin/env python

'''
prints out a stem and leaf plot of data
'''

from optparse import OptionParser
import sys, itertools

################
# Options
#===============
usage = "usage: %prog [options]* [file]*"
description = __doc__
parser = OptionParser(usage=usage) #,description=description)
################

def stem(data):
    return data // 10

def leaf(data):
    return data % 10

def add(fi, hist):
    for line in fi:
        data = int(float(line.strip()));
        hist.setdefault(stem(data),[]).append(leaf(data))

def main(files):
    hist = {}
    for fi in files:
        add(fi, hist)

    keys = hist.keys()
    keys.sort()

    for key in keys:
        hist[key].sort()
        print key, "|",
        for item in hist[key]:
            print item,
        print

if __name__=="__main__":
   (options, args) = parser.parse_args()
   if not args:
      files = [sys.stdin]
   else:
      files = itertools.imap( open, args )
   
   main(files);
