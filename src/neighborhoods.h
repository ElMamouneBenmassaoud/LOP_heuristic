/*  Heuristic Optimization assignment, 2026.
    Neighborhood structures for the Linear Ordering Problem:
    Transpose, Exchange, Insert — with incremental delta evaluation.
*/
#ifndef _NEIGHBORHOODS_H_
#define _NEIGHBORHOODS_H_

#include "optimization.h"
#include "instance.h"

/* ── Delta evaluation (incremental — no full recomputation) ─────────
   Each function returns the change in objective value if the move
   were applied. A positive delta means an improving move.          */

/* Swap adjacent elements at positions i and i+1 */
long long int deltaTranspose(long int *s, int i);

/* Swap elements at positions i and j (i < j) */
long long int deltaExchange(long int *s, int i, int j);

/* Remove element at position i and reinsert it at position j */
long long int deltaInsert(long int *s, int i, int j);

/* ── Move application ───────────────────────────────────────────────── */
void applyTranspose(long int *s, int i);
void applyExchange(long int *s, int i, int j);
void applyInsert(long int *s, int i, int j);

/* ── Iterative improvement until local optimum ──────────────────────
   firstImprovement = 1 : first-improvement pivoting rule
   firstImprovement = 0 : best-improvement  pivoting rule
   Returns the cost of the local optimum found.                      */
long long int iterativeImprovementTranspose(long int *s, long long int cost, int firstImprovement);
long long int iterativeImprovementExchange (long int *s, long long int cost, int firstImprovement);
long long int iterativeImprovementInsert   (long int *s, long long int cost, int firstImprovement);

/* ── Dispatcher: runs II with the given pivot rule and neighborhood ── */
long long int runIterativeImprovement(long int *s, long long int cost,
                                      PivotRule pivot, Neighborhood neigh);

/* ── VND: Variable Neighborhood Descent ────────────────────────────
   ALG_VND1: transpose → exchange → insert  (best-improvement at each step)
   ALG_VND2: transpose → insert  → exchange (best-improvement at each step) */
long long int runVND(long int *s, long long int cost, Algorithm alg);

#endif
