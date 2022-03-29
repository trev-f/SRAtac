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

        // call peaks
        Macs2CallPeaks(
            BamToBed.out.bed,
            effectiveGenomeSize
        )
    
    emit:
        narrowPeak = Macs2CallPeaks.out.narrowPeak
}