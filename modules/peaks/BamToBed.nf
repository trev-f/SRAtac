/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-29
Purpose: Convert bam to bed
*/

process BamToBed {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/bedtools:2.30.0--h468198e_3'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)

    output:
        tuple val(metadata), path('*.bed'), val(toolIDs), emit: bed

    script:
        // set suffix
        toolIDs += "btB"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        bedtools bamtobed \
            -i ${bam} \
            > ${metadata.sampleName}${suffix}.bed
        """
}
