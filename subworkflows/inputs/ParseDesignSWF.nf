include { ParseDesign } from "${baseDir}/modules/inputs/ParseDesign.nf"

workflow ParseDesignSWF {
    take:
        design

    main:
        ParseDesign(design)
            .csv
            .splitCsv(header:true, sep:',')
            .map { createReadsChannel(it) }
            .set { rawReads }

    emit:
        rawReads
}


// create a list of data from the csv
def createReadsChannel(LinkedHashMap row) {
    // store metadata in a Map
    def metadata = [:]
    metadata.libID      = row.lib_ID
    metadata.sampleName = row.sample_rep
    metadata.readType   = row.fq2 ? 'paired' : 'single'

    // store reads in a list
    def reads = []
    if (metadata.readType == 'single') {
        reads = [file(row.fq1)]
    } else {
        reads = [file(row.fq1), file(row.fq2)]
    }


    // create an empty list for tool IDs for suffixes
    toolIDs = []

    // check that reads files exist
    reads.each {
        if (!it.exists()) {
            exit 1, "ERROR: ${it} does not exist!"
        }
    }

    return [metadata, reads, toolIDs]
}
