# Tool Abbreviations

## Purpose

One of the key purposes of `SRAlign` (and pipelines built on `SRAlign`) is to simplify analysis.
Part of this simplification is making it easy to keep track of how each file has been produced, i.e. which tools were used to produce a file. 
In order to keep track of the steps for producing a file, this pipeline uses abbreviations appended onto file names to encode the tools used to produce each file.
Each major step is encoded in a brief, unique identifier.

## List of unique tool identifiers

### Trim reads

#### `fastp`

`fastp` - `fsp`

### Align reads

Note: For `SRAlign` (and pipelines built on `SRAlign`), the alignment tool is followed by a hyphen and the genome name (e.g. for reads aligned to the hg19 genome by `bowtie2`, the abbreviation would be `bt2-hg19`).

#### `bowtie2`

`bowtie2` - `bt2`

#### `HISAT2`

`HISAT2` - `ht2`

### SAM and BAM processing

#### `samtools`

`samtools` - `s`
* `sort` - `SR` - (`sSR`)
* `stats` - `ST` - (`sST`)
* `idxstat` - `IX-idxstat` - (`sIX-idxstat`)
* This seems nonsensical, but MultiQC requires "idxstat" to be in the file name for recognition of the file.

### Alignments QC and analysis

#### `preseq`

`preseq` - `ps`
* `lc_extrap` - `L`

### Miscellaneous

#### `seqtk`

`seqtk` - `sk`
* `sample` - `S`
