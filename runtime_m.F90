!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: runtime_m.f90 2709 2014-08-17 18:44:44Z wkliao $

      module runtime_m
      implicit none

      integer i_time        !time step counter
      integer method        ! 0: blocking APIs, 1: nonblocking
      logical restart       ! new run or restart switch:
                            ! .FALSE. for new run, .TRUE. for restart
      integer i_time_end    !ending time step

      double precision time          !current time
      double precision tstep         !timestep (non-dimensional)
      double precision time_save     !time at which to write savefiles (seconds)
      double precision time_save_inc !increment by which to write savefiles (seconds)

      double precision time_ref      !reference time (s)

      character(len=20) run_title    !unique title of run

      end module runtime_m
