#!/usr/bin/python

import os
from subprocess import *
from pylab import *
import sys
import numpy as np
#import pylab as plt
import socket


fields = 7
machine_name = 'cetus'
timestamp = '07-29-13-25'
executable_script = 'newtop'


nodes = [512, 1024, 2048, 4096]
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane' ]
volumelist = [ '512x512x512', '512x512x256', '512x256x512', '256x512x512', '256x256x512', '256x512x256', '512x256x256', '256x256x256', '128x256x512', '128x512x256', '256x128x512', '512x128x256', '512x256x128' ] 
exectype = [ 'noleader', 'fixedplane', 'smallestplane' ]
toplist = []
decomplist = [ '16x16x32', '16x32x16', '32x16x16', '32x32x16', '32x16x32', '16x32x32', '32x32x32', '64x32x32', '32x64x32', '32x32x64' ]

#for fixed volume files 
strong_decomp = [ '16x16x32', '16x32x32', '32x32x32', '32x32x64' ]
node_decomp = [ '512', '1024', '2048', '4096' ]

weak_decomp = [ '256x256x256', '256x256x512', '256x512x512', '512x512x512' ]
volume_decomp = [ '2GB', '4GB', '8GB', '16GB' ] 

arraylist = [ [ [ [ ] for l in range(len(decomplist)) ] for k in range(len(volumelist)) ] for j in range(len(exectype)) ]
exec_mean = [ [ [ [ ] for l in range(len(decomplist)) ] for k in range(len(volumelist)) ] for j in range(len(exectype)) ]
noleader_mean = [ [ [ ] for i in range(len(decomplist)) ] for j in range(len(volumelist)) ]
fixedplane_mean = [ [ [ ] for i in range(len(decomplist)) ] for j in range(len(volumelist)) ]
smallestplane_mean = [ [ [ ] for i in range(len(decomplist)) ] for j in range(len(volumelist)) ]
host_name = socket.gethostname()

for exec_index,exeutable in enumerate(exectype) :
 for node in nodes :
     for iter in range(1,11) :
         filename = executable_script + '_' +  str(node) + '_' + str(iter) + '_' + host_name + '_' + timestamp + '.output'
         if os.path.isfile(filename) :
           # print 'Greping file name ' + filename + '\n'
           grepcmd = 'grep ' + '\'' + searchstringlist[exec_index] + '\' ' + filename 
           #print grepcmd
           output = Popen(grepcmd, shell=True, stdout=PIPE).communicate()[0]
           lines = output.split('\n')
           topology = 0
           for line_index,line in enumerate(lines) :
             words = line.split()
             # print 'Before: ' + str(words)
             #print len(words)
             if (len(words) == 26)  :
              # print words
              topology = words[18] + 'x' + words[19] + 'x' + words[20]
              volume = words[2] + 'x' + words[3] + 'x' + words[4]

              try :
                top_index = decomplist.index(topology)
              except ValueError :
                print 'Topology index ' + topology + ' not found \n'
                continue
              try :
                vol_index = volumelist.index(volume)
              except ValueError :
                 print ' Volume index ' + volume + ' not found \n'
                 continue

              #if (iter == 1 and exec_index == 0) :
              # print ' Values found at '  + str(vol_index) + ' ' + str(top_index) + ' time: ' + words[6] + ' filename ' + filename
              arraylist[exec_index][vol_index][top_index].append(float(words[6]))
         else :
          print 'Filename ' + filename + ' not found ! '


print ' Finished reading all values from file ! \n'

# Retrieving the mean for each volumextopology
for vol_index,volume in enumerate(volumelist) :
  for top_index, topvalue in enumerate(decomplist) :
    for execute_index in range(0,3) :
      imagename = '../mira_images/' + volume + '_' + topvalue + '_' + exectype[execute_index] + '.png'
      datatext = '../mira_data/' + volume + '_' + topvalue + '_' + exectype[execute_index] + '.txt'
      output = open(datatext,'w')
      output.write(str(arraylist[execute_index][vol_index][top_index]))
      exec_mean[execute_index][vol_index][top_index] = np.mean(arraylist[execute_index][vol_index][top_index])
      center = ones(5) * exec_mean[execute_index][vol_index][top_index]
      data = concatenate((arraylist[execute_index][vol_index][top_index],center),0)
      boxplot(data)
      savefig(imagename)

