process RNA_ALIGN {
    tag "$library_id"
    input:
    tuple val(library_id), val(sample_id), val(assay), val(condition), val(replicate), path(read1), path(read2)
    path reference

    output:
    tuple val(library_id), val(assay), path("${library_id}.sam"), emit: bam

    script:
    """
    hisat2-build ${reference} reference_index
    hisat2 -p 2 -x reference_index -1 ${read1} -2 ${read2} -S ${library_id}.sam
    """
}

process FEATURE_COUNTS {
    tag "$library_id"
    input:
    tuple val(library_id), val(assay), path(bam)
    path annotation

    output:
    path "${library_id}.featureCounts.txt", emit: counts

    script:
    """
    featureCounts -T 2 -a ${annotation} -o ${library_id}.featureCounts.txt ${bam}
    """
}