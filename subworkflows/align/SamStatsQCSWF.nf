include { SamStats        } from "${baseDir}/modules/align/SamStats.nf"
include { SamStatsMultiQC } from "${baseDir}/modules/align/SamStatsMultiQC.nf"

workflow SamStatsQCSWF {
    take:
        bamBai
        prefix
    
    main:
        SamStats(bamBai)
        SamStatsMultiQC(
            SamStats.out.sST.collect(),
            SamStats.out.sIX.collect(),
            prefix,
            SamStats.out.tools.first()
        )

    emit:
        samtoolsStats    = SamStats.out.sST
        samtoolsIdxstats = SamStats.out.sIX
        samtoolsStatsIS  = SamStats.out.sSTIS
        pctDup           = SamStats.out.pctDup
}
