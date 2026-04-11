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

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#include "instance.h"
#include "utilities.h"
#include "timer.h"
#include "optimization.h"
#include "neighborhoods.h"

char *FileName;

/* Enums are defined in optimization.h and shared across all files */
PivotRule    pivotRule    = PIVOT_NONE;
Neighborhood neighborhood = NEIGH_NONE;
InitMethod   initMethod   = INIT_NONE;
Algorithm    algorithm    = ALG_II;

void usage(const char *prog) {
  fprintf(stderr,
    "Usage: %s -i <instance_file> [OPTIONS]\n"
    "  Pivoting : --first | --best\n"
    "  Neighborhood: --transpose | --exchange | --insert\n"
    "  Init     : --random | --cw\n"
    "  VND      : --vnd1 (T->E->I) | --vnd2 (T->I->E)  (replaces pivot+neigh)\n"
    "Examples:\n"
    "  %s -i instances/N-be75eec_150 --first --transpose --random\n"
    "  %s -i instances/N-be75eec_150 --vnd1 --cw\n",
    prog, prog, prog);
  exit(1);
}

void readOpts(int argc, char **argv) {
  /* Long options added on top of the original -i short option */
  static struct option long_opts[] = {
    { "first",     no_argument, NULL, 1 },
    { "best",      no_argument, NULL, 2 },
    { "transpose", no_argument, NULL, 3 },
    { "exchange",  no_argument, NULL, 4 },
    { "insert",    no_argument, NULL, 5 },
    { "random",    no_argument, NULL, 6 },
    { "cw",        no_argument, NULL, 7 },
    { "vnd1",      no_argument, NULL, 8 },
    { "vnd2",      no_argument, NULL, 9 },
    { NULL, 0, NULL, 0 }
  };

  int opt, idx;
  FileName = NULL;

  while ( (opt = getopt_long(argc, argv, "i:", long_opts, &idx)) != -1 )
    switch (opt) {
      case 'i': /* Instance file */
          FileName = (char *)malloc(strlen(optarg)+1);
          strncpy(FileName, optarg, strlen(optarg));
          break;
      case 1: pivotRule    = PIVOT_FIRST;     break;
      case 2: pivotRule    = PIVOT_BEST;      break;
      case 3: neighborhood = NEIGH_TRANSPOSE; break;
      case 4: neighborhood = NEIGH_EXCHANGE;  break;
      case 5: neighborhood = NEIGH_INSERT;    break;
      case 6: initMethod   = INIT_RANDOM;     break;
      case 7: initMethod   = INIT_CW;         break;
      case 8: algorithm    = ALG_VND1;        break;
      case 9: algorithm    = ALG_VND2;        break;
      default:
          fprintf(stderr, "Option not managed.\n");
          usage(argv[0]);
    }

  /* Validate required arguments */
  if ( !FileName ) {
    printf("No instance file provided (use -i <instance_name>). Exiting.\n");
    exit(1);
  }
  if ( initMethod == INIT_NONE ) {
    fprintf(stderr, "Error: initial solution required (--random or --cw).\n");
    usage(argv[0]);
  }
  if ( algorithm == ALG_II ) {
    if ( pivotRule == PIVOT_NONE ) {
      fprintf(stderr, "Error: pivoting rule required (--first or --best).\n");
      usage(argv[0]);
    }
    if ( neighborhood == NEIGH_NONE ) {
      fprintf(stderr, "Error: neighborhood required (--transpose, --exchange or --insert).\n");
      usage(argv[0]);
    }
  }
}

void printConfig() {
  printf("=== Configuration ===\n");
  if (algorithm == ALG_VND1)
    printf("Algorithm  : VND  (transpose -> exchange -> insert)\n");
  else if (algorithm == ALG_VND2)
    printf("Algorithm  : VND  (transpose -> insert -> exchange)\n");
  else {
    printf("Algorithm  : Iterative Improvement\n");
    printf("Pivoting   : %s\n", pivotRule == PIVOT_FIRST ? "first-improvement" : "best-improvement");
    printf("Neighborhood: %s\n",
           neighborhood == NEIGH_TRANSPOSE ? "transpose" :
           neighborhood == NEIGH_EXCHANGE  ? "exchange"  : "insert");
  }
  printf("Init       : %s\n", initMethod == INIT_RANDOM ? "random" : "CW heuristic");
  printf("=====================\n\n");
}



int main (int argc, char **argv)
{
  long int i,j;
  long int *currentSolution;
  long long int cost, finalCost;

  /* Do not buffer output */
  setbuf(stdout,NULL);
  setbuf(stderr,NULL);

  if (argc < 2) {
    printf("No instance file provided (use -i <instance_name>). Exiting.\n");
    exit(1);
  }

  /* Read parameters */
  readOpts(argc, argv);

  /* Print chosen configuration */
  printConfig();

  /* Read instance file */
  CostMat = readInstance(FileName);
  printf("Data have been read from instance file. Size of instance = %ld.\n\n", PSize);

  /* initialize random number generator, deterministically based on instance.
   * To do this we simply set the seed to the sum of elements in the matrix, so it is constant per-instance,
   but (most likely) varies between instances */
  Seed = (long int) 0;
    for (i=0; i < PSize; ++i)
      for (j=0; j < PSize; ++j)
        Seed += (long int) CostMat[i][j];
  printf("Seed used to initialize RNG: %ld.\n\n", Seed);

  /* starts time measurement */
  start_timers();

  /* A solution is just a vector of int with the same size as the instance */
  currentSolution = (long int *)malloc(PSize * sizeof(long int));

  /* Create an initial solution depending on chosen method */
  if (initMethod == INIT_RANDOM)
    createRandomSolution(currentSolution);
  else
    createCWSolution(currentSolution);

  /* Compute cost of initial solution and print it */
  cost = computeCost(currentSolution);
  printf("Initial cost: %lld\n", cost);

  /* Run the chosen algorithm (II or VND) */
  if (algorithm == ALG_VND1 || algorithm == ALG_VND2)
    finalCost = runVND(currentSolution, cost, algorithm);
  else
    finalCost = runIterativeImprovement(currentSolution, cost, pivotRule, neighborhood);

  printf("Final cost  : %lld\n", finalCost);
  printf("Time elapsed: %g\n\n", elapsed_time(VIRTUAL));

  free(currentSolution);
  return 0;
}
