/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-02-27
Purpose: Nextflow module
*/

process SamStatsMultiQC {
    tag "${runName}"

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/align", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/align", mode: 'copy', pattern: '*multiqc_data*'

    input:
        file sST
        file sIX
        val runName
        val toolIDs

    output:
        path '*'

    script:
        // update toolID and set suffix
        toolIDs += 'mqc'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''


        """
        multiqc \
            -n ${runName}${suffix} \
            --module samtools \
            ${sST} \
            ${sIX}
        """
}
