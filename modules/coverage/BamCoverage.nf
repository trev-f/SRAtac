/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-28
Purpose: Compute coverage of bam file over genome and write bigWig file
*/

process BamCoverage {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/deeptools:3.5.1--py_0'

    label 'cpu_mid'
    label 'mem_mid'

    publishDir "${params.baseDirData}/coverage", mode: 'copy', pattern: '*.bw'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)
        val binSize
        val normMethod

    output:
        tuple val(metadata), path('*.bw'), val(toolIDs), emit: bigWig

    script:
        // set suffix
        toolIDs += "dBC-${binSize}"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        bamCoverage \
            --bam ${bam} \
            --outFileFormat bigwig \
            --outFileName ${metadata.sampleName}${suffix}.bw \
            --binSize ${binSize} \
            --numberOfProcessors ${task.cpus} \
            --normalizeUsing ${normMethod} \
            --ignoreDuplicates
        """
}
