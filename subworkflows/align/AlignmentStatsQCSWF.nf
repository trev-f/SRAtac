include { SamtoolsStatsIdxstats } from "${projectDir}/modules/align/SamtoolsStatsIdxstats.nf"
include { AlignmentStatsMultiQC } from "${projectDir}/modules/align/AlignmentStatsMultiQC.nf"

workflow AlignmentStatsQCSWF {
    take:
        bamIndexed
        prefix
    
    main:
        SamtoolsStatsIdxstats(
            bamIndexed
        )

        AlignmentStatsMultiQC(
            SamtoolsStatsIdxstats.out.sST.collect(),
            SamtoolsStatsIdxstats.out.sIX.collect(),
            prefix,
            SamtoolsStatsIdxstats.out.tools.first()
        )

    emit:
        samtoolsStats    = SamtoolsStatsIdxstats.out.sST
        samtoolsIdxstats = SamtoolsStatsIdxstats.out.sIX
        samtoolsStatsIS  = SamtoolsStatsIdxstats.out.sSTIS
        pctDup           = SamtoolsStatsIdxstats.out.pctDup
}
