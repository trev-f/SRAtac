/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-06
Purpose: Build bowtie2 index
*/

process Bowtie2Build {
    tag "${refName}"

    container 'quay.io/biocontainers/bowtie2:2.4.5--py38hfbc8389_2'

    label 'cpu_mid'
    label 'mem_high'

    input:
        path reference
        val refName

    output:
        path '*', emit: bowtie2Index

    script:
        // set index basename
        bt2Base = reference.toString() - ~/.fa?/
        """
        bowtie2-build \
            --threads ${task.cpus} \
            ${reference} \
            ${bt2Base}
        """
     stub:
        // set index basename
        bt2Base = reference.toString() - ~/.fa?/
        """
        touch \
            ${bt2Base}.fa \
            ${bt2Base}.1.bt2 \
            ${bt2Base}.2.bt2 \
            ${bt2Base}.3.bt2 \
            ${bt2Base}.4.bt2 \
            ${bt2Base}.rev.1.bt2 \
            ${bt2Base}.rev.2.bt2
        """
}
