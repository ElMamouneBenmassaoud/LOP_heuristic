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
#ifndef _LO_H_
#define _LO_H_

/* ── Algorithm configuration enums (shared across all files) ───────── */
typedef enum { PIVOT_NONE,  PIVOT_FIRST, PIVOT_BEST }                      PivotRule;
typedef enum { NEIGH_NONE,  NEIGH_TRANSPOSE, NEIGH_EXCHANGE, NEIGH_INSERT } Neighborhood;
typedef enum { INIT_NONE,   INIT_RANDOM, INIT_CW }                         InitMethod;
typedef enum { ALG_II,      ALG_VND1,    ALG_VND2 }                        Algorithm;

extern long int **CostMat;

long long int computeCost ( long int *lo );
void createRandomSolution(long int *s);
void createCWSolution(long int *s);

#endif
