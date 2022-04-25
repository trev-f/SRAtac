/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-13
Purpose: Randomly sample reads
*/

process SeqtkSample {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/seqtk:1.3--h7132678_4'

    input:
        tuple val(metadata), file(reads), val(toolIDs)

    output:
        tuple val(metadata), file('*fastq.gz'), val(toolIDs), emit: sampleReads

    script:
        // update toolID and set suffix
        toolIDs += "skS"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        if (metadata.readType == 'single') {
            """
            seqtk sample -s${task.ext.seed} ${reads} ${task.ext.sampleSize} | \
                gzip -c > ${metadata.sampleName}${suffix}.fastq.gz 
            """
        } else {
            """
            seqtk sample -s${task.ext.seed} ${reads[0]} ${task.ext.sampleSize} | \
                gzip -c > ${metadata.sampleName}${suffix}_R1.fastq.gz 
            seqtk sample -s${task.ext.seed} ${reads[1]} ${task.ext.sampleSize} | \
                gzip -c > ${metadata.sampleName}${suffix}_R2.fastq.gz 
            """
        }
}
