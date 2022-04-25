process FastQC {
    tag "${metadata.sampleName}"

    container 'biocontainers/fastqc:v0.11.9_cv8'

    publishDir "${params.baseDirReport}/readsQC/trim/fastQC", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/readsQC/trim/fastQC",   mode: 'copy', pattern: '*.zip'

    input:
        tuple val(metadata), file(reads), val(toolIDs)

    output:
        path '*.html', emit: html
        path '*.zip', emit: zip 
        val toolIDs, emit: tools

    script:
        // update toolID and set suffix
        toolIDs += 'fqc'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        if (metadata.readType == 'single') {
            read1 = "${metadata.sampleName}${suffix}_R1.fastq.gz"

            """
            [ ! -f ${read1} ] && ln -s ${reads} ${read1}

            fastqc ${read1}
            """
        } else {
            read1 = "${metadata.sampleName}${suffix}_R1.fastq.gz"
            read2 = "${metadata.sampleName}${suffix}_R2.fastq.gz"

            """
            [ ! -f ${read1} ] && ln -s ${reads[0]} ${read1}
            [ ! -f ${read2} ] && ln -s ${reads[1]} ${read2}

            fastqc ${read1} ${read2}
            """
        }
}
