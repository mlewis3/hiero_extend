!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: main.f90 2710 2014-08-18 21:12:55Z wkliao $

      !----< main >-----------------------------------------------------
      program main
         use mpi
         use param_m,    only: npx, npy, npz, nx_g, ny_g, nz_g
         use param_m,    only: initialize_param
         use topology_m, only: gcomm, npes, myid, initialize_topology
#if defined(OPT) || defined(OPT_2)
         use param_m,    only: n_core0
         use topology_m, only: gcomm_x, gcomm_y, gcomm_yz, gcomm_yz_0, gcomm_node
         use topology_m, only: gcomm_z, gcomm_xz, gcomm_xy, gcomm_xz_0, gcomm_xy_0 
         use topology_m, only: mypx, mypy, mypz, mycore, ppn, nodenum
         use variables_m, only: xplane, yplane, zplane
#endif

         implicit none

         integer err
         logical isArgvRight
#if defined(OPT) || defined(OPT_2)
         integer res1, res2	!debug
#endif	

         call MPI_Init(err)
         call MPI_Comm_rank(MPI_COMM_WORLD, myid, err)
         call MPI_Comm_size(MPI_COMM_WORLD, npes, err)
         call MPI_Comm_dup (MPI_COMM_WORLD, gcomm,err)

         call read_command_line_arg(isArgvRight)
         if (.NOT. isArgvRight)  goto 999

         ! initialize parameters: nx, ny, nz, nsc, n_spec
         call initialize_param(myid, gcomm)

         ! intialize MPI process topology
         call initialize_topology(npx,npy,npz)


         
#if defined(OPT_2) || defined(OPT)
         ppn = 16
         mycore = mod (myid, ppn)
         nodenum = myid/ppn
              ! print *, '0 ', nx_g, ny_g,nz_g, ppn, myid, nodenum,mycore
              call MPI_Comm_split (MPI_COMM_WORLD, mypx, myid, gcomm_x, err)
              call MPI_Comm_split (MPI_COMM_WORLD, mypy, myid, gcomm_y, err)
              call MPI_Comm_split (MPI_COMM_WORLD, mypz, myid, gcomm_z, err)
           !    print *,'1 ',  nx_g, ny_g,nz_g, ppn, myid, nodenum,mycore
              call MPI_Comm_split (gcomm_y, mypz, myid, gcomm_yz, err)
               print *,'2 ',  nx_g, ny_g,nz_g, ppn, myid, nodenum,mycore
         !     call MPI_Comm_split (gcomm_yz, mycore, myid, gcomm_yz_0, err)
              call MPI_Comm_split (gcomm_x, mypz, myid, gcomm_xz, err) 
               print *, '3 ', nx_g, ny_g,nz_g, ppn, myid, nodenum,mycore
          !    call MPI_Comm_split (gcomm_xz, mycore, myid, gcomm_xy_0, err)
              call MPI_Comm_split (gcomm_x, mypy, myid, gcomm_xy, err) 
               print *, '4 ', nx_g, ny_g,nz_g, ppn, myid, nodenum,mycore
           !   call MPI_Comm_split (gcomm_xy, mycore, myid, gcomm_xy_0, err)


#endif

#ifdef COMMENT_OUT
         ppn = 1
         mycore = mod (myid, ppn)
         nodenum = myid/ppn

       !  if (myid .eq. 0 ) then 
         !     write(6, *, advance = "no")    ' Reviewing x,y,z planes   :  ',xplane, ' ', yplane, ' ',zplane
       !  endif

!         call MPI_Comm_split (MPI_COMM_WORLD, mypz, myid, gcomm_z, err)
         ! print *, '--- ', nx_g, '---- ', ny_g, '---- ', nz_g
   
         if ( ((ny_g * nz_g) .le. (nx_g * nz_g)) .and. ((ny_g * nz_g) .le. (nx_g * ny_g))) then
              !yz plane
              call MPI_Comm_split (MPI_COMM_WORLD, mypx, myid, gcomm_x, err)
              call MPI_Comm_split (MPI_COMM_WORLD, mypy, myid, gcomm_y, err)
              call MPI_Comm_split (gcomm_y, mypz, myid, gcomm_yz, err)
              call MPI_Comm_split (gcomm_yz, nodenum, myid, gcomm_node, err) 
              call MPI_Comm_split (gcomm_yz, mycore, myid, gcomm_yz_0, err)
              !check
              call MPI_Allreduce (myid, res1, 1, MPI_INT, MPI_MAX, gcomm_yz_0, err)
              call MPI_Allreduce (myid, res2, 1, MPI_INT, MPI_MAX, gcomm_node, err)
              call MPI_Comm_size (gcomm_yz_0, n_core0, err)

              if (mypx .eq. 0) then
             !    print*, 'MAIN--- YZ Plane ', myid, ' ', mycore, ' of ', nodenum, res1, res2, n_core0
               endif

        else if ( ((nx_g * nz_g) .le. (ny_g * nz_g)) .and. ((nx_g * nz_g) .le. (nx_g * ny_g))) then
              ! y = 0 plane
              ! xz plane
              call MPI_Comm_split (gcomm_x, mypz, myid, gcomm_xz, err) 
              call MPI_Comm_split (gcomm_xz, nodenum, myid, gcomm_node, err)
              call MPI_Comm_split (gcomm_xz, mycore, myid, gcomm_xy_0, err)

              !check
              call MPI_Allreduce (myid, res1, 1, MPI_INT, MPI_MAX, gcomm_xz_0, err)
              call MPI_Allreduce (myid, res2, 1, MPI_INT, MPI_MAX, gcomm_node, err)
              call MPI_Comm_size (gcomm_xz_0, n_core0, err)

              if (mypy .eq. 0) then
                  print*, 'MAIN--- XY Plane ', myid, ' ', mycore, ' of ', nodenum, res1, res2, n_core0
              endif

        else
              ! z = 0 , xy plane
              call MPI_Comm_split (gcomm_x, mypy, myid, gcomm_xy, err) 
              call MPI_Comm_split (gcomm_xy, nodenum, myid, gcomm_node, err)
              call MPI_Comm_split (gcomm_xy, mycore, myid, gcomm_xy_0, err)

              !check
              call MPI_Allreduce (myid, res1, 1, MPI_INT, MPI_MAX, gcomm_xy_0, err)
              call MPI_Allreduce (myid, res2, 1, MPI_INT, MPI_MAX, gcomm_node, err)
              call MPI_Comm_size (gcomm_xy_0, n_core0, err)

              if (mypz .eq. 0) then
                  print*, 'MAIN-- Z Plane ', myid, ' ', mycore, ' of ', nodenum, res1, res2, n_core0
              endif
        endif

#endif


!#ifdef OPT
!		 ppn = 1
!		 mycore = mod (myid, ppn)
!		 nodenum = myid/ppn
!		 call MPI_Comm_split (MPI_COMM_WORLD, mypx, myid, gcomm_x, err)
!		 call MPI_Comm_split (MPI_COMM_WORLD, mypy, myid, gcomm_y, err)
!		 call MPI_Comm_split (gcomm_y, mypz, myid, gcomm_yz, err)
!		 call MPI_Comm_split (gcomm_yz, nodenum, myid, gcomm_node, err)
!		 call MPI_Comm_split (gcomm_yz, mycore, myid, gcomm_yz_0, err)

		!check
!     call MPI_Allreduce (myid, res1, 1, MPI_INT, MPI_MAX, gcomm_yz_0, err)
!		 call MPI_Allreduce (myid, res2, 1, MPI_INT, MPI_MAX, gcomm_node, err)
!		 call MPI_Comm_size (gcomm_yz_0, n_core0, err)
!		 if (mypx .eq. 0) then
		  !print*, 'MAIN-- OPT: ', myid, ' ', mycore, ' of ', nodenum, res1, res2, n_core0
!		 endif
!#endif



         ! main computation task is here
         call MPI_Barrier(gcomm,err)
         ! if (myid .eq. 0) then write(6,*) 'Reporting results '
         call solve_driver

999      call MPI_Finalize(err)
      end program main

      !----< read_command_line_arg >------------------------------------
      subroutine read_command_line_arg(isArgvRight)
         use mpi
         use param_m,        only: nx_g, ny_g, nz_g, npx, npy, npz, n_spec
         use param_m,        only: initialize_param
         use runtime_m,      only: method, restart
         use topology_m,     only: gcomm, npes, myid, initialize_topology
         use io_profiling_m, only: dir_path
         implicit none

         character(len=128) executable
         logical isArgvRight

         ! declare external functions
         integer IARGC

         ! local variables for reading command-line arguments
         character(len = 256) :: argv(10)
         integer i, argc, int_argv(8), err

         ! Only root process reads command-line arguments
         if (myid .EQ. 0) then
            isArgvRight = .TRUE.
            call getarg(0, executable)
            argc = IARGC()
            !print *, 'argc= ', argc
            if (argc .NE. 10) then
               print *, 'Usage: ',trim(executable), &
               ' nx_g ny_g nz_g npx npy npz method nsp restart dir_path'
               isArgvRight = .FALSE.
            else
               do i=1, argc-2
                  call getarg(i, argv(i))
                  read(argv(i), FMT='(I16)') int_argv(i)
            !	  print *, 'argv(', i, ') = ', int_argv(i)
               enddo
               call getarg(argc-1, argv(argc-1))
               read(argv(argc-1), FMT='(L)') restart
             !  print *, 'restart = ', restart

               call getarg(argc, argv(argc))
               dir_path = argv(argc)
              ! print *, 'path = ', dir_path

               nx_g   = int_argv(1)
               ny_g   = int_argv(2)
               nz_g   = int_argv(3)
               npx    = int_argv(4)
               npy    = int_argv(5)
               npz    = int_argv(6)
               method = int_argv(7)
               n_spec = int_argv(8)
            endif
         endif

        ! broadcast if arguments are valid
         call MPI_Bcast(isArgvRight, 1, MPI_LOGICAL, 0, gcomm, err)
         if (.NOT. isArgvRight) return

         call MPI_Bcast(nx_g,       1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(ny_g,       1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(nz_g,       1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(npx,        1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(npy,        1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(npz,        1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(method,     1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(n_spec,     1, MPI_INTEGER,   0, gcomm, err)
         call MPI_Bcast(restart,    1, MPI_LOGICAL,   0, gcomm, err)
         call MPI_Bcast(dir_path, 256, MPI_CHARACTER, 0, gcomm, err)

      end subroutine read_command_line_arg

