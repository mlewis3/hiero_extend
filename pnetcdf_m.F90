!
!  Copyright (C) 2013, Northwestern University
!  See COPYRIGHT notice in top-level directory.
!
!  $Id: pnetcdf_m.f90 2709 2014-08-17 18:44:44Z wkliao $
#define IN_PLANE(xp,mypx,yp, mypy,zp,mypz) ( (xp .eqv. .true.) .AND. (mypx .eq. 0) ) .OR. ((yp .eqv. .true.)  .AND. (mypy .eq. 0) ) .OR. ( (zp .eqv. .true.)  .AND. (mypz .eq. 0)) 

      module pnetcdf_m
      ! module for Read-Write Restart files using Parallel NetCDF
      use mpi
      use io_profiling_m
      use pnetcdf

      implicit none

      private :: handle_err

      contains

      !----< handle_err() >---------------------------------------------
      subroutine handle_err(err_msg, errcode)
          implicit none
          integer,       intent(in) :: errcode
          character*(*), intent(in) :: err_msg

          ! local variables
          integer err
     
          print *, 'Error: ',trim(err_msg),' ',nfmpi_strerror(errcode)
          call MPI_Abort(MPI_COMM_WORLD, -1, err)
      end subroutine handle_err

      !----< pnetcdf_write() >------------------------------------------
      subroutine pnetcdf_write(filename)
          use topology_m,  only : gcomm, npes, mypx, mypy, mypz, myid
          use param_m,     only : nx, ny, nz, nx_g, ny_g, nz_g, nsc
          use variables_m, only : temp, pressure, yspecies, u
          use runtime_m,   only : method, time, tstep, time_save
#if defined(OPT) || defined(OPT_2)
          use topology_m,  only : gcomm_x, gcomm_yz, gcomm_yz_0, gcomm_node, mycore
          use topology_m,  only : gcomm_y, gcomm_z, gcomm_xz, gcomm_xy, gcomm_xz_0, gcomm_xy_0
          use variables_m, only : xplane, yplane, zplane
          use variables_m, only : temp_g, pressure_g, yspecies_g, u_g
#ifdef V2
          use variables_m, only : temp_0, pressure_0, yspecies_0, u_0
#endif
#endif
          implicit none


          ! declarations passed in
          character*(*), intent(in) :: filename

          ! local variables
          integer(MPI_OFFSET_KIND) g_sizes(4), subsizes(4), starts(4),len, put_size
          integer dimids(4), req(4), st(4), err, cmode
          integer ncid, yspecies_id, u_id, pressure_id, temp_id
          double precision time_start, time_end, d_time(1)

          ! create file and pass in the MPI hint
          time_start = MPI_Wtime()

          cmode = NF_CLOBBER + NF_64BIT_DATA
          put_size = 0

!#ifdef OPT
!          if (mypx .eq. 0) then
!            err = nfmpi_create(gcomm_x, trim(filename), cmode, file_info,ncid)
!            if (err .ne. NF_NOERR) call handle_err('nfmpi_create', err)
!            if (info_used .EQ. MPI_INFO_NULL) then
!                err = nfmpi_get_file_info(ncid, info_used)
!                if (err .ne. NF_NOERR) call handle_err('nfmpi_get_file_info', err)
!            endif
!          endif
#if defined(OPT_2) || defined(OPT) 
          if ((xplane .eqv. .true.)  .and. (mypx .eq. 0)) then
            err = nfmpi_create(gcomm_x, trim(filename), cmode, file_info,ncid)
            if (err .ne. NF_NOERR) call handle_err('nfmpi_create', err)
            if (info_used .EQ. MPI_INFO_NULL) then
                err = nfmpi_get_file_info(ncid, info_used)
                if (err .ne. NF_NOERR) call handle_err('nfmpi_get_file_info', err)
            endif
           print *, 'Opening from the x plane '
          elseif ( (yplane .eqv. .true.) .and. (mypy .eq. 0)) then 
            err = nfmpi_create(gcomm_y, trim(filename), cmode, file_info,ncid) 
            if (err .ne. NF_NOERR) call handle_err('nfmpi_create', err)
            if (info_used .EQ. MPI_INFO_NULL) then
                err = nfmpi_get_file_info(ncid, info_used)
                if (err .ne. NF_NOERR) call handle_err('nfmpi_get_file_info', err)
            endif
            print *, 'Opening from the y plane ' 
          elseif ( (zplane .eqv. .true.)  .and. (mypz .eq. 0)) then 
            err = nfmpi_create(gcomm_z, trim(filename), cmode, file_info,ncid)
            if (err .ne. NF_NOERR) call handle_err('nfmpi_create', err)
            if (info_used .EQ. MPI_INFO_NULL) then
                err = nfmpi_get_file_info(ncid, info_used)
                if (err .ne. NF_NOERR) call handle_err('nfmpi_get_file_info', err)
            endif
             print *, 'Opening from the z plane ' 
          endif
#else          
          err = nfmpi_create(gcomm, trim(filename), cmode, file_info,ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_create', err)
          if (info_used .EQ. MPI_INFO_NULL) then
              err = nfmpi_get_file_info(ncid, info_used)
              if (err .ne. NF_NOERR) call handle_err('nfmpi_get_file_info', err)
          endif
#endif
          time_end = MPI_Wtime()
          openT = openT + time_end - time_start
          openWT = openWT + time_end - time_start
          time_start = time_end

#if defined(OPT) || defined(OPT_2)
      !gather
         if (xplane .eqv. .true.) then
           call MPI_Gather (yspecies, nx, MPI_DOUBLE_PRECISION, yspecies_g, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
           call MPI_Gather (u, nx, MPI_DOUBLE_PRECISION, u_g, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
           call MPI_Gather (pressure, nx, MPI_DOUBLE_PRECISION, pressure_g, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
           call MPI_Gather (temp, nx, MPI_DOUBLE_PRECISION, temp_g, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
         else if (yplane .eqv. .true.) then 
       
           call MPI_Gather (yspecies, ny, MPI_DOUBLE_PRECISION, yspecies_g, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
           call MPI_Gather (u, ny, MPI_DOUBLE_PRECISION, u_g, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
           call MPI_Gather (pressure, ny, MPI_DOUBLE_PRECISION, pressure_g, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
           call MPI_Gather (temp, ny, MPI_DOUBLE_PRECISION, temp_g, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
         else
           ! zplane
           call MPI_Gather (yspecies, nz, MPI_DOUBLE_PRECISION, yspecies_g, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
           call MPI_Gather (u, nz, MPI_DOUBLE_PRECISION, u_g, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
           call MPI_Gather (pressure, nz, MPI_DOUBLE_PRECISION, pressure_g, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
           call MPI_Gather (temp, nz, MPI_DOUBLE_PRECISION, temp_g, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
         endif
#endif

!#ifdef OPT
!          if (mypx .eq. 0) then !pm: added
#if defined(OPT_2) || defined(OPT)
         ! if (mypz .eq. 0) print *, 'In plane: ', zplane
          if ( IN_PLANE(xplane,mypx,yplane,mypy,zplane,mypz)) then
            print*, 'rank in plane ', xplane, ' : ', mypx, ' : ', yplane, ' : ', mypy, ' : ', zplane, ' : ', mypz
            print*, 'Leaders: ', myid
#endif
          ! Save timing metadata global attributes
          ! ---------------------------------
          len = 1
          d_time(1) = time
          err = nfmpi_put_att_double(ncid, NF_GLOBAL, 'time', NF_DOUBLE, len, d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_put_att_double for time', err)
          d_time(1) = tstep
          err = nfmpi_put_att_double(ncid, NF_GLOBAL, 'tstep', NF_DOUBLE, len, d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_put_att_double for tstep', err)
          d_time(1) = time_save
          err = nfmpi_put_att_double(ncid, NF_GLOBAL, 'time_save', NF_DOUBLE, len, d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_put_att_double for time_save', err)

          ! global array dimensionality
          g_sizes(1) = nx_g
          g_sizes(2) = ny_g
          g_sizes(3) = nz_g

          ! local subarray dimensionality
#if defined(OPT) || defined(OPT_2)
          if (xplane .eqv. .true.) then
             subsizes(1) = nx_g !pm: added
             subsizes(2) = ny
             subsizes(3) = nz
          else if (yplane .eqv. .true.) then
             subsizes(1) = nx !pm: added
             subsizes(2) = ny_g
             subsizes(3) = nz
          else
             subsizes(1) = nx !pm: added
             subsizes(2) = ny
             subsizes(3) = nz_g
          endif
#else
          subsizes(1) = nx      !pm: commented
          subsizes(2) = ny
          subsizes(3) = nz
#endif

          ! start offsets of local array in global array
          ! note that Fortran array index starts with 1
          starts(1) = nx * mypx + 1
          starts(2) = ny * mypy + 1
          starts(3) = nz * mypz + 1
          starts(4) = 1

          ! define X-Y-Z dimensions of the global array
          err = nfmpi_def_dim(ncid, 'x',   g_sizes(1), dimids(1))
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_dim on x', err)
          err = nfmpi_def_dim(ncid, 'y',   g_sizes(2), dimids(2))
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_dim on y', err)
          err = nfmpi_def_dim(ncid, 'z',   g_sizes(3), dimids(3))
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_dim on z', err)

          ! define 4th dimension and variable yspecies
          g_sizes(4) = nsc + 1
          err = nfmpi_def_dim(ncid, 'nsc', g_sizes(4), dimids(4))
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_dim on nsc', err)
          err = nfmpi_def_var(ncid, 'yspecies', NF_DOUBLE, 4, dimids, yspecies_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_var on yspecies', err)

          ! define 4th dimension and variable u
          g_sizes(4) = 3
          err = nfmpi_def_dim(ncid, 'three', g_sizes(4), dimids(4))
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_dim on three', err)
          err = nfmpi_def_var(ncid, 'u', NF_DOUBLE, 4, dimids, u_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_var on u', err)

          ! define variable pressure
          err = nfmpi_def_var(ncid, 'pressure', NF_DOUBLE, 3, dimids, pressure_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_var on pressure', err)

          ! define variable temp
          err = nfmpi_def_var(ncid, 'temp', NF_DOUBLE, 3, dimids, temp_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_def_var on temp', err)

          ! end of define mode
          err = nfmpi_enddef(ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_enddef', err)


          if (method .EQ. 1) then  ! using nonblocking APIs
              !---- write array yspecies
              subsizes(4) = nsc + 1
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_iput_vara_double(ncid, yspecies_id, starts, subsizes, yspecies_g, req(1))
#else
              err = nfmpi_iput_vara_double(ncid, yspecies_id, starts, subsizes, yspecies, req(1))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iput_vara_double on yspecies', err)

              !---- write array u
              subsizes(4) = 3
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_iput_vara_double(ncid, u_id, starts, subsizes, u_g, req(2))
#else
              err = nfmpi_iput_vara_double(ncid, u_id, starts, subsizes, u, req(2))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iput_vara_double on u', err)

              !---- write array pressure
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_iput_vara_double(ncid, pressure_id, starts, subsizes, pressure_g, req(3))
#else
              err = nfmpi_iput_vara_double(ncid, pressure_id, starts, subsizes, pressure, req(3))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iput_vara_double on pressure', err)

              !---- write array temp
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_iput_vara_double(ncid, temp_id, starts, subsizes, temp_g, req(4))
#else
              err = nfmpi_iput_vara_double(ncid, temp_id, starts, subsizes, temp, req(4))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iput_vara_double on temp', err)

              err = nfmpi_wait_all(ncid, 4, req, st)
              if (err .ne. NF_NOERR) call handle_err('nfmpi_wait_all', err)

          else ! using blocking APIs
              !---- write array yspecies
              subsizes(4) = nsc + 1
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_put_vara_double_all(ncid, yspecies_id, starts, subsizes, yspecies_g)
#else
              err = nfmpi_put_vara_double_all(ncid, yspecies_id, starts, subsizes, yspecies)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_put_vara_double_all on yspecies', err)

              !---- write array u
              subsizes(4) = 3
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_put_vara_double_all(ncid, u_id, starts, subsizes, u_g)
#else
              err = nfmpi_put_vara_double_all(ncid, u_id, starts, subsizes, u)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_put_vara_double_all on u', err)

              !---- write array pressure
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_put_vara_double_all(ncid, pressure_id, starts, subsizes, pressure_g)
#else
              err = nfmpi_put_vara_double_all(ncid, pressure_id, starts, subsizes, pressure)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_put_vara_double_all on pressure', err)

              !---- write array temp
#if defined(OPT) ||  defined(OPT_2)
              err = nfmpi_put_vara_double_all(ncid, temp_id, starts, subsizes, temp_g)
#else
              err = nfmpi_put_vara_double_all(ncid, temp_id, starts, subsizes, temp)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_put_vara_double_all on temp', err)


          endif

          err = nfmpi_inq_put_size(ncid, put_size)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_put_size', err)

          write_amount = write_amount + put_size
          write_num    = write_num + 4

          time_end = MPI_Wtime()
          writeT = writeT + time_end - time_start

          err = nfmpi_close(ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_close', err)

          closeWT = closeWT + MPI_Wtime() - time_end	!just for write
          closeT = closeT + MPI_Wtime() - time_end

#if defined(OPT) || defined(OPT_2) 
		endif
#endif


      end subroutine pnetcdf_write

      !----< pnetcdf_read() >-------------------------------------------
      subroutine pnetcdf_read(filename)
          use topology_m,  only : gcomm, npes, mypx, mypy, mypz, myid
#if defined(OPT) || defined(OPT_2)
				  use topology_m,  only : gcomm_x, gcomm_yz, gcomm_yz_0, gcomm_node, mycore
          use topology_m,  only : gcomm_xy, gcomm_xz
          use topology_m,  only : gcomm_y, gcomm_z, gcomm_xz_0, gcomm_xy_0
          use variables_m, only : temp_g, pressure_g, yspecies_g, u_g
          use variables_m, only : xplane, yplane, zplane
#ifdef V2
          use param_m,     only : n_core0 
          use variables_m, only : temp_0, pressure_0, yspecies_0, u_0
#endif
#endif
          use param_m,     only : nx, ny, nz, nx_g, ny_g, nz_g, nsc
          use variables_m, only : temp, pressure, yspecies, u
          use runtime_m,   only : method, time, tstep, time_save

          implicit none

          ! declarations passed in
          character*(*), intent(in) :: filename

          ! local variables
          integer err, cmode, req(4), st(4)
          integer ncid, yspecies_id, u_id, pressure_id, temp_id
          integer(MPI_OFFSET_KIND) g_sizes(4), subsizes(4), starts(4),get_size
          double precision time_start, time_end, d_time(1)

          ! open file and pass in the MPI hint
          time_start = MPI_Wtime()

          cmode = NF_NOWRITE
					get_size = 0

          print*, 'in read ' , myid  

#ifdef OPT
		  if (mypx .eq. 0) then !pm: added
          err = nfmpi_open(gcomm_x, trim(filename), cmode, file_info, ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_open', err)
      endif
#elif OPT_2
       if (xplane .and. (mypx .eq. 0) ) then
          err = nfmpi_open(gcomm_x, trim(filename), cmode, file_info, ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_open', err)
           print*, 'xplane process ' , myid  
       elseif (yplane .and. (mypy .eq. 0)) then
          err = nfmpi_open(gcomm_y, trim(filename), cmode, file_info, ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_open', err)
            print*, 'yplane process ' , myid  
       else if (zplane .and. (mypz .eq. 0)) then
          err = nfmpi_open(gcomm_z, trim(filename), cmode, file_info, ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_open', err)
            print*, 'zplane process ' , myid  
      endif
#else 
          err = nfmpi_open(gcomm, trim(filename), cmode, file_info, ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_open', err)
#endif


          time_end = MPI_Wtime()
          openT = openT + time_end - time_start
					openRT = time_end - time_start
          time_start = time_end

#ifdef OPT
		  if (mypx .eq. 0) then !pm: added
#elif OPT_2
      if ( IN_PLANE(xplane,mypx,yplane,mypy,zplane,mypz)) then
          print*, 'A leader for the smallest plane ', myid
#endif 
          ! Get timing metadata global attributes
          ! ---------------------------------
          d_time(1) = time
          err = nfmpi_get_att_double(ncid, NF_GLOBAL, 'time', d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_get_att_double for time', err)
          d_time(1) = tstep
          err = nfmpi_get_att_double(ncid, NF_GLOBAL, 'tstep', d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_get_att_double for tstep', err)
          d_time(1) = time_save
          err = nfmpi_get_att_double(ncid, NF_GLOBAL, 'time_save', d_time)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_get_att_double for time_save', err)

          ! global array dimensionality
          g_sizes(1) = nx_g
          g_sizes(2) = ny_g
          g_sizes(3) = nz_g

          ! local subarray dimensionality
#ifdef OPT
          subsizes(1) = nx_g
          subsizes(2) = ny
          subsizes(3) = nz
#elif OPT_2
          if (xplane .eqv. .true.) then
             subsizes(1) = nx_g !pm: added
             subsizes(2) = ny
             subsizes(3) = nz
          else if (yplane .eqv. .true.) then
             subsizes(1) = nx !pm: added
             subsizes(2) = ny_g
             subsizes(3) = nz
          else
             subsizes(1) = nx !pm: added
             subsizes(2) = ny
             subsizes(3) = nz_g
          endif
#else
          subsizes(1) = nx  !pm: commented
          subsizes(2) = ny
          subsizes(3) = nz
#endif

          ! start offsets of local array in global array
          ! note that Fortran array index starts with 1
          starts(1) = nx * mypx + 1
          starts(2) = ny * mypy + 1
          starts(3) = nz * mypz + 1
          starts(4) = 1

          ! inquire variable yspecies id
          err = nfmpi_inq_varid(ncid, 'yspecies', yspecies_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_varid on yspecies', err)

          ! inquire variable u id
          err = nfmpi_inq_varid(ncid, 'u',        u_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_varid on u', err)

          ! inquire variable pressure id
          err = nfmpi_inq_varid(ncid, 'pressure', pressure_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_varid on pressure', err)

          ! inquire variable temp id
          err = nfmpi_inq_varid(ncid, 'temp',     temp_id)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_varid on temp', err)

#ifdef OPT
		!  if (myid .eq. 0) then
	!		print*, 'OPT: starts: myid = ', myid, ' ', starts(1), ' ', subsizes(1)
	!		print*, 'OPT: starts: myid = ', myid, ' ', starts(2), ' ', subsizes(2)
	!		print*, 'OPT: starts: myid = ', myid, ' ', starts(3), ' ', subsizes(3)
	!		print*, 'OPT: starts: myid = ', myid, ' ', starts(4), ' ', subsizes(4)
		!  endif
#endif

          if (method .EQ. 1) then  ! using nonblocking APIs
              !---- read array yspecies
              subsizes(4) = nsc + 1
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_iget_vara_double(ncid, yspecies_id, starts, subsizes, yspecies_g, req(1))
#else
              err = nfmpi_iget_vara_double(ncid, yspecies_id, starts, subsizes, yspecies, req(1))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iget_vara_double on yspecies', err)

              !---- read array u
              subsizes(4) = 3
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_iget_vara_double(ncid, u_id, starts, subsizes, u_g, req(2))
#else
              err = nfmpi_iget_vara_double(ncid, u_id, starts, subsizes, u, req(2))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iget_vara_double on u', err)

              !---- read array pressure
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_iget_vara_double(ncid, pressure_id, starts, subsizes, pressure_g, req(3))
#else
              err = nfmpi_iget_vara_double(ncid, pressure_id, starts, subsizes, pressure, req(3))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iget_vara_double on pressure', err)

              !---- read array temp
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_iget_vara_double(ncid, temp_id, starts, subsizes, temp_g, req(4))
#else
              err = nfmpi_iget_vara_double(ncid, temp_id, starts, subsizes, temp, req(4))
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_iget_vara_double on temp', err)

              err = nfmpi_wait_all(ncid, 4, req, st)
              if (err .ne. NF_NOERR) call handle_err('nfmpi_wait_all', err)
          else ! using blocking APIs
              !---- read array yspecies
              subsizes(4) = nsc + 1
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_get_vara_double_all(ncid, yspecies_id, starts, subsizes, yspecies_g)
#else
              err = nfmpi_get_vara_double_all(ncid, yspecies_id, starts, subsizes, yspecies)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_get_vara_double_all on yspecies', err)

              !---- read array u
              subsizes(4) = 3
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_get_vara_double_all(ncid, u_id, starts, subsizes, u_g)
#else
              err = nfmpi_get_vara_double_all(ncid, u_id, starts, subsizes, u)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_get_vara_double_all on u', err)

              !---- read array pressure
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_get_vara_double_all(ncid, pressure_id, starts, subsizes, pressure_g)
#else
              err = nfmpi_get_vara_double_all(ncid, pressure_id, starts, subsizes, pressure)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_get_vara_double_all on pressure', err)

              !---- read array temp
#if defined(OPT) || defined(OPT_2)
              err = nfmpi_get_vara_double_all(ncid, temp_id, starts, subsizes, temp_g)
#else
              err = nfmpi_get_vara_double_all(ncid, temp_id, starts, subsizes, temp)
#endif
              if (err .ne. NF_NOERR) call handle_err('nfmpi_get_vara_double_all on temp', err)

          endif

          err = nfmpi_inq_get_size(ncid, get_size)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_inq_get_size', err)
          
          read_amount = read_amount + get_size
          read_num    = read_num + 4

          time_end = MPI_Wtime()
          readT = readT + time_end - time_start

          err = nfmpi_close(ncid)
          if (err .ne. NF_NOERR) call handle_err('nfmpi_close', err)

          closeRT = MPI_Wtime() - time_end !just for read
          closeT = closeT + MPI_Wtime() - time_end
#if defined(OPT) || defined(OPT_2)
      endif
#endif


      call MPI_Barrier(gcomm, err)

      time_start = MPI_Wtime()

#if defined(OPT) || defined(OPT_2)
      !scatter
      if (xplane .eqv. .true.) then
        call MPI_Scatter (yspecies_g, nx, MPI_DOUBLE_PRECISION, yspecies, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
        call MPI_Scatter (u_g, nx, MPI_DOUBLE_PRECISION, u, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
        call MPI_Scatter (pressure_g, nx, MPI_DOUBLE_PRECISION, pressure, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
        call MPI_Scatter (temp_g, nx, MPI_DOUBLE_PRECISION, temp, nx, MPI_DOUBLE_PRECISION, 0, gcomm_yz, err)
      else if (yplane .eqv. .true. ) then  
        call MPI_Scatter (yspecies_g, ny, MPI_DOUBLE_PRECISION, yspecies, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
        call MPI_Scatter (u_g, ny, MPI_DOUBLE_PRECISION, u, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
        call MPI_Scatter (pressure_g, ny, MPI_DOUBLE_PRECISION, pressure, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
        call MPI_Scatter (temp_g, ny, MPI_DOUBLE_PRECISION, temp, ny, MPI_DOUBLE_PRECISION, 0, gcomm_xz, err)
      else  
        call MPI_Scatter (yspecies_g, nz, MPI_DOUBLE_PRECISION, yspecies, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
        call MPI_Scatter (u_g, nz, MPI_DOUBLE_PRECISION, u, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
        call MPI_Scatter (pressure_g, nz, MPI_DOUBLE_PRECISION, pressure, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
        call MPI_Scatter (temp_g, nz, MPI_DOUBLE_PRECISION, temp, nz, MPI_DOUBLE_PRECISION, 0, gcomm_xy, err)
      endif
#ifdef V2
		  if (mycore .eq. 0) then     		
		
			call MPI_Scatter (yspecies_g, nx_g/n_core0, MPI_DOUBLE_PRECISION, yspecies_0, nx_g/n_core0, MPI_DOUBLE_PRECISION, 0, gcomm_yz_0, err)
			call MPI_Scatter (u_g, nx_g/n_core0, MPI_DOUBLE_PRECISION, u_0, nx_g/n_core0, MPI_DOUBLE_PRECISION, 0, gcomm_yz_0, err)
			call MPI_Scatter (pressure_g, nx_g/n_core0, MPI_DOUBLE_PRECISION, pressure_0, nx_g/n_core0, MPI_DOUBLE_PRECISION, 0, gcomm_yz_0, err)
			call MPI_Scatter (temp_g, nx_g/n_core0, MPI_DOUBLE_PRECISION, temp_0, nx_g/n_core0, MPI_DOUBLE_PRECISION, 0, gcomm_yz_0, err)
		
		  endif

      call MPI_Scatter (yspecies_0, nx, MPI_DOUBLE_PRECISION, yspecies, nx, MPI_DOUBLE_PRECISION, 0, gcomm_node, err)
			call MPI_Scatter (u_0, nx, MPI_DOUBLE_PRECISION, u, nx, MPI_DOUBLE_PRECISION, 0, gcomm_node, err)
			call MPI_Scatter (pressure_0, nx, MPI_DOUBLE_PRECISION, pressure, nx, MPI_DOUBLE_PRECISION, 0, gcomm_node, err)
			call MPI_Scatter (temp_0, nx, MPI_DOUBLE_PRECISION, temp, nx, MPI_DOUBLE_PRECISION, 0, gcomm_node, err)

#endif
      time_end = MPI_Wtime()
      scatterT = (time_end - time_start) * 1000.0	!ms
#endif

      end subroutine pnetcdf_read

      end module pnetcdf_m

