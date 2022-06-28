/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-06-28
Purpose: Count number of reads in peaks
*/

include { FeatureCounts } from "${projectDir}/modules/counts/FeatureCounts.nf"

workflow FeatureCountsSWF {
    take:
        bamIndexed
        mergedPeaks

    main:
        FeatureCounts(
            bamIndexed,
            mergedPeaks
        )

    emit:
        countsFeatureCounts  = FeatureCounts.out.featCounts
        summaryFeatureCounts = FeatureCounts.out.featCountsSummary
}
