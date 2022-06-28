include { PreseqLcExtrap } from "${projectDir}/modules/complexity/PreseqLcExtrap.nf"

workflow PreseqSWF {
    take:
        bam
    
    main:
        PreseqLcExtrap(
            bam
        )
    
    emit:
        psL = PreseqLcExtrap.out.psL
}