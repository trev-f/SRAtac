/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-28
Purpose: Filter uninformative or confounding alignments from bam file
*/

process SambambaFilterBam {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/sambamba:0.8.2--h98b6b92_2'

    publishDir "${params.baseDirData}/align", mode: 'copy', pattern: '*.bam'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)
        val mapQThreshold
        val mitoChr

    output:
        tuple val(metadata), path('*.bam'), val(toolIDs), emit: bam

    script:
        // set suffix
        toolIDs += 'sbV'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''
        """
        sambamba view \
            --filter "mapping_quality >= ${mapQThreshold} and not ref_name == '${mitoChr}' and not unmapped" \
            --format bam \
            --with-header \
            --nthreads ${task.cpus} \
            --output-filename ${metadata.sampleName}${suffix}.bam \
            ${bam}
        """
}
