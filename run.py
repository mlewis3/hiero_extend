#!/usr/bin/python

import os
import time
from subprocess import *
import sys
import datetime
import socket
#import numpy as np
#import pylab as plt

nodes = [512]
modes = ['newtop']
baseDir = 'projects/ExaHDF5/mlewis/hiero'
plotfile = 'plotit'
searchstring = 'Time for read'
executables = ['No Leader', 'Fixed Plane', 'Smallest Plane']


def runcmd (pgm, node, dir, make_file):
        
	script = './' + pgm + '.sh ' + str(node)  + ' ' + str(dir) + ' ' + make_file
        
        cmd = 'qsub -A ' + project + ' -t 02:30:00 -n '+str(node)+' --mode script '+script
        print 'Executing ' + cmd
	jobid = Popen(cmd, shell=True, stdout=PIPE).communicate()[0]
	print 'Jobid : ' + jobid
	
	while True:
		cmd = 'qstat ' + jobid.strip() + ' | grep mlewis | awk \'{print $1}\''
		jobrun = Popen(cmd, shell=True, stdout=PIPE).communicate()[0]
		if jobrun == '':
			break
		time.sleep(45)

	return jobid.strip()


ts = time.time()
timestamp = datetime.datetime.fromtimestamp(ts).strftime('%m-%d-%H-%M')
#timestamp = datetime.datetime.fromtimestamp(ts).strftime('-%Y-%m-%d')
configuration = [ 'No Leader' , 'Fixed Plane' , 'Smallest Plane' ]
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane ' ]
filenamelist = [ 'nl_search_' + socket.gethostname() + timestamp, 'fp_search_' + socket.gethostname() + '_' + timestamp, 'sp_search_' + socket.gethostname() + '_' + timestamp ]
headerbanner = 'volume size (MB) \tnx_g\tny_g\tnz_g\tnpx\tnpy\tnpz\tread time\twrite time\tread (open)\tread (close)\topen time\tclose time\tread bw\tppn\tnode size\ttime-date'


fields = 17
topologies = 30
noleaderarray = [ [ [0.0] for j in range(fields) ] for i in range(topologies) ]
fixedplanearray = [ [ [0.0] for j in range(fields) ] for i in range(topologies) ]
smallestplanearray = [ [ [0.0] for j in range(fields) ] for i in range(topologies) ]


numIter = 11
outstreamlist = []
linelist = []
arraylist = []
arraylist.append(noleaderarray)
arraylist.append(fixedplanearray)
arraylist.append(smallestplanearray)
outputlist = []
ts = time.time()
make_file = 'F'


#project = 'visualization'
#basedir = '/projects/visualization/mlewis/hiero'

project = 'ExaHDF5'
basedir = '/projects/ExaHDF5/mlewis/hiero'

linecount = 0
for nodeIndex,node in enumerate(nodes):
  for iter in range (0, numIter):
    for pgm in modes:
      print '\nStarting ' + pgm + ' on ' + str(node) + ' nodes, basedir: ' + basedir 
      if iter > 0 :
         make_file = 'T'
      jobid = runcmd(pgm, node, basedir, make_file)
      filename = 'op' + pgm + '_' +str(node)+'_'+str(iter) + '_' + socket.gethostname()+ '_' + timestamp
      print filename + ' ' + jobid
      cmd = 'mv ' + jobid.strip() + '.output ' + filename + '.output'
      print cmd
      Popen(cmd, shell=True, stdout=PIPE).communicate()[0]
      cmd = 'mv ' + jobid.strip() + '.error ' + filename + '.error'
      print cmd
      Popen(cmd, shell=True, stdout=PIPE).communicate()[0]
      cmd = 'mv ' + jobid.strip() + '.cobaltlog ' + filename + '.cobaltlog'
      print cmd
      Popen(cmd, shell=True, stdout=PIPE).communicate()[0]
