/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-11
Purpose: Merge peaks with homer
*/

process MergePeaksHomer {
    tag "${inName}"

    container 'quay.io/biocontainers/homer:4.11--pl5321h9f5acd7_7'

    publishDir "${params.baseDirData}/peaks/merge", mode: 'copy', pattern: '*_hoM.txt'
    publishDir "${params.baseDirData}/peaks/merge", mode: 'copy', pattern: '*matrix.txt'

    input:
        tuple path(peaksFiles), val(toolIDs)
        val inName
        val effectiveGenomeSize

    output:
        tuple path('*_hoM.txt'), val(toolIDs), emit: mergePeaks
        tuple path('*.logPvalue.matrix.txt'), path('*.logRatio.matrix.txt'), path('*.count.matrix.txt'), val(toolIDs), emit: mergePeaksMatrix

    script:
        // set suffix
        toolIDs += "hoM"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        mergePeaks \
            ${task.ext.args} \
            -gsize ${effectiveGenomeSize} \
            -matrix ${inName}_${workflow.runName}_${workflow.start}${suffix} \
            ${peaksFiles} \
            > ${inName}_${workflow.runName}_${workflow.start}${suffix}.txt
        """
}
