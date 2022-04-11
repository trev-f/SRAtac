include { Preseq           } from "${baseDir}/modules/align/Preseq.nf"
include { PreseqRealCounts } from "${baseDir}/modules/align/PreseqRealCounts.nf"

workflow PreseqSWF {
    take:
        bam
    
    main:
        Preseq(
            bam
        )
        PreseqRealCounts(
            bam,
            Preseq.out.psL
        )
    
    emit:
        psL = Preseq.out.psL
        psRealCounts = PreseqRealCounts.out.preseqRealCounts
}