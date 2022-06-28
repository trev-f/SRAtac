/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-06
Purpose: Build hisat2 index
*/

process Hisat2Build {
    tag "${refName}"

    container 'quay.io/biocontainers/hisat2:2.2.1--h87f3376_4'
    
    label 'cpu_mid'
    label 'mem_high'

    input:
        path reference
        path genes
        val refName
        val spliceAware

    output:
        path "${reference.toString() - ~/.fa?/}*", emit: hisat2Index

    script:
        // set index basename
        def ht2Base = reference.toString() - ~/.fa?/

        // set arguments
        def options = task.ext.args ?: ''

        // build hisat2 index
        if (!spliceAware) {
            """
            hisat2-build \
                -p ${task.cpus} \
                ${options} \
                ${reference} \
                ${ht2Base}
            """
        } else {
            """
            hisat2_extract_splice_sites.py ${genes} > splicesites.txt
            hisat2_extract_exons.py        ${genes} > exons.txt

            hisat2-build \
                -p ${task.cpus} \
                --ss splicesites.txt \
                --exon exons.txt \
                ${options} \
                ${reference} \
                ${ht2Base}
            """
        }

    stub:
        // set index basename
        def ht2Base = reference.toString() - ~/.fa?/

        """
        touch \
            ${ht2Base}.fa \
            ${ht2Base}.1.ht2 \
            ${ht2Base}.2.ht2 \
            ${ht2Base}.3.ht2 \
            ${ht2Base}.4.ht2 \
            ${ht2Base}.5.ht2 \
            ${ht2Base}.6.ht2 \
            ${ht2Base}.7.ht2 \
            ${ht2Base}.8.ht2
        """
}
