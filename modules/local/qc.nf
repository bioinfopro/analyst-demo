process FASTQC {
    tag "$library_id"
    input:
    tuple val(library_id), path(read1), path(read2)

    output:
    tuple val(library_id), path('*.zip'), path('*.html'), emit: reports

    script:
    """
    fastqc --threads 2 ${read1} ${read2}
    """
}

process FASTP {
    tag "$library_id"
    publishDir "${params.outdir}/trimmed", mode: 'copy'
    input:
    tuple val(library_id), val(sample_id), val(assay), val(condition), val(replicate), path(read1), path(read2)

    output:
    tuple val(library_id), val(sample_id), val(assay), val(condition), val(replicate), path("${library_id}_R1.trimmed.fastq.gz"), path("${library_id}_R2.trimmed.fastq.gz"), emit: trimmed
    path "${library_id}.fastp.json", emit: json
    path "${library_id}.fastp.html", emit: html

    script:
    """
    fastp \\
      --in1 ${read1} --in2 ${read2} \\
      --out1 ${library_id}_R1.trimmed.fastq.gz \\
      --out2 ${library_id}_R2.trimmed.fastq.gz \\
      --json ${library_id}.fastp.json --html ${library_id}.fastp.html \\
      --thread 2
    """
}