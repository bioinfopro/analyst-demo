# Microbial genomics analyst demo

This repository is a demo mock-up for a bioinformatics analyst certification and its companion tally form. It models an experiment in which a microbial gene has been mutated and the team uses whole-genome sequencing (WGS) to confirm the edit and RNA-seq to assess expression of the mutated gene.

## Experiment design

- Three mutated biological samples: `mut_01`, `mut_02`, `mut_03`
- Three control biological samples: `ctrl_01`, `ctrl_02`, `ctrl_03`
- Two replicates per biological sample
- Two assays per replicate: WGS and RNA-seq
- Twelve sequencing libraries per assay-independent sample sheet: 24 FASTQ pairs total across both assays

The sample sheet is [config/samplesheet.csv](config/samplesheet.csv). It deliberately contains file paths only; no sequencing data is committed.

## Data location

Put paired FASTQ files at `data/fastq/` using the paths in the sample sheet. Put the reference genome at `data/reference/microbial_reference.fasta` and the gene annotation at `data/reference/microbial_annotation.gtf`. These locations are placeholders and are intentionally empty in this demo.

## Run the mock pipeline

The pipeline uses standard command-line tools through a Docker profile:

```bash
nextflow run main.nf -profile docker \
  --samplesheet config/samplesheet.csv \
  --reference data/reference/microbial_reference.fasta \
  --annotation data/reference/microbial_annotation.gtf
```

The pipeline expects real input files and will stop with a clear error if they are absent. It does not generate or download mock reads.

## QC scenario

[reports/multiqc_report.html](reports/multiqc_report.html) is a static, synthetic report for the certification scenario. It shows one library with 15% adapter contamination and one library with unusually low complexity. It is presentation material, not a result generated from committed sequencing data.

For a real run, replace the presentation report with the output of:

```bash
multiqc results/qc -o results/multiqc
```
