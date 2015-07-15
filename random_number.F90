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
#if defined(OPT) || defined(OPT_2)
          use topology_m,  only : mypx, mypy, mypz
          use variables_m, only : temp_g, pressure_g, yspecies_g, u_g
          use variables_m, only : xplane, yplane, zplane
#endif
          use variables_m, only : temp, pressure, yspecies, u
          use param_m,     only : nx, ny, nz, nsc, npx, npy, npz
          implicit none

#if defined(OPT) || defined(OPT_2)
          integer xdim
#endif
          

#ifdef OPT
		  if (mypx .eq. 0) then
          xdim = nx*npx
          call RANDOM_NUMBER(yspecies_g(1:xdim,1:ny,1:nz,1:nsc+1))
          call RANDOM_NUMBER(    temp_g(1:xdim,1:ny,1:nz))
          call RANDOM_NUMBER(pressure_g(1:xdim,1:ny,1:nz))
          call RANDOM_NUMBER(       u_g(1:xdim,1:ny,1:nz,1:3))
    endif

#elif OPT_2
        if (xplane .eqv. .true.) then 
          if (mypx .eq. 0 ) then
                 xdim = nx * npx
                    call RANDOM_NUMBER(yspecies_g(1:xdim,1:ny,1:nz, 1:nsc+1))
                    call RANDOM_NUMBER(       u_g(1:xdim,1:ny,1:nz,1:3))
                    call RANDOM_NUMBER(pressure_g(1:xdim,1:ny,1:nz))
                    call RANDOM_NUMBER(    temp_g(1:xdim,1:ny,1:nz))
          endif
        else if (yplane .eqv. .true. ) then 
             if (mypy .eq. 0) then
               xdim = ny * npy
                  call RANDOM_NUMBER(yspecies_g(1:nx,1:xdim,nz,1:nsc+1))
                  call RANDOM_NUMBER(       u_g(1:nx,1:xdim,nz,1:3))
                  call RANDOM_NUMBER(pressure_g(1:nx,1:xdim,nz))
                  call RANDOM_NUMBER(    temp_g(1:nx,1:xdim,nz))
              endif
        else
            if (mypz .eq. 0) then 
               xdim = nz * npz
                  call RANDOM_NUMBER(yspecies_g(1:nx,1:ny,1:xdim,1:nsc+1))
                  call RANDOM_NUMBER(       u_g(1:nx,1:ny,1:xdim,1:3))
                  call RANDOM_NUMBER(pressure_g(1:nx,1:ny,1:xdim))
                  call RANDOM_NUMBER(    temp_g(1:nx,1:ny,1:xdim))
            endif
        endif

#else
          call RANDOM_NUMBER(yspecies(1:nx,1:ny,1:nz,1:nsc+1))
          call RANDOM_NUMBER(    temp(1:nx,1:ny,1:nz))
          call RANDOM_NUMBER(pressure(1:nx,1:ny,1:nz))
          call RANDOM_NUMBER(       u(1:nx,1:ny,1:nz,1:3))
#endif


      end subroutine random_set
