/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-28
Purpose: Filter uninformative or confounding alignments from bam file
*/

process SambambaFilterBam {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/sambamba:0.8.2--h98b6b92_2'

    publishDir "${params.baseDirData}/align/filter", mode: 'copy', pattern: '*.bam'
    publishDir "${params.baseDirData}/align/filter", mode: 'copy', pattern: '*.bai'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)
        val mapQThreshold
        val mitoChr

    output:
        tuple val(metadata), path('*.bam'), path('*.bai'), val(toolIDs), emit: bamBai

    script:
        // set suffix
        toolIDs += 'sbF'
        suffix = toolIDs ? "__${toolIDs.join('_')}" : ''
        """
        # filter bam file
        sambamba view \
            --filter "mapping_quality >= ${mapQThreshold} and not ref_name == '${mitoChr}' and not unmapped" \
            --format bam \
            --with-header \
            --nthreads ${task.cpus} \
            ${bam} | \

        # sort filtered bam file
        sambamba sort \
            --nthreads ${task.cpus} \
            --out ${metadata.sampleName}${suffix}.bam \
            /dev/stdin
        
        # index sorted and filtered bam file
        sambamba index \
            --nthreads ${task.cpus} \
            ${metadata.sampleName}${suffix}.bam
        """
}
