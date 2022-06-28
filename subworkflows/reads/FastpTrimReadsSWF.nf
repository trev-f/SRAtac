include { Fastp } from "${projectDir}/modules/reads/Fastp.nf"

workflow FastpTrimReadsSWF {
    take:
        readsRaw

    main:
        Fastp(readsRaw)

    emit:
        readsTrimmed = Fastp.out.readsTrimmed
}
