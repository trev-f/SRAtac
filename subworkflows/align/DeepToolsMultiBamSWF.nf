include { DeepToolsMultiBamSummary } from "${projectDir}/modules/align/DeepToolsMultiBamSummary.nf"

workflow DeepToolsMultiBamSWF {
    take:
        bams
        bais
        prefix
    
    main:
        DeepToolsMultiBamSummary(
            bams,
            bais,
            prefix
        )
    
    emit:
        corMatrix = DeepToolsMultiBamSummary.out.corMatrix
        PCAMatrix = DeepToolsMultiBamSummary.out.PCAMatrix
}
