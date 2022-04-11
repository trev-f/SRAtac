include { FastQC       } from "${baseDir}/modules/reads/TrimFastQC.nf"
include { ReadsMultiQC } from "${baseDir}/modules/reads/TrimReadsMultiQC.nf"

workflow TrimReadsQCSWF {
    take:
        trimReads
        runName

    main:
        FastQC(trimReads)
        ReadsMultiQC(FastQC.out.zip.collect(), runName, FastQC.out.tools.first())

    emit:
        fqc_zip = FastQC.out.zip
}
