/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-12
Purpose: Count number of reads in peaks
*/

process FeatureCounts {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/subread:2.0.1--h7132678_2'

    label 'cpu_mid'
    label 'mem_mid'

    publishDir "${params.baseDirData}/counts", mode: 'copy', pattern: '*.txt*'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDsBam)
        tuple path(peaks), val(toolIDsPeaks)

    output:
        tuple path('*.txt'), val(toolIDsBam),         emit: featCounts
        tuple path('*.txt.summary'), val(toolIDsBam), emit: featCountsSummary


    script:
        // set suffix
        toolIDsBam += "srF"
        suffix = toolIDsBam ? "__${toolIDsBam.join('_')}" : ''

        // set arguments
        def options = task.ext.args ?: ''

        """
        featureCounts \
            -T ${task.cpus} \
            -a ${peaks} -F SAF \
            -o ${metadata.sampleName}${suffix}.txt \
            --ignoreDup \
            ${bam}
        """
}
