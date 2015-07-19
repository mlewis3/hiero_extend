#!/usr/bin/python

import os
from subprocess import *
import sys
import numpy as np
import pylab as plt
import socket

fields = 1
topologies = 30


nodes = [1024]
timestamps = ['07-18-15-10']
arraylist = []
linelist = []
searchstringlist = [ 'grep_no_leader' , 'grep_fixed_plane' , 'grep_smallest_plane' ]
exectype = [ 'noleader', 'fixedplane', 'smallestplane' ]

smallestplane =  [ [ [0.0] for j in range(fields) ] for i in range(topologies) ] 
fixedplane =  [ [ [0.0] for j in range(fields) ] for i in range(topologies) ] 
noleader =  [ [ [0.0] for j in range(fields) ] for i in range(topologies) ] 
arraylist.append(smallestplane)
arraylist.append(fixedplane)
arraylist.append(noleader)
iterations = 10

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
    for exec_index,lines in enumerate(linelist) :
      #iterating through all the topologies
      for top_index,line in enumerate(lines) :
        print line + '\n'
        words = line.split()
        if words: 
          arraylist[exec_index][top_index].append(float(words[6]))
        if iter == iterations - 1 :
          imagename = exectype[exec_index] + '_' + str(node) + '_' + words[18] + '_' + words[19] + '_' + words[20] + '.png'
          textfile = exectype[exec_index] + '_' + str(node) + '_' + words[18] + '_' + words[19] + '_' + words[20] + '.txt'
          input = textfile.open(textfile,'w')
          input.write(arraylist[exec_index][top_index])
          plt.boxplot(arraylist[exec_index][top_index])
          plt.savefig(imagename)
