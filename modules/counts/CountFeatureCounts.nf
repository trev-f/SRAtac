/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-12
Purpose: Count number of reads in peaks
*/

process CountFeatureCounts {
    tag "${inName}"

    container 'quay.io/biocontainers/subread:2.0.1--h7132678_2'

    publishDir "${params.baseDirData}/counts", mode: 'copy', pattern: '*_srF.txt*'

    input:
        path bams
        val toolIDsBams
        tuple path(peaks), val(toolIDsPeaks)
        val inName

    output:
        tuple path('*_srF.txt'), val(toolIDsBams), emit: featCounts
        tuple path('*_srF.txt.summary'), val(toolIDsBams), emit: featCountsSummary


    script:
        // set suffix
        toolIDsBams += "srF"
        suffix = toolIDsBams ? "__${toolIDsBams.join('_')}" : ''

        """
        featureCounts \
            -a ${peaks} -F SAF \
            -o ${inName}_${workflow.runName}_${workflow.start}${suffix}.txt \
            --ignoreDup \
            ${bams}
        """
}
