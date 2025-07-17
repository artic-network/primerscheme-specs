#import "@preview/pubmatter:0.2.1"

#show link: underline
#set highlight(fill: luma(230), radius: 2pt, bottom-edge: -2pt, top-edge: "ascender")
#set page(numbering: "1")
#set heading(numbering: "1.")
#set text(region: "GB")

#let bp_str = block(
  "Best practices are not required by the specification, however are strongly recommend.",
  fill: rgb(35, 157, 173, 20%),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  breakable: false,
)

#let fm = pubmatter.load((
  author: (
    (
      name: "Christopher Kent",
      email: "chrisgkent@protonmail.com",
      orcid: "0000-0002-7859-8394",
      affiliations: (
        "The ARTICnetwork Collaborative Award",
        "Institute of Microbiology and Infection, University of Birmingham, Birmingham, UK.",
      ),
      url: "https://github.com/ChrisgKent",
    ),
    (
      name: "Bede Constantinides",
      orcid: "0000-0002-3480-3819",
      affiliations: (
        "The ARTICnetwork Collaborative Award",
        "Institute of Microbiology and Infection, University of Birmingham, Birmingham, UK.",
      ),
    ),
  ),
  title: "ARTIC primer scheme specification v3.0.0-alpha",
  date: datetime(year: 2025, month: 07, day: 14),
  abstract: [Polymerase chain reaction (PCR) followed by amplicon DNA sequencing enables fast, sensitive and cost-effective molecular characterisation of target genes and genomes.
    PCR involves the selective amplification of a target genomic region (amplicons) using pairs of single-stranded oligonucleotide primers, complementary to opposing strands flanking the target region. Multiple regions can be simultaneously amplified in a single reaction via multiplexed PCR, with multiple reactions enabling tiling amplicon sequencing (ARTIC sequencing), facilitating efficient enrichment of entire microbial genomes for whole genome sequencing. However, accurately reproducing a primer scheme and the corresponding bioinformatic analysis of amplicon sequencing data depends on knowledge of primer sequences, amplicon layout, and their coordinates with respect to a reference sequence. Analysis and reuse of amplicon sequencing data is currently hindered by the lack of a clearly defined data interchange format for primer scheme definitions, a problem highlighted by the proliferation of SARS-CoV-2 primer schemes during the COVID-19 pandemic. Here, we describe a text-based specification for describing primer sequences and locations with respect to a reference sequence. This specification formalises and expands on the existing interchange format initially used in the PrimalScheme primer design tool, and since adopted by a growing ecosystem of tooling. This specification designates the use of a primer.bed file, based on the Browser Extensible Data (BED) text format, and an accompanying reference.fasta text file for defining primer schemes, and probe-based qPCR assays.
    This specification is intended to facilitate the exchange of primer scheme definitions for oligonucleotide synthesis, wet-lab and bioinformatic analysis use cases.],
  keywords: ("Data standards", "Primer Schemes", "Amplicon Sequencing"),
))

#let theme = (color: black.darken(20%), font: "Noto Sans")
#state("THEME").update(theme)
#set page(header: pubmatter.show-page-header(fm), footer: pubmatter.show-page-footer(fm))


#pubmatter.show-title-block(fm)
#pubmatter.show-abstract-block(fm)

#outline(indent: auto)

#pagebreak()

= primer.bed file
A primer.bed file describes a primer scheme in machine and human readable tabular format. Together with an accompanying reference.fasta, its purpose is to encapsulate all of the information needed to _i)_ acquire the primers from suppliers or custom oligonucleotide synthesis, _ii)_ combine the primers correctly to reproduce a pooled primer scheme, and _iii)_ facilitate correct and reproducible bioinformatic analysis of resulting sequencing data. It therefore incorporates both wet lab and analytical elements. This information includes primer sequences, primer pools, coordinates and orientation with respect to a reference sequence, and optionally relative primer concentrations.

== Format overview

`primer.bed` files are tab-delimited ASCII text files. Each line can either represent a _comment line_ (prefixed with "`#`") or a _record line_ (`BedLine`), representing a single unique oligonucleotide primer or probe associated with an amplicon. An amplicon comprises at least two primer record lines each describing primers on different strands.

The format of `primer.bed` is based on Browser Extensible Data (#link("https://samtools.github.io/hts-specs/BEDv1.pdf")[BED]) specification, with each oligonucleotide being treated as a genomic region, enabling compatibility with common BED file tooling.

== Comment Line

Comment lines are minimally parsed, but can optionally contain a scheme-level (key, value) pair. To this end, comment lines containing a single "`=`" will be split, with the left and right sides representing a scheme-level key and value respectively.

== record line (BedLine) field descriptions

#figure(
  table(
    columns: 5,
    align: (left, left, left, left, right),
    table.header[*Column*][*Field name*][*Type*][*Brief description*][*Restrictions*],
    [1], [chrom], [String], [Chromosome name], [`[A-Za-z0-9._]`],
    [2], [primerStart], [Integer], [Primer start position (zero-based, half-open)], [Positive integer (`u64`)],
    [3], [primerEnd], [Integer], [Primer end position (zero-based, half-open)], [Positive integer (`u64`)],
    [4], [primerName], [String], [Primer name], [`[a-zA-Z0-9\-]
    +_[0-9]+_(LEFT|RIGHT|PROBE)_[0-9]+`],
    [5], [pool], [Integer], [Primer pool], [Positive integer (`u64`)],
    [6], [strand], [String], [Primer strand], [`[-+]`],
    [7], [primerSeq], [String], [The nucleotide sequence in 5'#sym.arrow.r 3'], [ASCII non-whitespace characters],
    [8],
    [primerAttributes],
    [Optional(String)],
    [List of record-level (key, value) pairs separated by \`;\`. e.g. `k1=v1;k2=v2`],
    [ASCII non-whitespace characters],
  ),
  caption: [The column structure and description of a BedLine],
)


=== #highlight[`chrom`]
The name of the corresponding reference sequence chromosome for the primer. This must match a valid sequence ID inside an accompanying reference sequence FASTA file, by convention named `reference.fasta`.

=== #highlight[`primerStart`]
The start position of the primer on the `chrom` using BED-like zero-based, half-open coordinates.

=== #highlight[`primerEnd`]
The non-inclusive end position of the primer on the `chrom` using BED-like zero-based, half-open coordinates. Must be greater than #highlight[`primerStart`].

=== #highlight[`primerName`]
The name of the primer in the form "`{prefix}_{ampliconNumber}_{class}_{primerNumber}`".
- #highlight[`prefix`]: Must match regex `[a-zA-Z0-9\-]`. See best practices
- #highlight[`ampliconNumber`]: The number of the amplicon for its relevant #highlight[`chrom`]. Must be a positive integer incrementing from 1.
- #highlight[`primerClass`]: The class of the primer. Must be either `LEFT`, `RIGHT` or `PROBE`.
- #highlight[`primerNumber`]: The number of the primer. Must be a positive integer incrementing from 1.

=== #highlight[`pool`]
The PCR pool the primer belongs to. Must be a positive integer incrementing from 1 #footnote["Existing schemes/literature use refer to \`pool 1 and pool 2\`. Therefore 1-based indexing is expected"].

=== #highlight[`strand`]
The strand of the primer must be either #highlight[+] or #highlight[-]. It must correspond to the #highlight[class] component of the #highlight[primerName] (see the description of #highlight[primerName] above). #highlight[LEFT] and #highlight[RIGHT] primers must be #highlight[+] and #highlight[-] respectively, while #highlight[PROBE] can be either.
=== #highlight[`primerSeq`]
The sequence of the primer in the 5' to 3' direction. Unrestricted to contain any non-whitespace ASCII character #footnote["This is intentionally unrestricted (rather than IUPAC-only) to allow Primer Modification. Such as `/56-FAM/{primerSeq}` to represent 5' 6-FAM fluorescent dye labelled probe"].

=== #highlight[`primerAttributes`]
An *optional* list of a (key, value) pairs used to denote additional arbitrary primer attributes, in the form of #highlight[`pw=1.0;ps=10.0`]. This is intentionally flexible to allow the storage of additional information. In a primer.bed file this can be represented as either an empty 8th column or only 7 columns.

==== Reserved keys

- #highlight[`pw`]: primerWeight. The concentration of individual primers can be altered to balance amplicon performance. Primer concentration in the PCR should be scaled by `primerWeight * [typical PCR conc]`. This is restricted to positive floating point numbers (`f64 > 0`).


== Examples

=== Simple example
A seven column #highlight[`primer.bed`] file, with no #highlight[`primerAttributes`] or `comment lines`.

#block(
  fill: luma(230),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  breakable: false,
  [
    #show raw: set text(size: 8pt)
    ```
    MN908947.3  100 131 example_1_LEFT_1  1 + CTCTTGTAGATCTGTTCTCTAAACGAACTTT
    MN908947.3  419 447 example_1_RIGHT_1 1 - AAAACGCCTTTTTCAACTTCTACTAAGC
    MN908947.3  344 366 example_2_LEFT_1  2 + TCGTACGTGGCTTTGGAGACTC
    MN908947.3  707 732 example_2_RIGHT_1 2 - TCTTCATAAGGATCAGTGCCAAGCT
    ```],
)

=== Complex example
An eight column #highlight[`primer.bed`] file. With #highlight[`primerAttributes`] defined, and `comment lines` providing a #highlight[`chrom`] alias and explaining the #highlight[`gc`] #highlight[`primerAttributes`].
#block(
  fill: luma(230),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  breakable: false,
  [
    #show raw: set text(size: 8pt)
    ```
    # example scheme
    # gc=fraction gc
    # MN908947.3=sars-cov-2
    MN908947.3  100 131 example_1_LEFT_1  1 + CTCTTGTAGATCTGTTCTCTAAACGAACTTT pw=1.4;gc=0.35
    MN908947.3  419 447 example_1_RIGHT_1 1 - AAAACGCCTTTTTCAACTTCTACTAAGC  pw=1.4;gc=0.36
    MN908947.3  344 366 example_2_LEFT_1  2 + TCGTACGTGGCTTTGGAGACTC  pw=1;gc=0.55
    MN908947.3  707 732 example_2_RIGHT_1 2 - TCTTCATAAGGATCAGTGCCAAGCT pw=1;gc=0.44
    ```],
)

=== qPCR example
An eight column #highlight[`primer.bed`] file. Showing a fictional qPCR assay. The specific dyes and quenchers are (optionally) included in the comments lines.
#block(
  fill: luma(230),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  breakable: false,
  [
    #show raw: set text(size: 8pt)
    ```
    # example multiplexed-qPCR assay
    # gc=fraction gc
    # /3BHQ_1/=Black Hole Quencher 1
    # /56-FAM/=FAM
    # /5HEX/=HEX
    target1  2010 2030 iad3_1_LEFT_1  1 + AAAGGTCAGTCAACCCGTTC pw=1
    target1  2035 2060 iad3_1_PROBE_1  1 - /56-FAM/GCGTTGTTCAATTGCCTTGCTGATT/3BHQ_1/  pw=19.1
    target1  2903 2923 iad3_1_RIGHT_1  1 - TCGGGCCACCGCGTATGAAG  pw=1
    target2  5167 5187 rfw1_1_LEFT_1  1 + TCGTAGCATGGACTCGATGA pw=1
    target2  5271 5296 rfw1_1_PROBE_1 1 + /5HEX/TGATCCGCGTTTACTGTTCGACGCG/3BHQ_1/  pw=20.2
    target2  5301 5321 rfw1_1_RIGHT_1 1 - GTTTACCAAGGAACCATCCA  pw=1
    ```],
)

== primer.bed best practices

#bp_str

=== Use dedicated tooling

While CSV parsing modules should be compatible with parsing bedfiles, they do not carry out valuation, and require additional work to parse #highlight[primerAttribute] and #highlight[primerNames]. #link("https://github.com/ChrisgKent/primalbedtools")[`primalbedtools`] is an open source python package that carries out, parsing, schema validation and conversion, and common operations on #highlight[`primer.bed`] files.

=== Use unique names were possible

The #highlight[`prefix`] component of #highlight[`primerName`] should be as unique as possible (ideally a short uuid, i.e. #highlight[`359ba5`]) and different for each #highlight[`chrom`] and each scheme generation run. Using #highlight[`prefix`] such as "scheme" or "sars-cov-2" might seen tempting, however, will result in a freezer / LIMS full of very similar #highlight[`primerName`]s leading to confusion and pooling mistakes. As an example a primer labelled `scheme_1_LEFT_1` could belong to any scheme.

=== The comment lines

The `comment line`'s #highlight[`key=value`] pattern undergoes limited validation in the specification, and therefore tooling should implement robust error handling, and should avoid using the `comment line` for critical metadata. A suitable use case might be to document custom #highlight[`primerAttributes`] or providing human readable aliases for different #highlight[`chrom`]s.


= reference.fasta file
A #highlight[`reference.fasta`] file contains the DNA sequences of all the primary-reference genomes, used in primer scheme generation. Its purpose is to provide a reference genome and coordinate system for use in reference-based assembly and consensus generation.

== Format overview

#highlight[`reference.fasta`] files are typical ASCII-encoded #highlight[`.fasta`] #link("https://en.wikipedia.org/wiki/FASTA_format")[format files], with text representing the nucleotide sequence of the reference. Each genome starts with a header line (starting with #highlight[`>`]) that denotes the id of the genome, followed by lines of nucleotide data.

All #highlight[`chrom`] fields of the record lines must have a corresponding `id` in the #highlight[`reference.fasta`].


== Examples

=== Single fasta

#block(
  fill: luma(230),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  [
    #show raw: set text(size: 8pt)
    ```
    >MN908947.3
    ATTAAAGGTTTATACCTTCCCA...
    ```
  ],
)

The corresponding #highlight[`primer.bed`] file should contain the #highlight[`chrom`] #highlight[`MN908947.3`]

=== Multi fasta
#block(
  fill: luma(230),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  [
    #show raw: set text(size: 8pt)
    ```
    >MN908947.3
    ATTAAAGGTTTATACCTTCCCA...
    >NC_006432.1
    CGGACACACAAAAAGAAAGAAA...
    ```
  ],
)

The corresponding #highlight[`primer.bed`] file should contain `BedLines` with the #highlight[`chrom`] `MN908947.3` and `NC_006432.1`


== reference.fasta best practices

#bp_str

=== Use high quality genomes
The genome contained in the `reference.fasta` file is commonly used for referenced-based assembly. Therefore, using a genome with large numbers of `Ns` or ambiguous bases can lead consensus sequence errors.

=== Use DNA genomes
DNA sequences are expected and should be the default. As by the nature of PCR, the amplicons and corresponding sequencing data should be DNA. However, RNA is allowed due to possible unforeseen applications.

=== Use canonical/publicly genomes
The `reference.fasta` will need to be shared to reproduce the downstream analysis. Therefore, using property or restricted will inhibit sharing.


= Further comments

== Use encompassing metadata standards
This specification simply lays out the structure and formatting of the `primer.bed` and `reference.fasta` file, the minimal files used replicate the primer pools, and analysis used in multiplexed PCR.

For true reproducibility, each primer scheme should have an explicit name and semantic versioning system, to track changes to the scheme. Therefore, larger metadata standards are require such as such as #link("https://github.com/ChrisgKent/primal-page")[primal-page] with #link("https://labs.primalscheme.com")[PrimalScheme Labs] or #link("https://github.com/pha4ge/primaschema")[primaschema] with #link("https://github.com/pha4ge/primer-schemes")[pha4ge primer-schemes].





