/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-11
Purpose: Merge peaks with homer
*/

process MergePeaksHomer {
    tag "${inName}"

    container 'quay.io/biocontainers/homer:4.11--pl5321h9f5acd7_7'

    publishDir "${params.baseDirData}/peaks/merge", mode: 'copy', pattern: '*_hoM.txt'

    input:
        tuple path(peaksFiles), val(toolIDs)
        val inName

    output:
        path '*_hoM.txt', emit: mergePeaks

    script:
        // set suffix
        toolIDs += "hoM"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        mergePeaks \
            ${peaksFiles} \
            > ${inName}_${workflow.runName}_${workflow.start}${suffix}.txt
        """
}
