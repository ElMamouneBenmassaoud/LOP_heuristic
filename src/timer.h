/*****************************************************************************/
/*                                                                           */
/*      Version:  2.00   Date: 01/01/2009   File: timer.h                    */
/* Changes:                                                                  */
/* 30/10/1996 Created   (Thomas Stuetzle)                                    */
/* 01/01/2009 Added windows compatibility (Tommaso Schiavinotto)             */
/*****************************************************************************/
/*                                                                           */
/*===========================================================================*/



/*---------------------------------------------------------------------------*/


#ifndef _TIMER_H_
#define _TIMER_H_

int time_expired();

void start_timers();

double elapsed_time();

typedef enum type_timer {REAL, VIRTUAL} TIMER_TYPE;

#endif
