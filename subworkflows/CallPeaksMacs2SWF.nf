include { BamToBed } from '../modules/BamToBed.nf'

workflow CallPeaksMacs2SWF {
    take:
        bamIndexed

    main:
        // convert bam to bed
        BamToBed(
            bamIndexed
        )
}