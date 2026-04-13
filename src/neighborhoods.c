/*  Heuristic Optimization assignment, 2026.
    Neighborhood structures for the Linear Ordering Problem.
    All delta functions use incremental evaluation (no full recomputation).
*/

#include <stdlib.h>
#include "neighborhoods.h"
#include "instance.h"

/* ══════════════════════════════════════════════════════════════════════
   DELTA FUNCTIONS
   ══════════════════════════════════════════════════════════════════════ */

/* Transpose: swap adjacent elements at positions i and i+1.
   Only the pair (s[i], s[i+1]) changes order in the objective sum.
   delta = C[s[i+1]][s[i]] - C[s[i]][s[i+1]]                         */
long long int deltaTranspose(long int *s, int i) {
    return (long long int)CostMat[s[i+1]][s[i]]
         - (long long int)CostMat[s[i]][s[i+1]];
}

/* Exchange: swap elements at positions i and j (i < j).
   Three types of pairs are affected:
   - The direct pair (s[i], s[j])
   - Each element s[k] between i and j paired with s[i] (now s[j] takes that slot)
   - Each element s[k] between i and j paired with s[j] (now s[i] takes that slot) */
long long int deltaExchange(long int *s, int i, int j) {
    long long int delta = 0;
    int k;

    /* Direct pair contribution */
    delta += (long long int)CostMat[s[j]][s[i]]
           - (long long int)CostMat[s[i]][s[j]];

    /* Elements strictly between i and j */
    for (k = i + 1; k < j; k++) {
        delta += (long long int)CostMat[s[j]][s[k]]
               - (long long int)CostMat[s[i]][s[k]];
        delta += (long long int)CostMat[s[k]][s[i]]
               - (long long int)CostMat[s[k]][s[j]];
    }

    return delta;
}

/* Insert: remove element at position i and reinsert it at position j.
   Case j > i: s[i] moves right — for each k in [i+1, j], s[k] now
               comes before s[i] instead of after it.
   Case j < i: s[i] moves left  — for each k in [j, i-1], s[i] now
               comes before s[k] instead of after it.               */
long long int deltaInsert(long int *s, int i, int j) {
    long long int delta = 0;
    int k;

    if (i == j) return 0;

    if (j > i) {
        /* s[i] shifts right: each s[k] in (i+1..j) overtakes s[i] */
        for (k = i + 1; k <= j; k++)
            delta += (long long int)CostMat[s[k]][s[i]]
                   - (long long int)CostMat[s[i]][s[k]];
    } else {
        /* s[i] shifts left: s[i] overtakes each s[k] in (j..i-1) */
        for (k = j; k < i; k++)
            delta += (long long int)CostMat[s[i]][s[k]]
                   - (long long int)CostMat[s[k]][s[i]];
    }

    return delta;
}

/* ══════════════════════════════════════════════════════════════════════
   MOVE APPLICATION
   ══════════════════════════════════════════════════════════════════════ */

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

/* Removes s[i], shifts elements, then inserts at position j */
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

/* ══════════════════════════════════════════════════════════════════════
   ITERATIVE IMPROVEMENT — one neighborhood, until local optimum
   firstImprovement=1 → first-improvement rule
   firstImprovement=0 → best-improvement rule
   ══════════════════════════════════════════════════════════════════════ */

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
                    break; /* restart scan from the beginning */
                }
            } else {
                if (delta > bestDelta) {
                    bestDelta = delta;
                    bestI     = i;
                }
            }
        }

        /* Best-improvement: apply the best move found in full scan */
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
                        break; /* restart */
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
                        break; /* restart */
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

/* ══════════════════════════════════════════════════════════════════════
   DISPATCHER
   ══════════════════════════════════════════════════════════════════════ */

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

/* ══════════════════════════════════════════════════════════════════════
   VND — Variable Neighborhood Descent
   Uses first-improvement at each neighborhood step (as required).
   Restarts from the first neighborhood whenever an improvement is found.
   Stops when no neighborhood yields an improvement.
   ══════════════════════════════════════════════════════════════════════ */

long long int runVND(long int *s, long long int cost, Algorithm alg) {
    /* Neighborhood order: VND1 = T,E,I  |  VND2 = T,I,E */
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

        /* first-improvement (1) at each step, as specified */
        switch (order[k]) {
            case NEIGH_TRANSPOSE: newCost = iterativeImprovementTranspose(s, cost, 1); break;
            case NEIGH_EXCHANGE:  newCost = iterativeImprovementExchange (s, cost, 1); break;
            case NEIGH_INSERT:    newCost = iterativeImprovementInsert   (s, cost, 1); break;
            default: newCost = cost; break;
        }

        if (newCost > cost) {
            cost = newCost;
            k = 0; /* improvement found: restart from first neighborhood */
        } else {
            k++; /* no improvement: try next neighborhood */
        }
    }

    return cost;
}
