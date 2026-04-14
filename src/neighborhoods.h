#ifndef _NEIGHBORHOODS_H_
#define _NEIGHBORHOODS_H_

#include "optimization.h"
#include "instance.h"

long long int deltaTranspose(long int *s, int i);

long long int deltaExchange(long int *s, int i, int j);

long long int deltaInsert(long int *s, int i, int j);

void applyTranspose(long int *s, int i);
void applyExchange(long int *s, int i, int j);
void applyInsert(long int *s, int i, int j);

long long int iterativeImprovementTranspose(long int *s, long long int cost, int firstImprovement);
long long int iterativeImprovementExchange (long int *s, long long int cost, int firstImprovement);
long long int iterativeImprovementInsert   (long int *s, long long int cost, int firstImprovement);

long long int runIterativeImprovement(long int *s, long long int cost,
                                      PivotRule pivot, Neighborhood neigh);

long long int runVND(long int *s, long long int cost, Algorithm alg);

#endif
