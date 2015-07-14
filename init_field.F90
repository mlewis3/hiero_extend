!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: init_field.f90 2192 2013-11-14 19:48:08Z wkliao $

      !----< initialize_field >----------------------------------------
      subroutine initialize_field
         ! initializes primitive and solution variables amoung other things
         use variables_m, only: allocate_variables_arrays
         use runtime_m,   only: restart, time_save, time_save_inc
         use topology_m,  only: gcomm
         implicit none

         integer err

         ! allocate checkpointing variable arrays
         call allocate_variables_arrays(1)

         time_save_inc = 1.0e+5
         time_save = time_save_inc

         ! Restart code from prevous data files.
         if (restart)  then
            call MPI_Barrier(gcomm,err)
            call read_savefile
         endif
      end subroutine initialize_field
