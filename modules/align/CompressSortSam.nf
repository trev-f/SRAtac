/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-02-27
Purpose: Nextflow module
*/

process CompressSortSam {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    publishDir "${params.baseDirData}/align", mode: 'copy', pattern: '*.bam'

    input:
        tuple val(metadata), file(sam), val(toolIDs)

    output:
        tuple val(metadata), file('*.bam'), val(toolIDs), emit: bam

    script:
        // update toolID and set suffix
        toolIDs += 'sSR'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        samtools view -bh ${sam} | \
        samtools sort -o ${metadata.sampleName}${suffix}.bam -
        """
}
