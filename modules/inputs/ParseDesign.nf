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
    
    stub:
        """
        touch stub_design.csv
        echo 'lib_ID,sample_rep,fq1,fq2' >> stub_design.csv
        echo 'HSL-1_spoof,spoof_control_rep1,${projectDir}/test/data/reads/raw/HSL-1_spoof_R1.fastq.gz,${projectDir}/test/data/reads/raw/HSL-1_spoof_R2.fastq.gz' >> stub_design.csv
        echo 'HSL-2_spoof,spoof_control_rep2,${projectDir}/test/data/reads/raw/HSL-2_spoof_R1.fastq.gz,${projectDir}/test/data/reads/raw/HSL-2_spoof_R2.fastq.gz' >> stub_design.csv
        echo 'HSL-3_spoof,spoof_treatXY_rep1,${projectDir}/test/data/reads/raw/HSL-3_spoof_R1.fastq.gz,${projectDir}/test/data/reads/raw/HSL-3_spoof_R2.fastq.gz' >> stub_design.csv
        echo 'HSL-4_spoof,spoof_treatXY_rep2,${projectDir}/test/data/reads/raw/HSL-4_spoof_R1.fastq.gz,${projectDir}/test/data/reads/raw/HSL-4_spoof_R2.fastq.gz' >> stub_design.csv
        """
}
