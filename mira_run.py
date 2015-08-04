#!/usr/bin/python

import os
import time
from subprocess import *
import sys
import datetime
import socket
#import numpy as np
#import pylab as plt

# nodes = [ 512, 1024, 2048 , 4096 ]
nodes = [ 512, 1024, 2048, 4096 ]
modes = ['newtop']
baseDir = 'projects/ExaHDF5/mlewis/hiero'


def runcmd (pgm, node, dir, make_file):
        
	script = './' + pgm + '.sh ' + str(node)  + ' ' + str(dir) + ' ' + make_file
        
        cmd = 'qsub -A ' + project + ' -t 02:30:00 -n '+str(node) +' --mode script ' + script
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
topology = [ '512x512x512', '512x512x256', '512x256x512', '256x512x512', '256x256x512', '256x512x256', '512x256x256', '256x256x256', '128x256x512', '128x512x256', '256x128x512', '512x128x256', '512x256x128' ]
#topology = [ '256x256x256', '512x512x512', '128x256x512', '512x256x128' ]




numIter = 11
ts = time.time()
make_file = 'F'


project = 'visualization'
basedir = 'projects/visualization/mlewis/hiero/mira'

linecount = 0
for node in nodes :
  make_file = 'F'
  for iter in range (0, numIter):
      print '\nStarting ' + 'decomp' + ' on ' + str(node) + '  basedir: ' + basedir 
      if iter > 0 :
         make_file = 'T'
      jobid = runcmd('newtop', node, basedir, make_file)
      filename = 'newtop' + '_' + str(node)  + '_' + str(iter) + '_' + socket.gethostname()+ '_' + timestamp
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
  rncmd = 'rm -rf ' + '/' + basedir + '/smallestplane' + '/*'
  Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
  rncmd = 'rm -rf ' + '/' + basedir + '/fixedplane' + '/*' 
  Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
  rncmd = 'rm -rf ' + '/' + basedir + '/noleader' + '/*'
  Popen(rncmd, shell=True, stdout=PIPE).communicate()[0]
  
