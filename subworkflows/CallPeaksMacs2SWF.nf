include { BamToBed       } from '../modules/BamToBed.nf'
include { Macs2CallPeaks } from '../modules/Macs2CallPeaks.nf'

workflow CallPeaksMacs2SWF {
    take:
        bamIndexed
        effectiveGenomeSize

    main:
        // convert bam to bed
        BamToBed(
            bamIndexed
        )

        Macs2CallPeaks(
            BamToBed.out.bed,
            effectiveGenomeSize
        )
}