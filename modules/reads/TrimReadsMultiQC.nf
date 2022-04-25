process ReadsMultiQC {
    tag "${outName}"

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/readsQC/trim", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/readsQC/trim", mode: 'copy', pattern: '*multiqc_data*'

    input:
        file fastqc
        val outName
        val toolIDs

    output:
        path "*"

    script:
        // update toolID and set suffix
        toolIDs += 'mqc'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        multiqc \
            -n ${outName}${suffix} \
            --module fastqc \
            ${fastqc}
        """
}
