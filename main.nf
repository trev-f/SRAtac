#!/usr/bin/env nextflow

/*
---------------------------------------------------------------------
    trev-f/SRAlign
---------------------------------------------------------------------
SRAlign - A flexible pipeline for short read alignment to a reference.
https://github.com/trev-f/SRAlign
*/

nextflow.enable.dsl=2

/*
---------------------------------------------------------------------
    RUN MAIN WORKFLOW
---------------------------------------------------------------------
*/

include { SRAlign } from './workflows/SRAlign.nf'

workflow {
    SRAlign()
}
