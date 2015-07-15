!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: topology_m.f90 2710 2014-08-18 21:12:55Z wkliao $

      module topology_m
      ! module for topology variables
      use mpi
      implicit none

      integer gcomm
#if defined(OPT) || defined(OPT_2)
      integer mycore, ppn, nodenum
      integer gcomm_x, gcomm_y, gcomm_yz, gcomm_yz_0, gcomm_node
      integer gcomm_z, gcomm_xy, gcomm_xz, gcomm_xy_0, gcomm_xz_0 
#endif
      integer npes          ! total number of processors
      integer myid          ! rank of local processor
      integer mypx, mypy, mypz

      contains

      !----< initialize_topology() >-----------------------------------
      subroutine initialize_topology(npx,npy,npz)
          ! routine initializes some MPI stuff and the Cartesian MPI grid
          implicit none
          integer npx, npy, npz

          integer err

          ! check for npes compatibility
          if (npx*npy*npz .NE. npes) then
 1000        format(' npx*npy*npz is not equal to npes, npx = ',  &
                    i5,' npy = ', i5, ' npz = ', i5, ' npes = ', i5)
             if (myid .EQ. 0) then
                print 1000, npx,npy,npz,npes
             endif
             call MPI_Finalize(err)
             stop
          endif

          ! initialize Cartesian grid
          mypz = myid/(npx*npy)
          mypx = mod(myid-(mypz*npx*npy), npx)
          mypy = (myid-(mypz*npx*npy))/npx

      end subroutine initialize_topology

      end module topology_m
