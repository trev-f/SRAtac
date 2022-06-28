include { Hisat2Build } from "${projectDir}/modules/align/Hisat2Build.nf"
include { Hisat2Align } from "${projectDir}/modules/align/Hisat2Align.nf"

workflow Hisat2SWF {
    take:
        reads
        reference
        referenceName
        forceUseHisat2Index
        buildSpliceAwareIndex

    main:
        // set or build HISAT2 index
        if (reference[ 'hisat2' ] && forceUseHisat2Index) {
            hisat2Indexes = Channel
                .fromPath("${reference[ 'hisat2' ]}*", checkIfExists: true)
                .collect()
        } else {
            // set genes channel
            if (reference[ 'genes' ]) {
                ch_genes = Channel.fromPath(reference[ 'genes' ])
            } else {
                ch_genes = Channel.fromPath(params.dummyFile)
            }

            // build HISAT2 index
            Hisat2Build(
                reference[ 'fasta' ],
                ch_genes,
                referenceName,
                buildSpliceAwareIndex
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