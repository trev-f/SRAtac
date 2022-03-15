# SRAtac
A pipeline for ATAC-seq data analysis built on SRAlign.

## Introduction

**SRAtac** is a [Nextflow](https://www.nextflow.io/) pipeline for processing ATAC-seq data. 

**SRAtac** is designed to be highly flexible pipeline for ATAC-seq data processing. The goal of this pipeline is to perform end-to-end data processing of ATAC-seq samples with extensive QC at all steps.

## Pipeline overview

1. QC of raw reads - [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) & [MultiQC](https://multiqc.info/)
2. Trim raw reads - [cutadapt](https://github.com/marcelm/cutadapt)
3. Align reads - [BWA](http://bio-bwa.sourceforge.net/) -OR- [Bowtie 2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
4. Mark duplicates - [samblaster](https://github.com/GregoryFaust/samblaster)
5. QC of alignments - [Samtools](http://www.htslib.org/) & [MultiQC](https://multiqc.info/) 

## Quick start

1. [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
2. [Install Docker](https://docs.docker.com/engine/install/)
3. Download **sralign**:
    ```
    git clone https://github.com/trev-f/sralign.git
    ```
4. Run **sralign** in test mode:
    ```
    nextflow run sralign -profile test 
    ```
5. Run your analysis:
    ```
    nextflow run sralign -profile <> --input YYYYMMDD_input.csv --genome WBCel235
    ```

Detailed documentation can be found in [docs](docs/) and [usage](docs/usage.md)