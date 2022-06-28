include { FastQC       as RawFastQC  } from "${baseDir}/modules/reads/FastQC.nf"
include { FastQC       as TrimFastQC } from "${baseDir}/modules/reads/FastQC.nf"
include { ReadsMultiQC               } from "${baseDir}/modules/reads/ReadsMultiQC.nf"

workflow ReadsQCSWF {
    take:
        readsRaw
        readsTrimmed
        prefix


    main:
        // run FastQC on raw reads
        if (!params.skipRawFastQC) {
            RawFastQC(
                readsRaw
            )
            ch_rawFastQCZip = RawFastQC.out.zip
        } else {
            ch_rawFastQCZip = Channel.empty()
        }

        // run FastQC on trimmed reads
        if (!params.skipTrimFastQC) {
            TrimFastQC(
                readsTrimmed
            )
            ch_trimFastQCZip = TrimFastQC.out.zip
        } else {
            ch_trimFastQCZip = Channel.empty()
        }

        // create dedicated MultiQC report for all reads
        if (!params.skipDedicatedReadsMultiQC) {
            // combine raw and trimmed reads FastQC zip files
            ch_allFastQCZip = Channel.empty()
                .concat(ch_rawFastQCZip)    // add raw reads FastQC zip files
                .concat(ch_trimFastQCZip)   // add trimmed reads FastQC zip files
                .collect()                  // collect all zip files into a single channel

            // create the MultiQC report
            ReadsMultiQC(
                ch_allFastQCZip,
                prefix
            )
        }


    emit:
        raw_fqc_zip  = ch_rawFastQCZip
        trim_fqc_zip = ch_trimFastQCZip
}
