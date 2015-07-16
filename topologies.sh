#!/bin/bash 
#COBALT --disable_preboot
 
#export L1P_POLICY=std
#export BG_THREADLAYOUT=1   # 1 - default next core first; 2 - my core first

#Free bootable blocks
boot-block --reboot
 
NODES=$1


PROJECTDIR=$2


for MODE in 1 #0  
do
for NSP in 11 #100 52  
do 
for PROG in noleader fixedplane smallestplane
do
#do
#for DATA in 256x256x128 256x256x256 256x256x512 256x512x512
for DATA in 512x512x512 512x512x256 512x256x512 256x512x512 256x256x512 256x512x256 512x256x256 256x256x256 128x256x512 128x512x256 256x128x512 512x128x256 512x256x128 
do
 if [ $DATA = "512x512x512" ]; then 
    global=" 512 512 512 "
 elif [ $DATA = "512x512x256" ]; then 
    global=" 512 512 256 "
 elif [ $DATA = "512x256x512" ]; then 
    global=" 512 256 512 "
 elif [ $DATA = "256x512x512" ]; then 
    global=" 256 512 512 "
 elif [ $DATA = "256x256x512" ]; then 
    global=" 256 256 512 "
 elif [ $DATA = "256x512x256" ]; then 
    global=" 256 512 256 "
 elif [ $DATA = "512x256x256" ]; then 
    global=" 512 256 256 "
 elif [ $DATA = "256x256x256" ]; then 
    global=" 256 256 256 "
 elif [ $DATA = "128x256x512" ]; then 
    global=" 128 256 512 "
 elif [ $DATA = "128x512x256" ]; then 
    global=" 128 512 256 "
 elif [ $DATA = "256x128x512" ]; then 
    global=" 256 128 512 "
 elif [ $DATA = "512x128x256" ]; then 
    global=" 512 128 256 "
 elif [ $DATA = "512x256x128" ]; then 
    global=" 512 256 128 "
 fi
 
 for ppn in 16
 do
   
      RANKS=`echo "$NODES*$ppn"|bc`
      #16x8x16 8x16x16 16x16x8 16x16x32 16x32x16 32x16x16 32x32x16 32x16x32 16x32x32 32x32x32 64x32x32 32x64x32 32x32x64
      for DECOMP in 16x8x16 8x16x16 16x16x8 16x16x32 16x32x16 32x16x16 32x32x16 32x16x32 16x32x32 32x32x32 64x32x32 32x64x32 32x32x64
      do
         mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
         if [ $NODES = "128" ]; then
           if [ $DECOMP = "16x8x16" ]; then
             decomp="16 8 16"
           elif [ $DECOMP = "8x16x16" ]; then
             decomp="8 16 16"
           elif [ $DECOMP = "16x16x8" ]; then
             decomp="16 16 8"
           else
             continue
           fi
         elif [ $NODES = "512" ]; then
           if [ $DECOMP = "16x16x32" ]; then
             decomp="16 16 32"
           elif [ $DECOMP = "16x32x16" ]; then
             decomp="16 32 16"
           elif [ $DECOMP = "32x16x16" ]; then
             decomp="32 16 16"
           else
             continue
           fi
         elif [ $NODES = "1024" ]; then
           if [ $DECOMP = "32x32x16" ]; then
             decomp="32 32 16"
           elif [ $DECOMP = "32x16x32" ]; then
             decomp="32 16 32"
           elif [ $DECOMP = "16x32x32" ]; then
             decomp="16 32 32"
           else 
             continue
           fi
         elif [ $NODES = "2048" ]; then
           if [ $DECOMP = "32x32x32" ]; then
             decomp="32 32 32"
           else
             continue
           fi
         elif [ $NODES = "4096" ]; then
           if [ $DECOMP = "64x32x32" ]; then
             decomp="64 32 32"
           elif [ $DECOMP = "32x64x32" ]; then
             decomp="32 64 32"
           elif [ $DECOMP = "64x32x32" ]; then
             decomp="32 32 64"
           else 
             continue
           fi
         fi


         ENVS="PAMID_VERBOSE=1"
         OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}
	 echo 
         echo "* * * * *"
         echo "Starting $OUTPUT  with $decomp global $global"
	 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} F /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
         echo "* * * * *"
	 echo

      done #DECOMP 
      done #PPN  
  
  done #DATA
 done #PROGRAM
done #NSP
done #MODE

exit
 
