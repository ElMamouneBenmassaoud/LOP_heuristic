Heuristic Optimization — Implementation Exercise 1
INFO-H-413, ULB 2026
====================================================

Iterative Improvement and Variable Neighborhood Descent
algorithms for the Linear Ordering Problem (LOP).


REQUIREMENTS
------------
- GCC (or any C99-compatible compiler)
- Make
- Linux or macOS


COMPILATION
-----------
    make

To remove compiled files:
    make clean


USAGE
-----
    ./lop -i <instance_file> [OPTIONS]

Options:
    Pivoting rule  : --first | --best
    Neighborhood   : --transpose | --exchange | --insert
    Initialization : --random | --cw
    VND            : --vnd1 | --vnd2  (replaces pivot + neighborhood)

For Iterative Improvement (Exercise 1.1), all three options are required.
For VND (Exercise 1.2), only --vnd1 or --vnd2 and an init method are needed.


EXAMPLES
--------
Iterative Improvement:
    ./lop -i instances/N-be75eec_150 --first --transpose --random
    ./lop -i instances/N-be75eec_150 --best  --exchange  --cw
    ./lop -i instances/N-be75eec_150 --first --insert    --random
    ./lop -i instances/N-be75eec_150 --best  --insert    --cw

VND:
    ./lop -i instances/N-be75eec_150 --vnd1 --cw
    ./lop -i instances/N-be75eec_150 --vnd2 --cw

Output format:
    Initial cost: <value>
    Final cost  : <value>
    Time elapsed: <seconds>


INSTANCES
---------
All instances are in the instances/ directory.
Best known solutions are in best_known/best_known.txt.


PROJECT STRUCTURE
-----------------
    src/
        main.c          - Entry point, CLI argument parsing
        optimization.c  - Cost function, CW and random initialization
        optimization.h  - Shared enums and declarations
        neighborhoods.c - Delta functions, move application, II and VND
        neighborhoods.h - Neighborhood declarations
        instance.c/h    - Instance file reader
        utilities.c/h   - Random number generator
        timer.c/h       - CPU time measurement
    instances/          - LOP benchmark instances
    best_known/         - Best known solution values
    results/            - Experimental results and figures
    analysis.R          - R script for statistical analysis


RUNNING ALL EXPERIMENTS
-----------------------
    zsh run_experiments.sh

Output is saved to results/raw_data.txt (tab-separated).


STATISTICAL ANALYSIS
--------------------
Requires R (>= 4.0) with packages: ggplot2, ggrepel, patchwork, scales.

    Rscript analysis.R

Figures are saved to results/figures/.
