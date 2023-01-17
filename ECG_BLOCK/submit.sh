#!/bin/bash
#SBATCH --partition=c2_cpu
#SBATCH --job-name=ECG_block       # create a short name for your job
#SBATCH -o  /media/cephfs/labs/jbodurka/Obada/Projects/Capsule/scritps/ECG_BLOCK/ECG_BLOCK_out.txt       # create a short name for your job
#SBATCH -e  /media/cephfs/labs/jbodurka/Obada/Projects/Capsule/scritps/ECG_BLOCK/ECG_BLOCK_err.txt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH -q c2_cpu
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=32G         # memory per cpu-core (4G per cpu-core is default)


module load matlab/2019a
cd /media/cephfs/labs/jbodurka/Obada/Projects/Capsule/scritps/ECG_BLOCK/
matlab -singleCompThread -nodisplay -nosplash -r runMe_HR_Eniter_Block