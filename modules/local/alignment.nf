process SAMTOOLS_SORT_INDEX {
    tag "$library_id"
    input:
    tuple val(library_id), val(assay), path(sam)

    output:
    tuple val(library_id), val(assay), path("${library_id}.sorted.bam"), emit: bam

    script:
    """
    samtools view -bS ${sam} | samtools sort -o ${library_id}.sorted.bam
    samtools index ${library_id}.sorted.bam
    """
}