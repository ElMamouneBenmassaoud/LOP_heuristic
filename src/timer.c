/*****************************************************************************/
/*                                                                           */
/*      Version:  2.00   Date: 01/01/2009   File: timer.c                    */
/* Changes:                                                                  */
/* 30/10/1996 Created   (Thomas Stuetzle)                                    */
/* 01/01/2009 Added windows compatibility (Tommaso Schiavinotto)             */
/*****************************************************************************/
/*                                                                           */
/*===========================================================================*/


/*---------------------------------------------------------------------------*/


#include <stdio.h>
#ifndef __MINGW32__
#include <sys/time.h>
#include <sys/resource.h>
#else
#include <windows.h>
#endif
#include "timer.h"

#ifndef __MINGW32__
static struct rusage res;
static struct timeval tp;
#endif
static double virtual_time, real_time;


/*
 *  The virtual time of day and the real time of day are calculated and
 *  stored for future use.  The future use consists of subtracting these
 *  values from similar values obtained at a later time to allow the user
 *  to get the amount of time used by the backtracking routine.
 */
#ifndef __MINGW32__
void
start_timers()
{
    getrusage( RUSAGE_SELF, &res );
    virtual_time = (double) res.ru_utime.tv_sec +
		   (double) res.ru_stime.tv_sec +
		   (double) res.ru_utime.tv_usec / 1000000.0 +
		   (double) res.ru_stime.tv_usec / 1000000.0;

    gettimeofday( &tp, NULL );
    real_time =    (double) tp.tv_sec +
		   (double) tp.tv_usec / 1000000.0;
}
#else
void
start_timers()
{
       FILETIME creation_time;
       FILETIME exit_time;
       FILETIME kernel_time;
       FILETIME user_time;
       DWORD x = GetTickCount();
       if (!GetProcessTimes(GetCurrentProcess(),
                            &creation_time,
                            &exit_time,
                            &kernel_time,
                            &user_time))
           exit(-1);
       virtual_time =  user_time.dwLowDateTime / 1e7 +kernel_time.dwLowDateTime / 1e7;
       real_time = (double)(x / 1000) + (double)(x % 1000)/1000.0;
}
#endif

/*
 *  Stop the stopwatch and return the time used in seconds (either
 *  REALX or VIRTUAL time, depending on ``type'').
 */
#ifndef __MINGW32__
double
elapsed_time( type )
	TIMER_TYPE type;
{
    if (type == REAL) {
        gettimeofday( &tp, NULL );
        return( (double) tp.tv_sec +
		(double) tp.tv_usec / 1000000.0
		- real_time );
    }
    else {
        getrusage( RUSAGE_SELF, &res );
        return( (double) res.ru_utime.tv_sec +
		(double) res.ru_stime.tv_sec +
		(double) res.ru_utime.tv_usec / 1000000.0 +
		(double) res.ru_stime.tv_usec / 1000000.0
		- virtual_time );
    }
}
#else
double
elapsed_time( type )
	TIMER_TYPE type;
{
       FILETIME creation_time;
       FILETIME exit_time;
       FILETIME kernel_time;
       FILETIME user_time;

       if (!GetProcessTimes(GetCurrentProcess(),
                            &creation_time,
                            &exit_time,
                            &kernel_time,
                            &user_time))
           exit(-1);
       
       double vt = (double)user_time.dwLowDateTime / 1e7 +(double)kernel_time.dwLowDateTime / 1e7-virtual_time;
       if (type == REAL) {
	  DWORD x = GetTickCount();
	  return (double)(x / 1000) + (double)(x % 1000)/1000.0-real_time;
       } else
	  return vt;
}
#endif
