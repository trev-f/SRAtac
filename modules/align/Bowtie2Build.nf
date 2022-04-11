/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-06
Purpose: Build bowtie2 index
*/

process Bowtie2Build {
    tag "${refName}"

    container 'quay.io/biocontainers/bowtie2:2.4.5--py38hfbc8389_2'

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
}
