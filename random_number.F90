!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: random_number.f90 2709 2014-08-17 18:44:44Z wkliao $

      !----< random_set_seed >-----------------------------------------
      subroutine random_set_seed
          use topology_m, only : myid
          implicit none

          integer i, seed_size
          integer, DIMENSION(:), ALLOCATABLE :: seed

          call random_seed(SIZE=seed_size)
          ALLOCATE(seed(seed_size))
          i = 1
          seed = myid + 37 * (/ (i - 1, i = 1, seed_size) /)
          call random_seed(PUT=seed)
      end subroutine random_set_seed

      !----< random_set >----------------------------------------------
      subroutine random_set
          use topology_m,  only : myid
#ifdef OPT
          use topology_m,  only : mypx
          use variables_m, only : temp_g, pressure_g, yspecies_g, u_g
#endif
          use variables_m, only : temp, pressure, yspecies, u
          use param_m,     only : nx, ny, nz, nsc, npx
          implicit none

#ifdef OPT
          integer xdim
#endif
          
          call RANDOM_NUMBER(yspecies(1:nx,1:ny,1:nz,1:nsc+1))
          call RANDOM_NUMBER(    temp(1:nx,1:ny,1:nz))
          call RANDOM_NUMBER(pressure(1:nx,1:ny,1:nz))
          call RANDOM_NUMBER(       u(1:nx,1:ny,1:nz,1:3))

#ifdef OPT
!		  if (mypx .eq. 0) then
!          xdim = nx*npx
!          call RANDOM_NUMBER(yspecies_g(1:xdim,1:ny,1:nz,1:nsc+1))
!          call RANDOM_NUMBER(    temp_g(1:xdim,1:ny,1:nz))
!          call RANDOM_NUMBER(pressure_g(1:xdim,1:ny,1:nz))
!          call RANDOM_NUMBER(       u_g(1:xdim,1:ny,1:nz,1:3))
!		  endif
!
#endif
      end subroutine random_set
