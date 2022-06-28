/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-14
Purpose: Run preseq commands
*/

process PreseqLcExtrap {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/preseq:3.1.2--h2c25361_3'

    label 'mem_mid'

    publishDir "${params.baseDirData}/align/preseq", mode: 'copy', pattern: '*.txt'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)

    output:
        path '*_psL.txt', emit: psL

    script:
        // update toolIDs and set suffix
        toolIDspsL = toolIDs
        toolIDspsL += 'psL'
        suffixpsL = toolIDspsL ? "__${toolIDspsL.join('_')}" : ''

        toolIDs += ['psL']

        // identify read types
        readTypeArg = metadata.readType == 'single' ? '' : '-pe'

        """
        preseq lc_extrap \
            -o ${metadata.sampleName}${suffixpsL}.txt \
            ${readTypeArg} \
            -bam ${bam}
        """
    
    stub:
        // update toolIDs and set suffix
        toolIDspsL = toolIDs
        toolIDspsL += 'psL'
        suffixpsL = toolIDspsL ? "__${toolIDspsL.join('_')}" : ''

        toolIDs += ['psL']

        """
        touch ${metadata.sampleName}${suffixpsL}.txt
        """
}
