include { BamToBed       } from "${baseDir}/modules/peaks/BamToBed.nf"
include { Macs2CallPeaks } from "${baseDir}/modules/peaks/Macs2CallPeaks.nf"

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
        xls        = Macs2CallPeaks.out.xls
}