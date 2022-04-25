process Bowtie2Align {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/bowtie2:2.4.5--py38hfbc8389_2'

    label 'cpu_mid'
    label 'mem_mid'

    input:
        tuple val(metadata), file(reads), val(toolIDs)
        path bt2Indexes
        val refName

    output:
        tuple val(metadata), file('*.sam'), val(toolIDs), emit: sam

    script:
        // set reads arguments
        if (metadata.readType == 'single') {
            argReads = "-1 ${reads}"
        } else {
            argReads = "-1 ${reads[0]} -2 ${reads[1]}"
        }


        // update toolID and set suffix
        toolIDs += "bt2-${refName}"
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''


        // set index base name
        bt2IndexBaseName = bt2Indexes[0].toString() - ~/.rev.\d.bt2?/ - ~/.\d.bt2?/ - ~/.fa?/

        // set arguments
        def options = task.ext.args ?: ''

        """
        bowtie2 \
            --threads ${task.cpus} \
            ${options} \
            -x ${bt2IndexBaseName} \
            ${argReads} \
            -S ${metadata.sampleName}${suffix}.sam
        """
}
