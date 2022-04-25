include { SamtoolsFlagstat   } from "${baseDir}/modules/align/SamtoolsFlagstat.nf"
include { ContaminantStatsQC } from "${baseDir}/modules/align/ContaminantStatsQC.nf"

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