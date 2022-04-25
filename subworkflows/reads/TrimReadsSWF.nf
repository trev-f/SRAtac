include { Fastp } from "${baseDir}/modules/reads/Fastp.nf"

workflow TrimReadsSWF {
    take:
        rawReads

    main:
        Fastp(rawReads)

    emit:
        trimReads = Fastp.out.trimReads
}
