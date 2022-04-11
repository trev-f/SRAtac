process ReadsMultiQC {
    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/readsQC/raw", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/readsQC/raw", mode: 'copy', pattern: '*multiqc_data*'

    input:
        file fastqc
        val runName
        val toolIDs

    output:
        path "*"

    script:
        // update toolID and set suffix
        toolIDs += 'mqc'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        multiqc \
            -n ${runName}${suffix} \
            --module fastqc \
            ${fastqc}
        """
}
