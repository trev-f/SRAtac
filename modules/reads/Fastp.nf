process Fastp {
    tag "${metadata.sampleName}"

    label 'mem_mid'
    label 'cpu_mid'

    container 'quay.io/biocontainers/fastp:0.23.2--h79da9fb_0'

    input:
        tuple val(metadata), file(reads), val(toolIDs)

    output:
        tuple val(metadata), path('*.fastq.gz'), val(toolIDs), emit: readsTrimmed

    script:
        // update toolID and set suffix
        toolIDs += 'fsp'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        if (metadata.readType == 'single') {
            // set adapter sequence
            adapterTrim = params.adapterR1 ? "--adapter_sequence ${params.adapterR1}" : ''

            """
            fastp \
                --thread ${task.cpus} \
                ${adapterTrim} \
                -i ${reads} \
                -o ${metadata.sampleName}${suffix}_R1.fastq.gz
            """
        } else {
            // set adapter sequence(s)
            adapterTrimR1 = params.adapterR1 ? "--adapter_sequence ${params.adapterR1}" : ''
            adapterTrimR2 = params.adapterR2 ? "--adapter_sequence_r2 ${params.adapterR2}" : ''

            """
            fastp \
                --thread ${task.cpus} \
                ${adapterTrimR1} \
                ${adapterTrimR2} \
                -i ${reads[0]} \
                -I ${reads[1]} \
                -o ${metadata.sampleName}${suffix}_R1.fastq.gz \
                -O ${metadata.sampleName}${suffix}_R2.fastq.gz
            """
        }
    
    stub:
        // update toolID and set suffix
        toolIDs += 'fsp'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        if (metadata.readType == 'single') {
            """
            touch ${metadata.sampleName}${suffix}_R1.fastq.gz
            """
        } else {
            """
            touch ${metadata.sampleName}${suffix}_R1.fastq.gz ${metadata.sampleName}${suffix}_R2.fastq.gz
            """
        }
}