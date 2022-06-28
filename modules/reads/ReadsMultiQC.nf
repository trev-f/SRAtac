process ReadsMultiQC {
    tag "${outName}"

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReport}/readsQC", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/readsQC", mode: 'copy', pattern: '*__mqc-reads_data*'

    input:
        file fastqc
        val outName

    output:
        path "*"

    script:
        // set suffix
        suffix = "__mqc-reads"

        """
        multiqc \
            -n ${outName}${suffix} \
            --module fastqc \
            ${fastqc}
        """

    stub:
        // set suffix
        suffix = "__mqc-reads"

        """
        touch ${outName}${suffix}.html
        """
}
