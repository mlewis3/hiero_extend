#!/usr/bin/python

import os
import time
from subprocess import *
import sys
import datetime
import socket
#import numpy as np
#import pylab as plt

nodes = [1024]
modes = ['topologies']
baseDir = '/projects/ExaHDF5/mlewis/hiero'
plotfile = 'plotit'
searchstring = 'Time for read'
executables = ['No Leader', 'Fixed Plane', 'Smallest Plane']


def runcmd (pgm, node, dir):

	script = './' + pgm + '.sh ' + str(node)  + ' ' + str(dir)
        cmd = 'qsub -A ' + project + ' -t 01:00:00 -n '+str(node)+' --mode script '+script
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


numIter = 10
outstreamlist = []
linelist = []
arraylist = []
arraylist.append(noleaderarray)
arraylist.append(fixedplanearray)
arraylist.append(smallestplanearray)
outputlist = []
ts = time.time()


project = 'visualization'
basedir = '/projects/visualization/mlewis/hiero'

#project = 'ExaHDF5'
#basedir = '/projects/ExaHDF5/mlewis/hiero'

linecount = 0
for nodeIndex,node in enumerate(nodes):
  for iter in range (0, numIter):
    for pgm in modes:
      print '\nStarting ' + pgm + ' on ' + str(node) + ' nodes, basedir: ' + basedir 
      jobid = runcmd(pgm, node, basedir)
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
      outputfile = filename + '.output'
      if linelist :
        linelist = []
      for searchstring in searchstringlist:
        grepcmd = 'grep ' + '\'' + searchstring + '\' ' + outputfile
        grepoutput = Popen(grepcmd, shell=True, stdout=PIPE).communicate()[0]
        linelist.append(grepoutput)
      #index = -1
      for index,output in enumerate(linelist) :
       if output :
        print 'line output : ' + output + '\n'
        #index += 1
        # retrieving the output generation for a particular topology
        lines = output.split('\n')
        for index1,line in enumerate(lines):
          words = line.split()
          #print str(len(words)) + '\n'
          if words :
            print str(index1) + ' ' + str(index) + '\n' 
						#  read write time
            arraylist[index][index1][7] = float(arraylist[index][index1][7]) + float(words[6])
            arraylist[index][index1][8] = float(arraylist[index][index1][8]) + float(words[9])
            # open read close read
            arraylist[index][index1][9] = float(arraylist[index][index1][9]) + float(words[7])
            arraylist[index][index1][10] = float(arraylist[index][index1][10]) + float(words[8])
            # open time close time
            arraylist[index][index1][11] = float(arraylist[index][index1][11]) + float(words[5])
            arraylist[index][index1][12] = float(arraylist[index][index1][12]) + float(words[10])

            # read bandwidth
            arraylist[index][index1][13] = float(arraylist[index][index1][13]) + float(words[17])

            if iter == numIter -1: 
              arraylist[index][index1][0] = (float(words[2]) * float(words[3]) * float(words[4]) * 14 * 8) / 1048576
              #nx_g ny_g nz_g
              arraylist[index][index1][1] = int(words[2])
              arraylist[index][index1][2] = int(words[3])
              arraylist[index][index1][3] = int(words[4])
              #npx npy npz 
              arraylist[index][index1][4] = int(words[18])
              arraylist[index][index1][5] = int(words[19])
              arraylist[index][index1][6] = int(words[20])
              # read write time
              arraylist[index][index1][7] = float(arraylist[index][index1][7]) / numIter
              arraylist[index][index1][8] = float(arraylist[index][index1][8]) / numIter
              # open read close read
              arraylist[index][index1][9] = float(arraylist[index][index1][9]) / numIter
              arraylist[index][index1][10] = float(arraylist[index][index1][10]) / numIter
              # open time close time
              arraylist[index][index1][11] = float(arraylist[index][index1][11]) / numIter
              arraylist[index][index1][12] = float(arraylist[index][index1][12]) / numIter

              #read bandwith
              arraylist[index][index1][13] = arraylist[index][index1][13] / numIter
              # ppn
              arraylist[index][index1][14] = 16
              # node size
              arraylist[index][index1][15] = node
              # time stamp
              arraylist[index][index1][16] = timestamp
              
              if nodeIndex == 0 and index1 == 0:
                print 'Opening : ' + filenamelist[index] + ' node ' + str(node) + '\n'
                outputstream = open(filenamelist[index],'w')
                outputstream.write(headerbanner + '\n')
              else :
                print 'Appending file : ' + filenamelist[index] + ' node ' + str(node) + '\n'
                outputstream = open(filenamelist[index],'a')
              for arrayindex in range(0,17):
                outputstream.write(str(arraylist[index][index1][arrayindex]) + '\t')
              outputstream.write('\n')
