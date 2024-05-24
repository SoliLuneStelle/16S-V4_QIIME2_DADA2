#!/bin/sh
# 
##SBATCH --job-name=QIIME2_paired
#SBATCH --time=24:00:00
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=1
#SBATCH --partition=parallel
#SBATCH --mem-per-cpu=20G
#SBATCH --nodes=1
#SBATCH --mail-type=end 
#SBATCH --mail-user=jdodd7@jhu.edu

module load qiime2/2023.5.1

#copy emp_paired_end_script.config.txt to analysis folder
#edit variables of config file according to analysis
#save them and this script will use those variables in this analysis
source ./emp_paired_end_script.config

#echo the time for each
echo "Starting qiime2 analysis"
date

#import the demultiplexed data 
echo "Starting qiime2 tools import"
date

# inputing fastq files from emp-paired-end-sequences directory
qiime tools import \
 --type EMPPairedEndSequences \
 --input-path $DATA \
 --output-path ${PREFIX}.qza

#demultiplexing data
echo "Starting demux"
date
qiime demux emp-paired \
 --i-seqs ${PREFIX}.qza \
 --m-barcodes-file $METADATA \
 --m-barcodes-column BarcodeSequence \
 --p-rev-comp-mapping-barcodes \
 --o-per-sample-sequences ${PREFIX}_demux.qza  \
 --o-error-correction-details ${PREFIX}_demux-details.qza \
 --p-no-golay-error-correction 

echo "Starting demux summary"
date
qiime demux summarize \
 --i-data ${PREFIX}_demux.qza \
 --o-visualization ${PREFIX}_demux.qzv

#use dada2 to remove sequencing errors
echo "Starting DADA2"
date
qiime dada2 denoise-paired \
 --i-demultiplexed-seqs ${PREFIX}_demux.qza \
 --p-trim-left-f 23 \
 --p-trim-left-r 23 \
 --p-trunc-len-f 200 \
 --p-trunc-len-r 200 \
 --o-representative-sequences ${PREFIX}_reps.qza \
 --o-table ${PREFIX}_dada2.qza \
 --o-denoising-stats ${PREFIX}_stats-dada2.qza \
 --p-n-threads 2 \
 --p-min-fold-parent-over-abundance 10

echo "Starting filter"
date
qiime feature-table filter-samples \
 --i-table ${PREFIX}_dada2.qza \
 --m-metadata-file ${METADATA} \
 --p-where "[SampleOwner]='Lizzy'" \
 --o-filtered-table ${PREFIX}_dada2_filtered_table.qza

echo "Starting feature table summary"
date
qiime feature-table summarize \
 --i-table ${PREFIX}_dada2.qza \
 --o-visualization ${PREFIX}_dada2_summarize.qzv \
 --m-sample-metadata-file ${METADATA}

echo "End of script"
date



~
                                                                                                                                                                                                                                                                                                                                                                                               
