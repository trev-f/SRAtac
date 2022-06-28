/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-04-21
Purpose: Compute read coverages for BAMs
*/

process DeepToolsMultiBamSummary {
    tag "${outName}"

    label 'mem_mid'
    label 'cpu_mid'

    container 'quay.io/biocontainers/deeptools:3.5.1--py_0'

    publishDir "${params.baseDirData}/align/deepTools", mode: 'copy', pattern: '*_dBS.npz'
    publishDir "${params.baseDirData}/align/deepTools", mode: 'copy', pattern: '*_dBS_dPC.txt'
    publishDir "${params.baseDirData}/align/deepTools", mode: 'copy', pattern: '*_dBS_dPP.txt'

    input:
        path bams
        path bais
        val  outName 

    output:
        path '*_dBS.npz',     emit: multiBamSummary
        path '*_dBS_dPC.txt', emit: corMatrix
        path '*_dBS_dPP.tab', emit: PCAMatrix

    script:
        toolIDs = []
        toolIDs += 'dBS'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        multiBamSummary bins \
            --bamfiles ${bams} \
            ${task.ext.args.multiBamSummary} \
            --numberOfProcessors ${task.cpus} \
            --outFileName ${outName}${suffix}.npz

        plotCorrelation \
            -in ${outName}${suffix}.npz \
            ${task.ext.args.plotCorrelation} \
            --outFileCorMatrix ${outName}${suffix}_dPC.txt

        plotPCA \
            -in ${outName}${suffix}.npz \
            ${task.ext.args.plotPCA} \
            --outFileNameData ${outName}${suffix}_dPP.tab
        """
    
    stub:
        toolIDs = []
        toolIDs += 'dBS'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        touch ${outName}${suffix}.npz
        touch ${outName}${suffix}_dPC.txt
        touch ${outName}${suffix}_dPP.tab
        """
}
