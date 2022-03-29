/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-29
Purpose: Call peaks with macs2
*/

process Macs2CallPeaks {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/macs2:2.2.7.1--py39hbf8eff0_4'

    publishDir "${params.baseDirData}/peaks", mode: 'copy', pattern: '*'

    input:
        tuple val(metadata), path(bed), val(toolIDs)
        val effectiveGenomeSize

    output:
        path '*'

    script:
        // set suffix
        toolIDs += "m2C"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        macs2 callpeak \
            -t ${bed} \
            --format BED \
            --gsize ${effectiveGenomeSize} \
            --keep-dup 1 \
            --name ${metadata.sampleName}${suffix} \
            --nolambda --nomodel \
            --extsize 150 --shift 75
        """
}
