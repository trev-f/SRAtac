/*
Author : Trevor F. Freeman <trvrfreeman@gmail.com>
Date   : 2022-02-27
Purpose: Nextflow module
*/

process SamtoolsStatsIdxstats {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    publishDir "${params.baseDirData}/align/stats", mode: 'copy', pattern: '*.txt'

    input:
        tuple val(metadata), path(bam), path(bai), val(toolIDs)

    output:
        path '*_sST.txt', emit: sST
        path '*_sIX-idxstat.txt', emit: sIX
        path '*sST-IS.txt', emit: sSTIS
        path '*_pctDup.txt', emit: pctDup
        val toolIDs, emit: tools

    script:
        // update toolID and set suffix
        toolIDsST = toolIDs
        toolIDsST += 'sST'
        suffixsST = toolIDsST ? "__${toolIDsST.join('_')}" : ''

        toolIDsIX = toolIDs
        toolIDsIX += 'sIX-idxstat'
        suffixsIX = toolIDsIX ? "__${toolIDsIX.join('_')}" : ''

        toolIDsSTIS = toolIDs
        toolIDsSTIS += 'sST-IS'
        suffixsSTIS = toolIDsSTIS ? "__${toolIDsSTIS.join('_')}" : ''

        toolIDspd = toolIDs
        toolIDspd += 'pctDup'
        suffixspd = toolIDspd ? "__${toolIDspd.join('_')}" : ''

        toolIDs += ['sST', 'sIX-idxstat']

        """
        samtools stats ${bam} > ${metadata.sampleName}${suffixsST}.txt
        samtools idxstats ${bam} > ${metadata.sampleName}${suffixsIX}.txt

        # extract insert sizes
        grep ^IS ${metadata.sampleName}${suffixsST}.txt \
            | cut -f 2,3 \
            > ${metadata.sampleName}${suffixsSTIS}.txt

        # extract number of mapped reads
        MAPPED=\$( \
            grep ^SN ${metadata.sampleName}${suffixsST}.txt \
            | cut -f 2- \
            | grep 'reads mapped:' \
            | cut -f 2)
        # extract number of duplicate reads
        DUPPED=\$( \
            grep ^SN ${metadata.sampleName}${suffixsST}.txt \
            | cut -f 2- \
            | grep 'reads duplicated:' \
            | cut -f 2)
        # calculate percent of duplicated reads
        PCTDUP=\$(awk -v MAPPED=\$MAPPED -v DUPPED=\$DUPPED 'BEGIN{print DUPPED / MAPPED * 100}')
        echo -e "${metadata.sampleName}${suffixspd}\t\$PCTDUP" > ${metadata.sampleName}${suffixspd}.txt
        """
    
    stub:
        // update toolID and set suffix
        toolIDsST = toolIDs
        toolIDsST += 'sST'
        suffixsST = toolIDsST ? "__${toolIDsST.join('_')}" : ''

        toolIDsIX = toolIDs
        toolIDsIX += 'sIX-idxstat'
        suffixsIX = toolIDsIX ? "__${toolIDsIX.join('_')}" : ''

        toolIDspd = toolIDs
        toolIDspd += 'pctDup'
        suffixspd = toolIDspd ? "__${toolIDspd.join('_')}" : ''

        toolIDs += ['sST', 'sIX-idxstat']

        """
        touch ${metadata.sampleName}${suffixsST}.txt
        touch ${metadata.sampleName}${suffixsIX}.txt
        touch ${metadata.sampleName}${suffixspd}.txt
        """
}
