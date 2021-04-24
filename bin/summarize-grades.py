#!/usr/bin/env python

import sys

COLUMNS = []
DATA = []

class Data:
    def __str__(self):
        t = []
        for key in COLUMNS:
            t.append(self[key])
        return "\t".join(t)


def processFile(fname):
    for line in open(fname):
        spline = line.strip("\n").split("\t");
        if (spline[0].startswith("\""):
            spline = spline[1:]
            for item in spline:
                if item not in COLUMNS:
                    COLUMNS.append(item)
        else:
            
        print spline

def main():
    for arg in sys.argv[1:]:
        print 'arg is', arg
        processFile(arg)

    keys = data.keys()
    keys.sort()
    for key in keys:
        print data


if __name__=="__main__":
    print 'calling main'
    main()




