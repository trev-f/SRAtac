/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-03-06
Purpose: Build hisat2 index
*/

process Hisat2Build {
    tag "${refName}"

    container 'quay.io/biocontainers/hisat2:2.2.1--h87f3376_4'

    input:
        path reference
        val refName

    output:
        path '*', emit: hisat2Index

    script:
        // set index basename
        def ht2Base = reference.toString() - ~/.fa?/

        // set arguments
        def options = task.ext.args ?: ''

        // build hisat2 index
        """
        hisat2-build \
            ${options} \
            ${reference} \
            ${ht2Base}
        """
}
