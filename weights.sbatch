#!/bin/bash

#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16

# --ntasks-per-node will be used in doParallel.R to specify the number
# of cores to use on the machine. Using 16 will allow us to use all
# cores on a sandyb node
module load R

R CMD BATCH --no-save --no-restore convergence.R
