include { Preseq           } from "${baseDir}/modules/align/Preseq.nf"

workflow PreseqSWF {
    take:
        bam
    
    main:
        Preseq(
            bam
        )
    
    emit:
        psL = Preseq.out.psL
}