!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: variables_m.f90 2192 2013-11-14 19:48:08Z wkliao $

      module variables_m
      ! module for variables variables
      implicit none

      ! primative variables
      double precision, allocatable :: yspecies(:,:,:,:) !mass fractions for ALL species
      double precision, allocatable ::        u(:,:,:,:) !velocity vector (non-dimensional)
      double precision, allocatable :: pressure(:,:,:)   !pressure (non-dimensional)
      double precision, allocatable ::     temp(:,:,:)   !temprature (non-dimensional)

#if defined(OPT) || defined(OPT_2)
      double precision, allocatable :: yspecies_g(:,:,:,:) !mass fractions for ALL species
      double precision, allocatable ::        u_g(:,:,:,:) !velocity vector (non-dimensional)
      double precision, allocatable :: pressure_g(:,:,:)   !pressure (non-dimensional)
      double precision, allocatable ::     temp_g(:,:,:)   !temprature (non-dimensional)
      logical xplane, yplane, zplane
#ifdef V2
      double precision, allocatable :: yspecies_0(:,:,:,:) !mass fractions for ALL species
      double precision, allocatable ::        u_0(:,:,:,:) !velocity vector (non-dimensional)
      double precision, allocatable :: pressure_0(:,:,:)   !pressure (non-dimensional)
      double precision, allocatable ::     temp_0(:,:,:)   !temprature (non-dimensional)
#endif
#endif
      contains

      !----< allocate_variables_arrays() >-----------------------------
      subroutine allocate_variables_arrays(flag)
         ! allocate variables arrays
         use param_m, only : nx, ny, nz, nsc

#if defined(OPT) || defined(OPT_2)
         use param_m, only : nx_g, n_core0, ny_g, nz_g 
         use topology_m, only : mypx, mypy, mypz, mycore
         use param_m, only : npx, npy, npz
      
#endif

         implicit none
         integer flag
         integer xdim


#ifdef OPT_2
         integer leader_xplane, leader_yplane, leader_zplane
         leader_xplane = npy * npz
         leader_yplane = npx * npz
         leader_zplane = npx * npy
         xplane = .false.
         yplane = .false.
         zplane = .false.
    
          if (mypz .eq. 0) print *, ' Variable_m xplane ', leader_xplane, ' yplane ', leader_yplane, ' z plane: ' , leader_zplane 
         
         if ((leader_xplane .LE. leader_yplane) .AND. (leader_xplane .LE. leader_zplane)) then
             if (mypx .eq. 0 ) then
               xdim = nx_g
               if (flag .eq. 1) then
                  allocate(yspecies_g(xdim,ny,nz,nsc+1))
                  allocate(       u_g(xdim,ny,nz,3))
                  allocate(pressure_g(xdim,ny,nz))
                  allocate(    temp_g(xdim,ny,nz))
               endif
             endif
             xplane = .true.
         else if ( (leader_yplane .LE. leader_xplane) .AND. (leader_yplane .LE. leader_zplane) ) then
              if (mypy .eq. 0) then
                 xdim = ny_g
                 if (flag .EQ. 1) then
                   allocate(yspecies_g(nx,xdim,nz,nsc+1))
                   allocate(       u_g(nx,xdim,nz,3))
                   allocate(pressure_g(nx,xdim,nz))
                   allocate(    temp_g(nx,xdim,nz))
                 endif
              endif
              yplane = .true.
         else
             if (mypz .eq. 0) then    
                 xdim = nz_g
                 if (flag .eq. 1) then
                    allocate(yspecies_g(nx,ny,xdim,nsc+1))
                    allocate(       u_g(nx,ny,xdim,3))
                    allocate(pressure_g(nx,ny,xdim))
                    allocate(    temp_g(nx,ny,xdim))
                 endif
             endif
             zplane = .true.
         endif
!         print *, ' Variable planes ', xplane, yplane , zplane
#endif

#ifdef OPT
        xplane = .true.
        if (mypx .eq. 0) then
         xdim = nx_g
         if (flag .EQ. 1) then
            allocate(yspecies_g(xdim,ny,nz,nsc+1))
            allocate(       u_g(xdim,ny,nz,3))
            allocate(pressure_g(xdim,ny,nz))
            allocate(    temp_g(xdim,ny,nz))
          endif
         endif

#ifdef V2
      if (mycore .eq. 0) then
       xdim = nx_g/n_core0
       if (flag .EQ. 1) then
            allocate(yspecies_0(xdim,ny,nz,nsc+1))
            allocate(       u_0(xdim,ny,nz,3))
            allocate(pressure_0(xdim,ny,nz))
            allocate(    temp_0(xdim,ny,nz))
       endif
      endif
#endif
#endif

       xdim = nx
       if (flag .EQ. 1) then
          allocate(yspecies(xdim,ny,nz,nsc+1))
          allocate(       u(xdim,ny,nz,3))
          allocate(pressure(xdim,ny,nz))
          allocate(    temp(xdim,ny,nz))

       elseif (flag .EQ. -1) then
          deallocate(yspecies)
          deallocate(u)
          deallocate(pressure)
          deallocate(temp)
       endif

      end subroutine allocate_variables_arrays

      end module variables_m

