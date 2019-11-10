#!/bin/bash
#SBATCH --nodes 1 --ntasks 4 --mem 16G --time 36:00:00 --out logs/busco.%a.log -J busco

module load busco

# for augustus training
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
# set to a local dir to avoid permission issues and pollution in global
export AUGUSTUS_CONFIG_PATH=$(realpath augustus/3.3/config)

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
if [ -z ${SLURM_ARRAY_JOB_ID} ]; then
	SLURM_ARRAY_JOB_ID=$$
fi
GENOMEFOLDER=genomes
EXT=sorted.fasta
LINEAGE=/srv/projects/db/BUSCO/v9/fungi_odb9
OUTFOLDER=BUSCO
TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p $TEMP
SAMPLEFILE=samples.dat
NAME=$(sed -n ${N}p $SAMPLEFILE | cut -f1)
PHYLUM=$(sed -n ${N}p $SAMPLEFILE | cut -f2)
SubPhyla=$(sed -n ${N}p $SAMPLEFILE | cut -f3)
SEED_SPECIES=rhizopus_oryzae
if [[ $SubPhyla == "Mucoromycotina" ]]; then
	SEED_SPECIES="mucor_circinelloides_f._lusitanicus__nrrl_3629"
elif [[ $SubPhyla == "Mortirellomycotina" ]]; then
	SEED_SPECIES="Mortierella_verticillata_CRF"
elif [[ $SubPhyla == "Entomophthoromycotina" ]]; then
	SEED_SPECIES="Conidiobolus_coronatus"
elif [[ $SubPhyla == "Kickxellomycotina" ]]; then
	SEED_SPECIES="coemansia_umbellata__bcrc_34882"
fi
GENOMEFILE=$(realpath $GENOMEFOLDER/${NAME}.${EXT})
LINEAGE=$(realpath $LINEAGE)

if [ -d "$OUTFOLDER/run_${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
    pushd $OUTFOLDER
    run_BUSCO.py -i $GENOMEFILE -l $LINEAGE -o $NAME -m geno --cpu $CPU --tmp $TEMP --long -sp $SEED_SPECIES
    popd
fi

rm -rf $TEMP
