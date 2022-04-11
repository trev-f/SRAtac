/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-14
Purpose: Generate preseq real counts file
*/

process PreseqRealCounts {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    input:
        tuple val(metadata), path(bam), val(toolIDs)
        path psL

    output:
        path '*preseq_real_counts.txt', emit: preseqRealCounts

    script:
        // update toolID and set suffix
        toolIDs += 'preseq_real_counts'

        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''

        """
        REALCOUNT=\$(samtools view -c -F 4 ${bam})
        UNIQCOUNT=\$(samtools view -c -F 1028 ${bam})
        echo "${psL} \${REALCOUNT} \${UNIQCOUNT}" > ${metadata.sampleName}${suffix}.txt
        """
}
