include { Samblaster           } from "${projectDir}/modules/align/Samblaster.nf"
include { SamtoolsCompressSort } from "${projectDir}/modules/align/SamtoolsCompressSort.nf"
include { SamtoolsIndex        } from "${projectDir}/modules/align/SamtoolsIndex.nf"

workflow PostprocessSamSWF {
    take:
        sam

    main:
        // mark duplicates with samblaster
        Samblaster(
            sam
        )

        // compress sam and sort bam by coordinate
        SamtoolsCompressSort(
            Samblaster.out.sam
        )

        // index bam
        SamtoolsIndex(
            SamtoolsCompressSort.out.bamSorted
        )

    emit:
        bamIndexed = SamtoolsIndex.out.bamIndexed
}