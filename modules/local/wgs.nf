process WGS_ALIGN {
    tag "$library_id"
    input:
    tuple val(library_id), val(sample_id), val(assay), val(condition), val(replicate), path(read1), path(read2)
    path reference

    output:
    tuple val(library_id), val(assay), path("${library_id}.sam"), emit: bam

    script:
    """
    bwa mem -t 2 ${reference} ${read1} ${read2} > ${library_id}.sam
    """
}

process VARIANT_CALLING {
    tag "$library_id"
    input:
    tuple val(library_id), val(assay), path(bam)
    path reference

    output:
    path "${library_id}.vcf.gz", emit: variants

    script:
    """
    samtools mpileup -Ou -f ${reference} ${bam} | bcftools call -mv -Oz -o ${library_id}.vcf.gz
    bcftools index ${library_id}.vcf.gz
    """
}