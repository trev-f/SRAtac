include { Samblaster      } from "${baseDir}/modules/align/Samblaster.nf"
include { CompressSortSam } from "${baseDir}/modules/align/CompressSortSam.nf"
include { IndexBam        } from "${baseDir}/modules/align/IndexBam.nf"

workflow PreprocessSamSWF {
    take:
        sam

    main:
        // mark duplicates with samblaster
        Samblaster(
            sam
        )

        // compress sam and sort bam by coordinate
        CompressSortSam(
            Samblaster.out.sam
        )

        // index bam
        IndexBam(
            CompressSortSam.out.bam
        )

    emit:
        bamBai = IndexBam.out.bamBai
}