/*
=====================================================================
    HANDLE INPUTS
=====================================================================
*/


/*
    ---------------------------------------------------------------------
    Tools
    ---------------------------------------------------------------------
*/

def tools = [
    trim      : ['fastp'],
    alignment : ['bowtie2', 'hisat2']
]

// check valid read-trimming tool
assert params.trimTool in tools.trim , 
    "'${params.trimTool}' is not a valid read trimming tool.\n\tValid options: ${tools.trim.join(', ')}\n\t" 

// check valid alignment tool
assert params.alignmentTool in tools.alignment , 
    "'${params.alignmentTool}' is not a valid alignment tool.\n\tValid options: ${tools.alignment.join(', ')}\n\t"

ch_multiqcConfig = file(params.multiqcConfig, checkIfExists: true)

/*
    ---------------------------------------------------------------------
    Design and Inputs
    ---------------------------------------------------------------------
*/

// check design file
if (params.input) {
    ch_input = file(params.input)
} else {
    exit 1, 'Input design file not specified!'
}


// set input design name
inName = params.input.take(params.input.lastIndexOf('.')).split('/')[-1]


/*
    ---------------------------------------------------------------------
    References and Contaminant Genomes
    ---------------------------------------------------------------------
*/

// check reference genome
if (params.genomes && params.genome && !params.genomes.containsKey(params.genome)) {
    exit 1, "Reference genome '${params.genome}' is not available.\n\tAvailable genomes include: ${params.genomes.keySet().join(", ")}"
}
genome = params.genomes[ params.genome ]

// check contaminant
if (params.genomes && params.contaminant && !params.skipAlignContam && !params.genomes.containsKey(params.contaminant)) {
    exit 1, "Contaminant genome '${params.contaminant}' is not available.\n\tAvailable genomes include: ${params.genomes.keySet().join(", ")}"
}
contaminant = params.genomes[ params.contaminant ]

/*
=====================================================================
    MAIN WORKFLOW
=====================================================================
*/

include { ParseDesignSWF        as ParseDesign        } from '../subworkflows/ParseDesignSWF.nf'
include { RawReadsQCSWF         as RawReadsQC         } from '../subworkflows/RawReadsQCSWF.nf'
include { TrimReadsSWF          as TrimReads          } from '../subworkflows/TrimReadsSWF.nf'
include { TrimReadsQCSWF        as TrimReadsQC        } from '../subworkflows/TrimReadsQCSWF.nf'
include { AlignBowtie2SWF       as AlignBowtie2       ; 
          AlignBowtie2SWF       as ContamBowtie2      } from '../subworkflows/AlignBowtie2SWF.nf'
include { AlignHisat2SWF        as AlignHisat2        ; 
          AlignHisat2SWF        as ContamHisat2       } from '../subworkflows/AlignHisat2SWF.nf'
include { PreprocessSamSWF      as PreprocessSam      } from '../subworkflows/PreprocessSamSWF.nf'
include { SamStatsQCSWF         as SamStatsQC         } from '../subworkflows/SamStatsQCSWF.nf'
include { SeqtkSample           as SeqtkSample        } from '../modules/SeqtkSample.nf'
include { ContaminantStatsQCSWF as ContaminantStatsQC } from '../subworkflows/ContaminantStatsQCSWF.nf'
include { FullMultiQC           as FullMultiQC        } from '../modules/FullMultiQC.nf'
include { PreseqSWF             as Preseq             } from '../subworkflows/PreseqSWF.nf'


workflow sralign {

    /*
    ---------------------------------------------------------------------
        Read design file, parse sample names and identifiers, and stage reads files
    ---------------------------------------------------------------------
    */

    // Subworkflow: Parse design file
    ParseDesign(
        ch_input
    )
    ch_rawReads = ParseDesign.out.rawReads


    /*
    ---------------------------------------------------------------------
        Raw reads
    ---------------------------------------------------------------------
    */

    if (!params.skipRawFastQC) {
        // Subworkflow: Raw reads fastqc and mulitqc
        RawReadsQC(
            ch_rawReads,
            inName
        )
        ch_rawReadsFQC = RawReadsQC.out.fqc_zip
    } else {
        ch_rawReadsFQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Trim raw reads
    ---------------------------------------------------------------------
    */

    if (!params.skipTrimReads) {
        // Trim reads
        switch (params.trimTool) {
            case 'fastp':
                // Subworkflow: Trim raw reads
                TrimReads(
                    ch_rawReads
                )
                ch_trimReads = TrimReads.out.trimReads
                break
        }


        // Trimmed reads QC
        if (!params.skipTrimReadsQC) {
            // Subworkflow: Trimmed reads fastqc and multiqc
            TrimReadsQC(
                ch_trimReads,
                inName
            ) 
            ch_trimReadsFQC = TrimReadsQC.out.fqc_zip
        } else {
            ch_trimReadsFQC = Channel.empty()
        }
    } else {
        ch_trimReadsFQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Align reads to genome
    ---------------------------------------------------------------------
    */

    // Set channel of reads to align 
    if (!params.forceAlignRawReads) {
        if (!params.skipTrimReads) {
            ch_readsToAlign = ch_trimReads
        } else {
            ch_readsToAlign = ch_rawReads
        }
    } else {
        ch_readsToAlign = ch_rawReads
    }


    if (!params.skipAlignGenome) {
        ch_samGenome = Channel.empty()
        // Align reads to genome
        switch (params.alignmentTool) {
            case 'bowtie2':
                // Subworkflow: Align reads to genome with bowtie2 and build index if necessary
                AlignBowtie2(
                    ch_readsToAlign,
                    genome,
                    params.genome
                )
                ch_samGenome = AlignBowtie2.out.sam
                break
            
            case 'hisat2':
                // Subworkflow: Align reads to genome with hisat2 and build index if necessary
                AlignHisat2(
                    ch_readsToAlign,
                    genome,
                    params.genome
                )
                ch_samGenome = AlignHisat2.out.sam
                break
        }
    

    PreprocessSam(
        ch_samGenome
    )
    ch_bamGenome        = PreprocessSam.out.bam
    ch_bamIndexedGenome = PreprocessSam.out.bamBai


    if (!params.skipSamStatsQC) {
        // Subworkflow: Samtools stats and samtools idxstats and multiqc of alignment results
        SamStatsQC(
            ch_bamIndexedGenome,
            inName
        )
        ch_alignGenomeStats    = SamStatsQC.out.samtoolsStats
        ch_alignGenomeIdxstats = SamStatsQC.out.samtoolsIdxstats
        ch_alignGenomeStatsIS  = SamStatsQC.out.samtoolsStatsIS
        ch_alignGenomePctDup   = SamStatsQC.out.pctDup
        }
    } else {
        ch_alignGenomeStats    = Channel.empty()
        ch_alignGenomeIdxstats = Channel.empty()
        ch_alignGenomeStatsIS  = Channel.empty()
        ch_alignGenomePctDup   = Channel.empty()
    }

    /*
    ---------------------------------------------------------------------
        Check contamination 
    ---------------------------------------------------------------------
    */

    if (params.contaminant && !params.skipAlignContam) {
        ch_samContaminant = Channel.empty()

        // Sample reads
        SeqtkSample(
            ch_readsToAlign
        ) 
        ch_readsContaminant = SeqtkSample.out.sampleReads

        // Align reads to contaminant genome
        switch (params.alignmentTool) {
            case 'bowtie2':
                // Subworkflow: Align reads to contaminant genome with bowtie2 and build index if necessary
                ContamBowtie2(
                    ch_readsContaminant,
                    contaminant,
                    params.contaminant
                )
                ch_samContaminant = ContamBowtie2.out.sam
                break
            
            case 'hisat2':
                // Subworkflow: Align reads to contaminant genome with hisat2 and build index if necessary
                ContamHisat2(
                    ch_readsContaminant,
                    contaminant,
                    params.contaminant
                )
                ch_samContaminant = ContamHisat2.out.sam
                break
        }

        // Get contaminant alignment stats
        ContaminantStatsQC(
            ch_samContaminant,
            inName
        )
        ch_contaminantFlagstat = ContaminantStatsQC.out.samtoolsFlagstat
    } else {
        ch_contaminantFlagstat = Channel.empty()
    }

    /*
    ---------------------------------------------------------------------
        Dataset stats
    ---------------------------------------------------------------------
    */

    // Preseq
    if (!params.skipPreseq) {
        Preseq(
            ch_bamGenome
        )
        ch_preseqLcExtrap = Preseq.out.psL
        ch_psRealCounts   = Preseq.out.psRealCounts
    } else {
        ch_preseqLcExtrap = Channel.empty()
        ch_psRealCounts   = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Full pipeline MultiQC
    ---------------------------------------------------------------------
    */

    ch_fullMultiQC = Channel.empty()
        .concat(ch_rawReadsFQC)
        .concat(ch_trimReadsFQC)
        .concat(ch_alignGenomeStats)
        .concat(ch_alignGenomeIdxstats)
        .concat(ch_alignGenomeStatsIS)
        .concat(ch_alignGenomePctDup)
        .concat(ch_contaminantFlagstat)
        .concat(ch_preseqLcExtrap)
        .concat(ch_psRealCounts)

    FullMultiQC(
        inName,
        ch_multiqcConfig,
        ch_fullMultiQC.collect()
    )
}
