include { ParseDesign   } from "${projectDir}/modules/inputs/ParseDesign.nf"
include { SamtoolsIndex } from "${projectDir}/modules/align/SamtoolsIndex.nf"

workflow ParseDesignSWF {
    take:
        design

    main:
        ParseDesign(
            design
        )
            .csv
            .splitCsv(header:true, sep:',')
            .map { createDesignChannel(it) }
            .branch {
                reads: it[1].any { it =~ /(fastq|fq)/ }   // add channels with fastq files (either fastq or fq) to reads channel
                bams:  it[1].any { it =~ /\.bam$/ }       // add channels with bams to bams channel
            }
            .set { design }

        // Index bams
        SamtoolsIndex(
            design.bams
        )
            .set { bamBai }

    emit:
        reads  = design.reads
        bamBai = bamBai
}


// create a list of data from the csv
def createDesignChannel(LinkedHashMap row) {
    // reads
    if (row.fq1) {
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

        return [metadata, reads, toolIDs]
    }
    
    // bams
    else if (row.bam) {
        // store metadata in a Map
        def metadata = [:]
        metadata.libID      = row.lib_ID
        metadata.sampleName = row.sample_rep

        // store bams
        bam = [file(row.bam)]

        // create an empty list for tool IDs for suffixes
        toolIDs = row.tool_IDs.split('_')

        return [metadata, bam, toolIDs]
    }
}
