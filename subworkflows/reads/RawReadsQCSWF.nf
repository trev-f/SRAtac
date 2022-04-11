include { FastQC       } from "${baseDir}/modules/reads/RawFastQC.nf"
include { ReadsMultiQC } from "${baseDir}/modules/reads/RawReadsMultiQC.nf"

workflow RawReadsQCSWF {
    take:
        rawReads
        runName

    main:
        FastQC(rawReads)
        ReadsMultiQC(FastQC.out.zip.collect(), runName, FastQC.out.tools.first())

    emit:
        fqc_zip = FastQC.out.zip
}
