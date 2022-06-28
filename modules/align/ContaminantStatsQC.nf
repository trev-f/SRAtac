/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-13
Purpose: samtools flagstat multiQC report
*/

process ContaminantStatsQC {
    tag "${outName}"

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/align", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/align", mode: 'copy', pattern: '*mqc-contaminant_data*'

    input:
        file sFS
        val outName
        val toolIDs

    output:
        path '*'

    script:
        // update toolID and set suffix
        toolIDs += 'mqc-contaminant'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        multiqc \
            -n ${outName}${suffix} \
            --module samtools \
            ${sFS}
        """
    
    stub:
        toolIDs += 'mqc-contaminant'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        touch ${outName}${suffix}.html
        """
}
