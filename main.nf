nextflow.enable.dsl=2

include { FASTQC } from './modules/local/qc'
include { FASTP } from './modules/local/qc'
include { WGS_ALIGN } from './modules/local/wgs'
include { RNA_ALIGN } from './modules/local/rnaseq'
include { SAMTOOLS_SORT_INDEX } from './modules/local/alignment'
include { VARIANT_CALLING } from './modules/local/wgs'
include { FEATURE_COUNTS } from './modules/local/rnaseq'

workflow {
    samples = Channel.fromPath(params.samplesheet, checkIfExists: true)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, row.assay, row.condition, row.replicate as Integer, file(row.fastq_r1), file(row.fastq_r2)) }

    read_pairs = samples.map { sample_id, assay, condition, replicate, read1, read2 ->
        tuple("${sample_id}_${assay}_rep${replicate}", sample_id, assay, condition, replicate, read1, read2)
    }

    FASTQC(read_pairs.map { library_id, sample_id, assay, condition, replicate, read1, read2 -> tuple(library_id, read1, read2) })
    FASTP(read_pairs)

    wgs_reads = FASTP.out.trimmed.filter { it[2] == 'wgs' }
    rnaseq_reads = FASTP.out.trimmed.filter { it[2] == 'rnaseq' }

    WGS_ALIGN(wgs_reads, file(params.reference))
    RNA_ALIGN(rnaseq_reads, file(params.reference))
    SAMTOOLS_SORT_INDEX(WGS_ALIGN.out.bam.mix(RNA_ALIGN.out.bam))
    VARIANT_CALLING(SAMTOOLS_SORT_INDEX.out.bam.filter { it[1] == 'wgs' }, file(params.reference))
    FEATURE_COUNTS(SAMTOOLS_SORT_INDEX.out.bam.filter { it[1] == 'rnaseq' }, file(params.annotation))
}