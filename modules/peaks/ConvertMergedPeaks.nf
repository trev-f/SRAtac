/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-12
Purpose: Convert merged peaks to standard file format
*/

process ConvertMergedPeaks {
    tag "${inName}"

    container 'quay.io/biocontainers/pandas:1.1.5'

    publishDir "${params.baseDirData}/peaks/merge", mode: 'copy', pattern: '*.saf'

    input:
        tuple path(mergedPeaks), val(toolIDs)
        val inName
        val tool

    output:
        tuple path('*.saf'), val(toolIDs), emit: mergedPeaks

    script:
        """
        convert_merged_peaks.py \
            --tool ${tool} \
            -o SAF \
            ${mergedPeaks}
        """
}
