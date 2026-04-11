/*  Heuristic Optimization assignment, 2015.
    Adapted by Jérémie Dubois-Lacoste from the ILSLOP implementation
    of Tommaso Schiavinotto:
    ---
    ILSLOP Iterated Lcaol Search Algorithm for Linear Ordering Problem
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

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <limits.h>

#include "optimization.h"
#include "instance.h"
#include "utilities.h"

#define MAX_FLOAT FLT_MAX


long int **CostMat;


long long int computeCost (long int *s ) {
    int h,k;
    long long int sum;
    
    /* Diagonal value are not considered */
    for (sum = 0, h = 0; h < PSize; h++ ) 
	for ( k = h + 1; k < PSize; k++ )
	    sum += CostMat[s[h]][s[k]];
    return(sum);
}


void createRandomSolution(long int *s) {
    int j;
    long int *random;

    random = generate_random_vector(PSize);
    for ( j = 0 ; j < PSize ; j++ ) {
      s[j] = random[j];
    }
    free ( random );
}


/* Chenery-Watanabe (CW) heuristic.
   Greedy construction: at each step, pick the unplaced row i that maximizes
   the sum of CostMat[i][j] over all other unplaced rows j.
   That row is the most "attractive" to place next (it contributes most to
   the objective if placed before all remaining rows). */
void createCWSolution(long int *s) {
    int i, j, step, best;
    long long int score, bestScore;
    int *placed = (int *)calloc(PSize, sizeof(int)); /* 0 = not yet placed */

    for (step = 0; step < PSize; step++) {
        best      = -1;      
        bestScore = LLONG_MIN; 

        /* Find the unplaced row with the highest attractiveness */
        for (i = 0; i < PSize; i++) {
            if (placed[i]) continue;

            score = 0;
            for (j = 0; j < PSize; j++) {
                if (!placed[j] && j != i)
                    score += CostMat[i][j];
            }

            if (score > bestScore) {
                bestScore = score;
                best      = i;
            }
        }

        s[step]      = best;
        placed[best] = 1;
    }

    free(placed);
}

