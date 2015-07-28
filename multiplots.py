#!/usr/bin/python

import os
from subprocess import *
import sys
import numpy as np
import pylab as plt
import socket

fields = 7
topologies = 30
volumes = 20
executes = 3
iterations = 10


nodes = [128]
#timestamps = ['07-20-00-42']
#timestamps = ['07-20-00-42']
timestamps = ['07-22-09-20']
arraylist = []
linelist = []
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane' ]
volumelist = [ '512x512x512', '512x512x256', '512x256x512', '256x512x512', '256x256x512', '256x512x256', '512x256x256', '256x256x256', '128x256x512', '128x512x256', '256x128x512', '512x128x256', '512x256x128' ] 
exectype = [ 'noleader', 'fixedplane', 'smallestplane' ]
toplist = []
decomplist = [ '16x8x16', '8x16x16', '16x16x8', '16x16x32', '16x32x16', '32x16x16', '32x32x16', '32x16x32', '16x32x32', '32x32x32', '64x32x32', '32x64x32', '32x32x64' ]
# arraylist = [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(executes) ] for i in range(iterations) ]
arraylist = [ [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(volumes) ] for i in range(executes) ]
noleader_values = [ [] for i in range(volumes) ]
fixedplane_values = [ [] for i in range(volumes) ]
smallestplane_values = [ [] for i in range(volumes) ]
noleader_strong = [ [] for i in range(volumes) ]
fixedplane_strong = [ [] for i in range(volumes) ]
smallestplane_strong = [ [] for i in range(volumes) ]


host_name = socket.gethostname()

for exec_index in range(executes) :
  for vol_index,volume in enumerate(volumelist) :
    for iter in range(iterations) :
      filename = 'decomp_' + str(volume) + '_' + str(iter) + '_' + host_name + '_' + timestamp + '.output'
      for top_index,decomp in enumerate(decomplist):
        grepcmd = 'grep ' + '\'' + searchstring + '\' ' + filename + ' | grep ' + decomp
        line = Popen(grepcmd, shell=True, stdout=PIPE).communicate()[0]
        words = line.split()
        if words :
          print words
          arraylist[exec_index][vol_index][top_index][0].append(float(words[6]))
          if iter == 0 :
            #npx, npy, npz
            arraylist[exec_index][vol_index][top_index][1].append(int(words[18]))
            arraylist[exec_index][vol_index][top_index][2].append(int(words[19]))
            arraylist[exec_index][vol_index][top_index][3].append(int(words[20]))
          if iter == 1 and exec_index == 0 and vol_index == 0 :
            # Every volume has the same topology
            toplist.append(top_index)


# Retrieving the mean for each volumextopology
for vol_index,volume in enumerate(volumelist) :
  for topvalues in toplist :
    noleader_values[vol_index].append(np.mean(arraylist[0][vol_index][topvalues][0]))
    fixedplane_values[vol_index].append(np.mean(arraylist[1][vol_index][topvalues][0]))
    smallestplane_values[vol_index].append(np.mean(arraylist[2][vol_index][topvalues][0]))

# Strong value graph  -- same volume, increasing core size
for vol_index,volume in enumerate(volumelist) :
  filename = host_name + 'strong_'  + volume + '_' + timestamps[0] + '.csv'
  input = open(filename,'w')
  base = [ 16, 8 , 16]
  nodesize = ( base[0] * base[1] * base[2] ) / 16
  header = ', , No Leader, Fixed Plane, Smallest Plane \n'
  input.write(header)
  
  for topvalues in toplist :
    topologyString = str(base[0]) + 'x' + str(base[1]) + 'x' + str(base[2])
    if ( topologyString == decomlist[topvalues]) :
      nodesize = (base[0] * base[1] * base[2] ) / 16
      row = str(nodesize)  + ',' + noleader_values[vol_index][topvalues] + ',' + fixedplane_values[vol_index][topvalues] + ',' + smallestplane_values[vol_index][topvalues] + '\n'
      base = list(map(lambda x: (x*2), base))
      input.write(row)


#Weak value graph , -- increasing volume  same core size
for topvalues in toplist :
  filename = host_name + 'weak_'  + decomposition[topvalues] + '_' + timestamps[0] + '.csv'

  


