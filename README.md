# Microbial genome editing analysis

Reproducible analysis of a microbial genome-editing experiment. Whole-genome sequencing (WGS) is used to confirm the intended gene mutation and identify additional variants. Paired-end RNA sequencing (RNA-seq) is used to assess whether the mutation changes expression of the target gene.

## Study design

The study contains six biological samples, each sequenced in two replicates:

| Group | Samples | Replicates | Assay |
| --- | --- | --- | --- |
| Mutated | `mut_01`, `mut_02`, `mut_03` | 2 each | WGS and RNA-seq |
| Control | `ctrl_01`, `ctrl_02`, `ctrl_03` | 2 each | WGS and RNA-seq |

The complete library manifest is [config/samplesheet.csv](config/samplesheet.csv). It contains 24 paired-end libraries: 12 WGS libraries and 12 RNA-seq libraries.

The primary analysis questions are:

1. Is the intended mutation present in the mutated samples and absent from the controls?
2. Are there additional high-confidence variants that could confound interpretation?
3. Is the mutated gene expressed differently from the control condition?
4. Do technical QC issues affect confidence in any of these conclusions?

## Repository layout

```text
.
├── config/samplesheet.csv       Library metadata and input paths
├── data/README.md               External data requirements
├── main.nf                      Nextflow DSL2 entry point
├── modules/local/               QC, alignment, variant, and counting processes
├── nextflow.config              Container and runtime configuration
└── reports/multiqc_report.html  QC report for the analysis record
```

## Input data

Raw sequencing data and reference files are managed outside Git. They must be staged at the following paths before execution:

- `data/fastq/`: paired FASTQ files named in the sample sheet
- `data/reference/microbial_reference.fasta`: the exact reference genome used for alignment and variant calling
- `data/reference/microbial_annotation.gtf`: the annotation used for RNA-seq feature counting

The reference genome and annotation should be versioned or checksummed in the data-management system used for the project. No raw reads, reference genome, or annotation are committed to this repository.

## Workflow

The workflow is implemented in [main.nf](main.nf) and runs these stages:

1. FastQC and fastp assess and trim each paired-end library.
2. WGS reads are aligned with BWA-MEM.
3. RNA-seq reads are aligned with HISAT2.
4. SAM files are converted, sorted, and indexed with samtools.
5. WGS alignments are used for small-variant calling with bcftools.
6. RNA-seq alignments are summarized against the GTF with featureCounts.

The WGS and RNA-seq branches remain separate after preprocessing so that variant calling is never applied to transcriptomic reads and expression counting is never applied to genomic reads.

## Running the analysis

Requirements:

- Nextflow `>=23.10.0`
- Docker
- Access to the staged input data and reference files

Run the complete workflow with:

```bash
nextflow run main.nf -profile docker \
  --samplesheet config/samplesheet.csv \
  --reference data/reference/microbial_reference.fasta \
  --annotation data/reference/microbial_annotation.gtf \
  --outdir results
```

Nextflow publishes process outputs beneath `results/`. The work directory and the `.nextflow/` metadata directory should not be treated as analysis deliverables; retain the Nextflow execution report and trace when archiving a run.

## Quality control

The recorded QC review identified two libraries requiring follow-up:

| Library | Finding | Decision |
| --- | --- | --- |
| `ctrl_03_rnaseq_rep2` | 15% adapter contamination | Trim, confirm read retention and insert-size distribution, then reassess before interpreting expression results |
| `mut_02_wgs_rep1` | Unusually low library complexity with 68.7% duplication | Compare with the paired replicate, inspect coverage uniformity, and treat allele-frequency estimates cautiously |

The report is available at [reports/multiqc_report.html](reports/multiqc_report.html). It is a static analysis record for this repository and is explicitly labeled as synthetic presentation output because the underlying sequencing files are not stored here. A data-backed run should regenerate the report from the QC outputs:

```bash
multiqc results/qc -o results/multiqc
```

QC warnings must be resolved or documented before accepting a mutation call or reporting a differential-expression result. A passing summary does not replace review of coverage at the engineered locus, replicate concordance, or the biological plausibility of the result.

## Outputs

Expected deliverables include:

- FastQC and fastp reports for every library
- Trimmed FASTQ files
- Sorted and indexed WGS and RNA-seq BAM files
- Compressed and indexed VCF files for WGS libraries
- featureCounts tables for RNA-seq libraries
- A MultiQC report and Nextflow execution metadata

The current pipeline is an analysis scaffold: it defines the processing structure and expected locations, but it does not include input data or claim biological conclusions until a real run has been executed and reviewed.

## Reproducibility and provenance

Container image versions are pinned in [nextflow.config](nextflow.config). For each production run, record:

- the Git commit used for execution
- the Nextflow version and profile
- checksums or accession identifiers for input files
- the reference and annotation versions
- the Nextflow trace, report, and execution timeline
- the analyst disposition of all QC warnings

Results should be interpreted together with the run metadata and QC review, rather than copied between analyses without their provenance.
