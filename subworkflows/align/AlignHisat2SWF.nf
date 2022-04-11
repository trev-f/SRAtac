include { Hisat2Build } from "${baseDir}/modules/align/Hisat2Build.nf"
include { Hisat2Align } from "${baseDir}/modules/align/Hisat2Align.nf"

workflow AlignHisat2SWF {
    take:
        reads
        reference
        referenceName

    main:
        // set or build hisat2 index
        if (reference[ 'hisat2' ]) {
            hisat2Indexes = Channel
                .fromPath("${reference[ 'hisat2' ]}*", checkIfExists: true)
                .collect()
        } else {
            Hisat2Build(
                reference[ 'fasta' ],
                referenceName
            )
            .collect()
            .set { hisat2Indexes }
        }

        Hisat2Align(
            reads,
            hisat2Indexes,
            referenceName
        )

    emit:
        sam = Hisat2Align.out.sam
}