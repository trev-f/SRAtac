include { SamStats } from '../modules/SamStats.nf'
include { SamStatsMultiQC } from '../modules/SamStatsMultiQC.nf'

workflow SamStatsQCSWF {
    take:
        bamBai
        runName
    
    main:
        SamStats(bamBai)
        SamStatsMultiQC(SamStats.out.sST.collect(), SamStats.out.sIX.collect(), runName, SamStats.out.tools.first())

    emit:
        samtoolsStats = SamStats.out.sST
        samtoolsIdxstats = SamStats.out.sIX
        samtoolsStatsIS  = SamStats.out.sSTIS
}
