process ParseDesign {
    tag "${design}"

    container 'quay.io/biocontainers/python-bioext:0.20.4--py39h7f6d023_1'

    publishDir "${params.baseDirData}/design", mode: 'copy'

    input:
        path design

    output:
        path '*.csv', emit: csv

    script:
        """
        parse_design.py \
            ${design}
        """
}
