/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-13
Purpose: Perform samtools flagstat on a sam, bam, or cram file
*/

process SamtoolsFlagstat {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    publishDir "${params.baseDirData}/align/stats", mode: 'copy', pattern: '*.txt'

    input:
        tuple val(metadata), path(bam), val(toolIDs)

    output:
        path '*_sFS.txt', emit: sFS
        val toolIDs,      emit: tools

    script:
        toolIDs += 'sFS'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        samtools flagstat ${bam} > ${metadata.sampleName}${suffix}.txt
        """

    stub:
        toolIDs += 'sFS'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        touch ${metadata.sampleName}${suffix}.txt
        """
}
