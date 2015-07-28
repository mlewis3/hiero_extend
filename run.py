#!/usr/bin/python

import os
import time
from subprocess import *
import sys
import datetime
import socket
#import numpy as np
#import pylab as plt

nodes = [128, 512]
modes = ['short_decomp']
baseDir = 'projects/ExaHDF5/mlewis/hiero'
executables = ['No Leader', 'Fixed Plane', 'Smallest Plane']


def runcmd (pgm, node, dir, make_file, topelement):
        
	script = './' + pgm + '.sh ' + str(node)  + ' ' + str(dir) + ' ' + make_file + ' ' + topelement
        
        cmd = 'qsub -A ' + project + ' -t 01:00:00 -n '+str(node) +' --mode script ' + script
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
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane ' ]
#topology = [ '512x512x512', '512x512x256', '512x256x512', '256x512x512', '256x256x512', '256x512x256', '512x256x256', '256x256x256', '128x256x512', '128x512x256', '256x128x512', '512x128x256', '512x256x128' ]
topology = [ '256x256x256', '512x512x256' ]
headerbanner = 'volume size (MB) \tnx_g\tny_g\tnz_g\tnpx\tnpy\tnpz\tread time\twrite time\tread (open)\tread (close)\topen time\tclose time\tread bw\tppn\tnode size\ttime-date'




numIter = 2
ts = time.time()
make_file = 'F'


project = 'visualization'
basedir = 'projects/visualization/mlewis/hiero'

#project = 'ExaHDF5'
#basedir = '/projects/ExaHDF5/mlewis/hiero'

linecount = 0
for topelement in topology :
  make_file = 'F'
  for iter in range (0, numIter):
      print '\nStarting ' + 'decomp' + ' on ' + str(topelement) + ' volume topology, basedir: ' + basedir 
      if iter > 0 :
         make_file = 'T'
      jobid = runcmd('decomp', 128, basedir, make_file, topelement)
      filename = 'op' + 'decomp' + '_' + topelement  + '_' + str(iter) + '_' + socket.gethostname()+ '_' + timestamp
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
      rncmd = 'rm -rf ' + '/' + basedir + '/smallestplane' + '/' + topelement
      Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
      rncmd = 'rm -rf ' + '/' + basedir + '/fixedplane' + '/' + topelement
      Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
      rncmd = 'rm -rf ' + '/' + basedir + '/noleader' + '/' + topelement
      Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
  
