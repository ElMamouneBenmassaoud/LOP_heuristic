
#include <stdlib.h>
#include "neighborhoods.h"
#include "instance.h"


/* --- delta functions --- */

/* swap s[i] and s[i+1]: only that pair changes in the objective */
long long int deltaTranspose(long int *s, int i) {
    return (long long int)CostMat[s[i+1]][s[i]]
         - (long long int)CostMat[s[i]][s[i+1]];
}

/* swap s[i] and s[j]: the direct pair + all elements between i and j */
long long int deltaExchange(long int *s, int i, int j) {
    long long int delta = 0;
    int k;

    delta += (long long int)CostMat[s[j]][s[i]]
           - (long long int)CostMat[s[i]][s[j]];

    for (k = i + 1; k < j; k++) {
        delta += (long long int)CostMat[s[j]][s[k]]
               - (long long int)CostMat[s[i]][s[k]];
        delta += (long long int)CostMat[s[k]][s[i]]
               - (long long int)CostMat[s[k]][s[j]];
    }

    return delta;
}

/* remove s[i] and reinsert at j: equivalent to |i-j| adjacent swaps */
long long int deltaInsert(long int *s, int i, int j) {
    long long int delta = 0;
    int k;

    if (i == j) return 0;

    if (j > i) {
        for (k = i + 1; k <= j; k++)
            delta += (long long int)CostMat[s[k]][s[i]]
                   - (long long int)CostMat[s[i]][s[k]];
    } else {
        for (k = j; k < i; k++)
            delta += (long long int)CostMat[s[i]][s[k]]
                   - (long long int)CostMat[s[k]][s[i]];
    }

    return delta;
}


/* --- apply moves --- */

void applyTranspose(long int *s, int i) {
    long int tmp = s[i];
    s[i]   = s[i+1];
    s[i+1] = tmp;
}

void applyExchange(long int *s, int i, int j) {
    long int tmp = s[i];
    s[i] = s[j];
    s[j] = tmp;
}

void applyInsert(long int *s, int i, int j) {
    long int elem = s[i];
    int k;

    if (j > i) {
        for (k = i; k < j; k++)
            s[k] = s[k+1];
    } else {
        for (k = i; k > j; k--)
            s[k] = s[k-1];
    }
    s[j] = elem;
}


/* --- iterative improvement --- */

long long int iterativeImprovementTranspose(long int *s, long long int cost,
                                            int firstImprovement) {
    int i, improved, bestI;
    long long int delta, bestDelta;

    improved = 1;
    while (improved) {
        improved  = 0;
        bestDelta = 0;
        bestI     = -1;

        for (i = 0; i < PSize - 1; i++) {
            delta = deltaTranspose(s, i);
            if (firstImprovement) {
                if (delta > 0) {
                    applyTranspose(s, i);
                    cost    += delta;
                    improved = 1;
                    break;
                }
            } else {
                if (delta > bestDelta) {
                    bestDelta = delta;
                    bestI     = i;
                }
            }
        }

        if (!firstImprovement && bestI >= 0) {
            applyTranspose(s, bestI);
            cost    += bestDelta;
            improved = 1;
        }
    }

    return cost;
}

long long int iterativeImprovementExchange(long int *s, long long int cost,
                                           int firstImprovement) {
    int i, j, improved, bestI, bestJ;
    long long int delta, bestDelta;

    improved = 1;
    while (improved) {
        improved  = 0;
        bestDelta = 0;
        bestI = bestJ = -1;

        for (i = 0; i < PSize - 1 && !improved; i++) {
            for (j = i + 1; j < PSize; j++) {
                delta = deltaExchange(s, i, j);
                if (firstImprovement) {
                    if (delta > 0) {
                        applyExchange(s, i, j);
                        cost    += delta;
                        improved = 1;
                        break;
                    }
                } else {
                    if (delta > bestDelta) {
                        bestDelta = delta;
                        bestI = i;
                        bestJ = j;
                    }
                }
            }
        }

        if (!firstImprovement && bestI >= 0) {
            applyExchange(s, bestI, bestJ);
            cost    += bestDelta;
            improved = 1;
        }
    }

    return cost;
}

long long int iterativeImprovementInsert(long int *s, long long int cost,
                                         int firstImprovement) {
    int i, j, improved, bestI, bestJ;
    long long int delta, bestDelta;

    improved = 1;
    while (improved) {
        improved  = 0;
        bestDelta = 0;
        bestI = bestJ = -1;

        for (i = 0; i < PSize && !improved; i++) {
            for (j = 0; j < PSize; j++) {
                if (i == j) continue;
                delta = deltaInsert(s, i, j);
                if (firstImprovement) {
                    if (delta > 0) {
                        applyInsert(s, i, j);
                        cost    += delta;
                        improved = 1;
                        break;
                    }
                } else {
                    if (delta > bestDelta) {
                        bestDelta = delta;
                        bestI = i;
                        bestJ = j;
                    }
                }
            }
        }

        if (!firstImprovement && bestI >= 0) {
            applyInsert(s, bestI, bestJ);
            cost    += bestDelta;
            improved = 1;
        }
    }

    return cost;
}

long long int runIterativeImprovement(long int *s, long long int cost,
                                      PivotRule pivot, Neighborhood neigh) {
    int fi = (pivot == PIVOT_FIRST);

    switch (neigh) {
        case NEIGH_TRANSPOSE: return iterativeImprovementTranspose(s, cost, fi);
        case NEIGH_EXCHANGE:  return iterativeImprovementExchange (s, cost, fi);
        case NEIGH_INSERT:    return iterativeImprovementInsert   (s, cost, fi);
        default:              return cost;
    }
}


/* --- VND --- */

long long int runVND(long int *s, long long int cost, Algorithm alg) {
    Neighborhood order[3];

    if (alg == ALG_VND1) {
        order[0] = NEIGH_TRANSPOSE;
        order[1] = NEIGH_EXCHANGE;
        order[2] = NEIGH_INSERT;
    } else {
        order[0] = NEIGH_TRANSPOSE;
        order[1] = NEIGH_INSERT;
        order[2] = NEIGH_EXCHANGE;
    }

    int k = 0;
    while (k < 3) {
        long long int newCost;

        switch (order[k]) {
            case NEIGH_TRANSPOSE: newCost = iterativeImprovementTranspose(s, cost, 1); break;
            case NEIGH_EXCHANGE:  newCost = iterativeImprovementExchange (s, cost, 1); break;
            case NEIGH_INSERT:    newCost = iterativeImprovementInsert   (s, cost, 1); break;
            default: newCost = cost; break;
        }

        if (newCost > cost) {
            cost = newCost;
            k = 0;
        } else {
            k++;
        }
    }

    return cost;
}
