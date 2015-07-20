#!/usr/bin/python

import os
from subprocess import *
import sys
import numpy as np
import pylab as plt
import socket

fields = 4
topologies = 30
executes = 3
iterations = 10


nodes = [512]
timestamps = ['07-20-00-37']
arraylist = []
linelist = []
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane' ]
exectype = [ 'noleader', 'fixedplane', 'smallestplane' ]
toplist = []
# arraylist = [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(executes) ] for i in range(iterations) ]
arraylist = [ [ [ [ ] for l in range(fields) ] for k in range(topologies) ] for j in range(executes) ] 
imagelist = []

host_name = socket.gethostname()

for node in nodes :
 for timestamp in timestamps :
   for iter in range(iterations) :
    filename = 'optopologies_' + str(node) + '_' + str(iter) + '_' + host_name + '_' + timestamp + '.output'
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
        if words:
          arraylist[exec_index][top_index][0].append(float(words[6]))
          if iter == 0 :
            arraylist[exec_index][top_index][1].append(float(words[18]))
            arraylist[exec_index][top_index][2].append(float(words[19]))
            arraylist[exec_index][top_index][3].append(float(words[20]))
          if iter == 0 and exec_index == 0:
             toplist.append(top_index)

# imagelist = [ exec ] [ topologies ] [ (read value 1) ( read value 2 ) ....  ( read value num iterations) ] 
for exec_index in range(3):
  for top_index,topvalues in enumerate(toplist) :
    word1 =  arraylist[exec_index][topvalues][1][0]
    word2 =  arraylist[exec_index][topvalues][2][0]
    word3 =  arraylist[exec_index][topvalues][3][0]
    if not word1 :
     print 'something is wrong: exec_index ' + str(exectype[exec_index]) + ' top index ' + str(topvalues) + '\n'
    imagename =  exectype[exec_index] + '_' + str(top_index) + '_' + host_name + '_' + str(nodes[0]) + '_' + str(word1) + '_' + str(word2) + '_' + str(word3) + '.png'
    textfile =   exectype[exec_index] + '_' + str(top_index) + '_' + host_name + '_' + str(nodes[0]) + '_' + str(word1) + '_' + str(word2) + '_' + str(word3) + '.txt'
    input = open(textfile,'w')
    output = []
    for k in arraylist[exec_index][topvalues][0] :
      input.write(str(k) + ' ')
    plt.boxplot(arraylist[exec_index][topvalues][0])
    plt.savefig(imagename)

