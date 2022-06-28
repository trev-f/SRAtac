/*
=====================================================================
    SRAlign WORKFLOW
=====================================================================
*/

/*
    ---------------------------------------------------------------------
    Tools
    ---------------------------------------------------------------------
*/

def tools = [
    mergePeaks : ['homer']
]

// check valid peak merging tool
assert params.mergePeaksTool in tools.mergePeaks,
    "'${params.mergePeaksTool} is not a valied peak-merging tool.\n\tValid options: ${tools.mergePeaks.join(', ')}\n\t'"

/*
This object takes care of many necessary steps upon construction:
    - Logs a header for the pipeline that prints pipeline name and logo
    - Prints a help message if help parameter is specified
    - Checks parameters
*/ 
def srawf = new SRAlignWorkflow(log, params, workflow)


/*
    ---------------------------------------------------------------------
    Set useful pipeline values
    ---------------------------------------------------------------------
*/

// set output filename base prefix
outBasePrefix   = srawf.outBasePrefix
outUniquePrefix = srawf.outUniquePrefix

// set genome and contaminant values
genome = params.genomes[ params.genome ]
contaminant = params.genomes[ params.contaminant ]

/*
    ---------------------------------------------------------------------
    Import modules
    ---------------------------------------------------------------------
*/

include { SambambaFilterBam     as SambambaFilterBam  } from "${baseDir}/modules/align/SambambaFilterBam.nf"
include { BamCoverage           as BamCoverage        } from "${baseDir}/modules/coverage/BamCoverage.nf"
include { CallPeaksMacs2SWF     as CallPeaksMacs2     } from "${baseDir}/subworkflows/peaks/CallPeaksMacs2SWF.nf"
include { MergePeaksHomer       as MergePeaksHomer    } from "${baseDir}/modules/peaks/MergePeaksHomer.nf"
include { ConvertMergedPeaks    as ConvertMergedPeaks } from "${projectDir}/modules/peaks/ConvertMergedPeaks.nf"
include { ParseDesignSWF        as ParseDesign        } from "${projectDir}/subworkflows/inputs/ParseDesignSWF.nf"
include { FastpTrimReadsSWF     as FastpTrimReads     } from "${projectDir}/subworkflows/reads/FastpTrimReadsSWF.nf"
include { ReadsQCSWF            as ReadsQC            } from "${projectDir}/subworkflows/reads/ReadsQCSWF.nf"
include { Bowtie2SWF            as Bowtie2Genome      ; 
          Bowtie2SWF            as Bowtie2Contaminant } from "${projectDir}/subworkflows/align/Bowtie2SWF.nf"
include { Hisat2SWF             as Hisat2Genome       ; 
          Hisat2SWF             as Hisat2Contaminant  } from "${projectDir}/subworkflows/align/Hisat2SWF.nf"
include { PostprocessSamSWF     as PostprocessSam     } from "${projectDir}/subworkflows/align/PostprocessSamSWF.nf"
include { AlignmentStatsQCSWF   as AlignmentStatsQC   } from "${projectDir}/subworkflows/align/AlignmentStatsQCSWF.nf"
include { SeqtkSample           as SeqtkSample        } from "${projectDir}/modules/reads/SeqtkSample.nf"
include { ContaminantStatsQCSWF as ContaminantStatsQC } from "${projectDir}/subworkflows/align/ContaminantStatsQCSWF.nf"
include { PreseqSWF             as Preseq             } from "${projectDir}/subworkflows/complexity/PreseqSWF.nf"
include { DeepToolsMultiBamSWF  as DeepToolsMultiBam  } from "${projectDir}/subworkflows/align/DeepToolsMultiBamSWF.nf"
include { FeatureCountsSWF      as FeatureCounts      } from "${projectDir}/subworkflows/counts/FeatureCountsSWF.nf"
include { FullMultiQC           as FullMultiQC        } from "${projectDir}/modules/misc/FullMultiQC.nf"


workflow SRAtac {
    /*
    ---------------------------------------------------------------------
        Read design file, parse sample names and identifiers, and stage reads files
    ---------------------------------------------------------------------
    */

    // set channel for input design file
    ch_input = file(params.input)

    // Subworkflow: Parse design file
    ParseDesign(
        ch_input
    )
    ch_readsRaw         = ParseDesign.out.reads
    ch_bamIndexedGenome = ParseDesign.out.bamBai


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
                FastpTrimReads(
                    ch_readsRaw
                )
                ch_readsTrimmed = FastpTrimReads.out.readsTrimmed
                break
        }
    } else {
        ch_readsTrimmed = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Reads QC
    ---------------------------------------------------------------------
    */

    if (!params.skipReadsQC) {
        // Subworkflow: FastQC and MulitQC for raw and trimmed reads
        ReadsQC(
            ch_readsRaw,
            ch_readsTrimmed,
            outUniquePrefix
        )
        ch_readsRawFQC     = ReadsQC.out.raw_fqc_zip
        ch_readsTrimmedFQC = ReadsQC.out.trim_fqc_zip
    } else {
        ch_readsRawFQC     = Channel.empty()
        ch_readsTrimmedFQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Align reads to genome
    ---------------------------------------------------------------------
    */

    // Set channel of reads to align 
    if (!params.forceAlignRawReads) {
        if (!params.skipTrimReads) {
            ch_readsToAlign = ch_readsTrimmed
        } else {
            ch_readsToAlign = ch_readsRaw
        }
    } else {
        ch_readsToAlign = ch_readsRaw
    }


    if (!params.skipAlignGenome) {
        ch_samGenome = Channel.empty()
        // Align reads to genome
        switch (params.alignmentTool) {
            case 'bowtie2':
                // Subworkflow: Align reads to genome with bowtie2 and build index if necessary
                Bowtie2Genome(
                    ch_readsToAlign,
                    genome,
                    params.genome
                )
                ch_samGenome = Bowtie2Genome.out.sam
                break
            
            case 'hisat2':
                // Subworkflow: Align reads to genome with hisat2 and build index if necessary
                Hisat2Genome(
                    ch_readsToAlign,
                    genome,
                    params.genome,
                    params.forceUseHisat2Index,
                    params.buildSpliceAwareIndex
                )
                ch_samGenome = Hisat2Genome.out.sam
                break
    }

    // Postprocess sam files: mark duplicates, sort alignments, compress to bam, and index
    PostprocessSam(
        ch_samGenome
    )
    ch_bamIndexedGenome = PostprocessSam.out.bamIndexed.mix(ch_bamIndexedGenome)


    if (!params.skipAlignmentStatsQC) {
        // Subworkflow: Samtools stats and samtools idxstats and multiqc of alignment results
        AlignmentStatsQC(
            ch_bamIndexedGenome,
            outUniquePrefix
        )
        ch_alignGenomeStats    = AlignmentStatsQC.out.samtoolsStats
        ch_alignGenomeIdxstats = AlignmentStatsQC.out.samtoolsIdxstats
        ch_alignGenomeStatsIS  = AlignmentStatsQC.out.samtoolsStatsIS
        ch_alignGenomePctDup   = AlignmentStatsQC.out.pctDup
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
                Bowtie2Contaminant(
                    ch_readsContaminant,
                    contaminant,
                    params.contaminant
                )
                ch_samContaminant = Bowtie2Contaminant.out.sam
                break
            
            case 'hisat2':
                // Subworkflow: Align reads to contaminant genome with hisat2 and build index if necessary
                Hisat2Contaminant(
                    ch_readsContaminant,
                    contaminant,
                    params.contaminant,
                    params.forceUseHisat2Index,
                    false
                )
                ch_samContaminant = Hisat2Contaminant.out.sam
                break
        }

        // Get contaminant alignment stats
        ContaminantStatsQC(
            ch_samContaminant,
            outUniquePrefix
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
            ch_bamIndexedGenome
        )
        ch_preseqLcExtrap = Preseq.out.psL
    } else {
        ch_preseqLcExtrap = Channel.empty()
    }

    // deepTools
    ch_alignments = ch_bamIndexedGenome
    ch_alignmentsCollect = 
        ch_alignments
        .multiMap {
            it ->
            bam:     it[1]
            bai:     it[2]
            toolIDs: it[3]
        }

    DeepToolsMultiBam(
        ch_alignmentsCollect.bam.collect(),
        ch_alignmentsCollect.bai.collect(),
        outBasePrefix
    )
    ch_corMatrix = DeepToolsMultiBam.out.corMatrix
    ch_PCAMatrix = DeepToolsMultiBam.out.PCAMatrix


    /*
    ---------------------------------------------------------------------
        Filter uninformative reads
    ---------------------------------------------------------------------
    */

    // Sambamba Filter
    if (!params.skipFilterBam) {
        SambambaFilterBam(
            ch_bamIndexedGenome,
            params.mappingQualityThreshold,
            genome[ 'mitoChr' ]
        )
        ch_bamFilteredIndexedGenome = SambambaFilterBam.out.bamBai
    } else {
        ch_bamFilteredIndexedGenome = Channel.empty()
    }

    // Create alignments channel to use for other analyses, i.e. filtered or unfiltered alignments?
    if (!params.skipFilterBam && !params.forceUnfilteredBam) {
        ch_alignments = ch_bamFilteredIndexedGenome
    } else {
        ch_alignments = ch_bamIndexedGenome
    }

    /*
    ---------------------------------------------------------------------
        Bam coverage to bigWig
    ---------------------------------------------------------------------
    */

    if (!params.skipBamCoverage) {
        BamCoverage(
            ch_alignments,
            params.binSize,
            params.normMethod
        )
    }

    /*
    ---------------------------------------------------------------------
        Peak calling and peaks analysis
    ---------------------------------------------------------------------
    */

    // call peaks
    if (!params.skipPeakCalling) {      // call peaks unless skip option selected
        CallPeaksMacs2(
            ch_alignments,
            genome[ 'effectiveGenomeSize' ]
        )
        ch_peaksNarrowPeak = CallPeaksMacs2.out.narrowPeak
        ch_peaksXls        = CallPeaksMacs2.out.xls
    } else {                            // create empty channels if call peaks skipped
        ch_peaksNarrowPeak = Channel.empty()
        ch_peaksXls        = Channel.empty()
    }

    // collect peaks files
    ch_peaksCollect =
        ch_peaksNarrowPeak
        .multiMap {
            it ->
            peaks:   it[1]
            toolIDs: it[2]
        }
        
    ch_peaksCollect
        .peaks
        .collect()
        .set { ch_peaksCollectPeaks }

    ch_peaksCollect
        .toolIDs
        .first()
        .set { ch_peaksCollectToolIDs }

    ch_peaksCollect
        .peaks
        .collect()
        .combine(ch_peaksCollect.toolIDs)

    if (!params.skipMergePeaks) {
        switch (params.mergePeaksTool) {
            // merge peaks with homer merge peaks
            case 'homer':
                MergePeaksHomer(
                    ch_peaksCollectPeaks,
                    ch_peaksCollectToolIDs,
                    outBasePrefix,
                    genome[ 'effectiveGenomeSize' ]
                )
                ch_mergePeaks = MergePeaksHomer.out.mergePeaks
                break
        }
    }

    // convert merged peaks
    ConvertMergedPeaks(
        ch_mergePeaks,
        outBasePrefix,
        params.mergePeaksTool
    )
    ch_mergePeaksSAF = ConvertMergedPeaks.out.mergedPeaks


    /*
    ---------------------------------------------------------------------
        Reads counts matrix
    ---------------------------------------------------------------------
    */

    // produce reads counts matrix
    ch_alignmentsCollect = 
        ch_alignments
        .multiMap {
            it ->
            bam:     it[1]
            bai:     it[2]
            toolIDs: it[3]
        }
    
    FeatureCounts(
        ch_alignments,
        ch_mergePeaksSAF
    )
    ch_countsFeatureCounts  = FeatureCounts.out.countsFeatureCounts
    ch_summaryFeatureCounts = FeatureCounts.out.summaryFeatureCounts

    /*
    ---------------------------------------------------------------------
        Full pipeline MultiQC
    ---------------------------------------------------------------------
    */

    ch_fullMultiQC = Channel.empty()
        .concat(ch_readsRawFQC)
        .concat(ch_readsTrimmedFQC)
        .concat(ch_alignGenomeStats)
        .concat(ch_alignGenomeIdxstats)
        .concat(ch_alignGenomeStatsIS)
        .concat(ch_alignGenomePctDup)
        .concat(ch_contaminantFlagstat)
        .concat(ch_preseqLcExtrap)
        .concat(ch_peaksXls)
        .concat(
            ch_countsFeatureCounts
                .map {
                    it[0]
                }
        )
        .concat(ch_corMatrix)
        .concat(ch_PCAMatrix)
    
    // set channel for MultiQC config file
    ch_multiqcConfig = file(params.multiqcConfig)

    FullMultiQC(
        outUniquePrefix,
        ch_multiqcConfig,
        ch_fullMultiQC.collect()
    )
}
