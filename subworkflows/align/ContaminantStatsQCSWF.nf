include { SamtoolsFlagstat   } from "${projectDir}/modules/align/SamtoolsFlagstat.nf"
include { ContaminantStatsQC } from "${projectDir}/modules/align/ContaminantStatsQC.nf"

workflow ContaminantStatsQCSWF {
    take:
        sam
        prefix

    main:
        SamtoolsFlagstat(
            sam
        )
        ContaminantStatsQC(
            SamtoolsFlagstat.out.sFS.collect(),
            prefix,
            SamtoolsFlagstat.out.tools.first()
        )
    
    emit:
        samtoolsFlagstat = SamtoolsFlagstat.out.sFS
}