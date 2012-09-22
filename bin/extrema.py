#!/usr/bin/env python

#This reads in data and returns all lecal maxes above the mean value
# does a quadratic fit for sections of more than 3 points
# and linear interpolation for 2 points

import sys, string
from Numeric import *
from LinearAlgebra import *

def quadfit( data ):
	extreme = []
	if len(data)==1:	# if this is a single point, return it
		extreme = data[0]
	elif len(data)==2:	# if this is a section of 2 points, linear interpolate
		x = ( data[0][0] + data[1][0] )/2
		y = ( data[0][1] + data[1][1] )/2
		extreme = [x,y]
	else:			# must be a section of many points, prepare quadratic
		# we are solving a linear system, with all sums from i=1 to n
		#	[ sum y_i         ]   [ sum 1 ,    sum x_i,   sum x_i^2 ] [ A ]
		#	[ sum x_i*y_i     ] = [ sum x_i,   sum x_i^2, sum x_i^3 ] [ B ]
		#	[ sum x_i^2 * y_i ]   [ sum x_i^2, sum x_i^3, sum x_i^4 ] [ C ]
		#	can be written Y[0:3] = M[0:3][0:3] * X[0:3]
		x_i, x_i2, x_i3, x_i4, y_i, y_ix_i, y_ix_i2 = (0.,)*7
		for i in range(len(data)):
			x_i += data[i][0]
			x_i2+= data[i][0]**2
			x_i3+= data[i][0]**3
			x_i4+= data[i][0]**4
			y_i += data[i][1]
			y_ix_i += data[i][1]*data[i][0]
			y_ix_i2+= data[i][1]*data[i][0]*data[i][0]
		M = array( ( (len(data), x_i, x_i2), (x_i, x_i2, x_i3), (x_i2, x_i3,x_i4) ), Float )
		Y = array( (y_i, y_ix_i, y_ix_i2), Float )
		(C,B,A) = matrixmultiply(inverse(M), Y)
		x = -B/(2*A)
		extreme = [ x, A*x*x + B*x + C ]
	return extreme

# ====================================
# BEGIN MAIN ROUTINE
# ====================================
if len(sys.argv) == 1:
	lines = sys.stdin.readlines()
elif len(sys.argv) == 2:
	try:
		fobj = open(sys.argv[1], 'r')
		lines = fobj.readlines()
		fobj.close()
	except IOError:
		print 'IOError: Could not open %s' % input_file
		exit
else:
	print 'Usage: maxima input.txt'
	sys.exit()

	
# parse out '#' begun comments, and empty lines
data_lines = []
for i in range(len(lines)):
	for j in range(len(lines[i])):
		if lines[i][j] == '#':
			lines[i] = lines[i][:j]
			break
	lines[i] = lines[i].lstrip()
	if lines[i] != '':
		data_lines.append(lines[i])

data = []
mean = 0.
for line_no in range(len(data_lines)):
	# split into tokens
	tokens = string.split(data_lines[line_no])
	data.append([float(x) for x in tokens])
	mean += data[line_no][1]
mean /= len(data_lines)

# get each extreme position and range, append to list of maxima
maxima = []
i = 0
while i < len(data):
	# get the beginning (p1) of contiguous set above mean
	if data[i][1] >= mean:
		p1 = p2 = i
	else:
		i+=1
		continue
	
	# get the end (p2) of contiguous set above mean
	while i<len(data) and data[i][1]>=mean :
		p2=i
		i+=1
	i+=1
	maxima.append(quadfit(data[p1:p2+1]))

# great we're all done
print '# maxima at'
for i in range(len(maxima)):
	print "%13.13E   %13.13E"%(maxima[i][0],maxima[i][1])
print ''

minima = []
i = 0
while i < len(data):
	# get the beginning (p1) of contiguous set below mean
	if data[i][1] < mean:
		p1 = p2 = i
	else:
		i+=1
		continue
	
	# get the end (p2) of contiguous set below mean
	while i<len(data) and data[i][1]<mean :
		p2=i
		i+=1
	i+=1
	minima.append(quadfit(data[p1:p2+1]))
print '# minima at'
for i in range(len(minima)):
	print "%13.13E   %13.13E"%(minima[i][0],minima[i][1])
