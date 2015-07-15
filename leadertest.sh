#!/bin/bash 
#COBALT --disable_preboot
 
#export L1P_POLICY=std
#export BG_THREADLAYOUT=1   # 1 - default next core first; 2 - my core first

#Free bootable blocks
boot-block --reboot
 
NODES=$1


PROJECTDIR=projects/ExaHDF5/mlewis/hiero


for MODE in 1 #0  
do
for NSP in 11 #100 52  
do 
for PROG in noleader fixedplane smallestplane
do
#do
#for DATA in 256x256x128 256x256x256 256x256x512 256x512x512
for DATA in 256x256x256 512x512x512 256x512x256 #256x256x256 256x256x512 256x512x512
do
 for ppn in 16
 do
   
			RANKS=`echo "$NODES*$ppn"|bc`

      if [ "$RANKS" -eq "512" ]; then
          # 32 x 16 
      
          if [ $DATA = "256x256x256" ]; then		#assume ppn=16 always 
             for DECOMP in 4x8x16 4x16x8 16x4x8
             do
          
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
	              global=" 256 256 256 "
                decomp=" "
                if [ $DECOMP = "4x8x16" ]; then
                   decomp=" 4 8 16 "
                fi

                if [ $DECOMP = "4x16x8" ]; then
                   decomp=" 4 16 8 "
                fi

                if [ $DECOMP = "16x4x8" ]; then
                   decomp=" 16 4 8 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp global $global"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo

             done  
             
           fi
       fi

      if [ "$RANKS" -eq "1024" ]; then
          # 64 x 16 
      
          if [ $DATA = "256x256x256" ]; then		#assume ppn=16 always 
             for DECOMP in 8x8x16 16x8x8 8x16x8
             do
          
	              global=" 256 256 256 "
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
                if [ $DECOMP = "8x8x16" ]; then
                   decomp=" 8 8 16 "
                fi

                if [ $DECOMP = "16x8x8" ]; then
                   decomp=" 16 8 8 "
                fi

                if [ $DECOMP = "8x16x8" ]; then
                   decomp=" 8 16 8 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo

             done  
             
           fi
       fi

      if [ "$RANKS" -eq "2048" ]; then
          # 128 x 16 
          if [ $DATA = "512x512x512" ]; then		#assume ppn=16 always 
             for DECOMP in 8x16x16
             do
          
	              global=" 512 512 512 "
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
                if [ $DECOMP = "8x16x16" ]; then
                   decomp=" 8 16 16 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo

             done  
             
           fi
       fi

      if [ "$RANKS" -eq "4096" ]; then
          # 256 x 16 
          if [ $DATA = "512x512x512" ]; then		#assume ppn=16 always 
             for DECOMP in 16x16x16
             do
          
	              global=" 512 512 512 "
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
                if [ $DECOMP = "16x16x16" ]; then
                   decomp=" 16 16 16 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo
             done  
             
           fi
       fi

      if [ "$RANKS" -eq "8192" ]; then
          # 512 x 16 
          if [ $DATA = "512x512x512" ]; then		#assume ppn=16 always 
             for DECOMP in 16x32x16 16x16x32 32x16x16
             do
          
	              global=" 512 512 512 "
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
                if [ $DECOMP = "16x32x16" ]; then
                   decomp=" 16 32 16 "
                fi

                if [ $DECOMP = "16x16x32" ]; then
                   decomp=" 16 16 32 "
                fi

                if [ $DECOMP = "32x16x16" ]; then
                   decomp=" 32 16 16 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T  /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo
             done  
         fi
          if [ $DATA = "256x512x256" ]; then		#assume ppn=16 always 
             for DECOMP in 16x32x16 32x16x16 16x16x32
             do
          
	              global=" 256 512 256 "
                mkdir -p /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
                if [ $DECOMP = "16x32x16" ]; then
                   decomp=" 16 32 16 "
                fi

                if [ $DECOMP = "16x16x32" ]; then
                   decomp=" 16 16 32 "
                fi

                if [ $DECOMP = "32x16x16" ]; then
                   decomp=" 32 16 16 "
                fi

								 ENVS="PAMID_VERBOSE=1"
								 OUTPUT=${PROG}_N${NODES}_R${ppn}_${MODE}_${NSP}_${DATA}_${LOCAL}
								 echo 
								 echo "* * * * *"
								 echo "Starting $OUTPUT  with $decomp"
								 runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs "${ENVS}" : ${PROG} ${global} ${decomp} $MODE ${NSP} T /${PROJECTDIR}/${PROG}/${DATA}/${DECOMP}
								 echo "* * * * *"
								 echo
             done  
         fi
       fi
  
  done
 done
done
done
done

exit
 
