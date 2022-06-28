/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-02-27
Purpose: Nextflow module
*/

process AlignmentStatsMultiQC {
    tag "${outName}"

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/align", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/align", mode: 'copy', pattern: '*mqc-alignments_data*'

    input:
        file samtoolsStats
        file samtoolsIdxstats
        val outName
        val toolIDs

    output:
        path '*'

    script:
        // update toolID and set suffix
        toolIDs += 'mqc-alignments'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        multiqc \
            -n ${outName}${suffix} \
            --module samtools \
            ${samtoolsStats} \
            ${samtoolsIdxstats}
        """
    
    stub:
        // update toolID and set suffix
        toolIDs += 'mqc-alignments'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        touch ${outName}${suffix}.html
        """
}
