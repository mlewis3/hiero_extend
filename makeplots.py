#!/usr/bin/python

import os
from subprocess import *
import sys
import numpy as np
import pylab as plt
import socket

fields = 7
topologies = 30
executes = 3
iterations = 10


nodes = [128]
#timestamps = ['07-20-00-42']
#timestamps = ['07-20-00-42']
timestamps = ['07-22-09-20']
arraylist = []
linelist = []
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane' ]
exectype = [ 'noleader', 'fixedplane', 'smallestplane' ]
toplist = []
# arraylist = [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(executes) ] for i in range(iterations) ]
arraylist = [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(executes) ] 
imagelist = []
noleader_values = []
fixedplane_values = []
smallestplane_values = []

host_name = socket.gethostname()

for node in nodes :
 for timestamp in timestamps :
   for iter in range(iterations) :
    filename = 'opnewtop_' + str(node) + '_' + str(iter) + '_' + host_name + '_' + timestamp + '.output'
    if linelist :
       linelist = []
    for searchstring in searchstringlist:
     grepcmd = 'grep ' + '\'' + searchstring + '\' ' + filename
     grepoutput = Popen(grepcmd, shell=True, stdout=PIPE).communicate()[0]
     linelist.append(grepoutput)
    for exec_index,output in enumerate(linelist) :
      #iterating through all the topologies
      lines = output.split('\n')
      for top_index,line in enumerate(lines) :
        #print line + '\n'
        words = line.split()
        if words :
          print words
          arraylist[exec_index][top_index][0].append(float(words[6]))
          if iter == 0 :

            #npx, npy, npz
            arraylist[exec_index][top_index][1].append(int(words[18]))
            arraylist[exec_index][top_index][2].append(int(words[19]))
            arraylist[exec_index][top_index][3].append(int(words[20]))
            #nx_g, ny_g, nz_g
            arraylist[exec_index][top_index][4].append(int(words[2]))
            arraylist[exec_index][top_index][5].append(int(words[3]))
            arraylist[exec_index][top_index][6].append(int(words[4]))
          if iter == 1 and exec_index == 0 :
             # print filename + '_ ' + float(words[6])
             toplist.append(top_index)

# imagelist = [ exec ] [ topologies ] [ (read value 1) ( read value 2 ) ....  ( read value num iterations) ] 
for top_index,topvalues in enumerate(toplist) :
    word1 =  arraylist[0][topvalues][1][0]
    word2 =  arraylist[0][topvalues][2][0]
    word3 =  arraylist[0][topvalues][3][0]
    noleader_values.append(np.mean(arraylist[0][topvalues][0]))
    fixedplane_values.append(np.mean(arraylist[1][topvalues][0]))
    smallestplane_values.append(np.mean(arraylist[2][topvalues][0]))

#Writing the final data
filename = host_name + '_'  + str(nodes[0]) + '_' + timestamps[0] + '.csv'
csvinput = open(filename,'w')
prev_vol_top = ' '
curr_vol_top =  ' '
for top_index,topvalues in enumerate(toplist) :
  global_banner = ' ' + str(arraylist[0][topvalues][4][0]) + 'X' +  str(arraylist[0][topvalues][5][0]) + 'X' +  str(arraylist[0][topvalues][6][0]) + ' '
  local_banner = ' ' + str(arraylist[0][topvalues][1][0]) + 'X' +  str(arraylist[0][topvalues][2][0]) + 'X' + str(arraylist[0][topvalues][3][0]) + ' '
  nl = str(noleader_values[top_index])
  fp = str(fixedplane_values[top_index])
  sp = str(smallestplane_values[top_index])
  if (top_index == 0) :
    header = ', , No Leader, Fixed Plane, Smallest Plane \n'
    csvinput.write(header)
    prev_vol_top = global_banner
    curr_vol_top = global_banner
    input_line = global_banner + ',' + local_banner + ',' + nl + ',' + fp + ',' + sp + '\n'
    csvinput.write(input_line)
  else :
    curr_vol_top = global_banner
    if curr_vol_top == prev_vol_top :
      input_line = ',' + local_banner + ',' + nl + ',' + fp + ',' + sp + '\n'
    else :
      input_line = global_banner + ',' + local_banner + ',' + nl + ',' + fp + ',' + sp + '\n'
    prev_vol_top = global_banner
    csvinput.write(input_line)
       
