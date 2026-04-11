/*  Heuristic Optimization assignment, 2015.
    Adapted by Jérémie Dubois-Lacoste from the ILSLOP implementation
    of Tommaso Schiavinotto:
    ---
    ILSLOP Iterated Local Search Algorithm for Linear Ordering Problem
    Copyright (C) 2004  Tommaso Schiavinotto (tommaso.schiavinotto@gmail.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef _UTILITIES_H_
#define _UTILITIES_H_

#define PREV 0
#define NEXT 1
#define E_START 0
#define E_END 1

long int **createMatrix (long int i);
int rand0N(int limit);

extern void fatal (char *s);

extern double ran01( long *idum );

extern int randInt(int minimum, int maximum);

extern long int * generate_random_vector(long int dim );


/* constants for a pseudo-random number generator, taken from
   Numerical Recipes in C book --- never trust the standard C random
   number generator */
#define IA 16807
#define IM 2147483647
#define AM (1.0/IM)
#define IQ 127773
#define IR 2836

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif


extern long int Seed; /* seed for the random number generator */

#endif
