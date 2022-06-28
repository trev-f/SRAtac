include { Bowtie2Build } from "${projectDir}/modules/align/Bowtie2Build.nf"
include { Bowtie2Align } from "${projectDir}/modules/align/Bowtie2Align.nf"

workflow Bowtie2SWF {
    take:
        reads
        reference
        referenceName
    
    main:
        // set or build bowtie2 index
        if (reference[ 'bowtie2' ]) {
            bowtie2Indexes = Channel
                .fromPath("${reference[ 'bowtie2' ]}*", checkIfExists: true)
                .collect()
        } else {
            Bowtie2Build(
                reference[ 'fasta' ],
                referenceName
            )
            .collect()
            .set { bowtie2Indexes }
        }

        Bowtie2Align(
            reads,
            bowtie2Indexes,
            referenceName
        )

    emit:
        sam = Bowtie2Align.out.sam
}
