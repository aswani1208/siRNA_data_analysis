
# Analyze Small RNA Distribution & Identify miRNAs (mirdeep2)


# Installation
sudo apt-get update
sudo apt-get install perl
sudo apt-get install default-jdk
sudo apt install build-essential

git clone https://github.com/rajewsky-lab/miRDeep2.git
cd miRDeep2
perl install.pl

cd tutorial_dir
bash run_tut.sh
cd ..
cd src
perl miRDeep2.pl --version

# Download the miRNA files for Solanum tuberosum

# From pimREN

wget https://www.pmiren.com/ftp-download/Solanum_tuberosum_Stu/Solanum_tuberosum_mature.fa
wget https://www.pmiren.com/ftp-download/Solanum_tuberosum_Stu/Solanum_tuberosum_hairpin.fa

# From mirBase

wget https://www.mirbase.org/download/hairpin.fa
wget https://www.mirbase.org/download/mature.fa

# Extract miRNA

extract_miRNAs.pl hairpin.fa stu > hairpin_stu.fa
extract_miRNAs.pl mature.fa stu > mature_stu.fa

# build bowtie index for miRNA seq from pimREN and mirbase

bowtie-build Solanum_tuberosum_mature.fa Solanum_tuberosum_mature_index
bowtie-build Solanum_tuberosum_hairpin.fa Solanum_tuberosum_hairpin_index

bowtie-build hairpin_stu.fa hairpin_stu_index
bowtie-build mature_stu.fa mature_stu_index

#fastq to fasta

while read SRA; do 
seqkit fq2fa ~/rna_seq_analysis/ref_dataset/trimmed_fastqc/"$SRA"_trimmed_filtered.fastq.gz -o "$SRA"_trimmed.fasta; 
done < ~/rna_seq_analysis/ref_dataset/sra_data/SRR_Acc_List.txt

# Reduce the header description in the fasta file

sed -i 's/ /_/g' ~/rna_seq_analysis/ref_dataset/read_mapping/Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa
sed -E 's/>(CM[0-9]+\.[0-9]+|MU[0-9]+\.[0-9]+).*/>\1/' ~/rna_seq_analysis/ref_dataset/read_mapping/Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa > fixed_genome.fa

# build bowtie index of the genome 

bowtie-build fixed_genome.fa fixed_genome_index

# process reads and map them to the genome.

while read SRA; do 
mapper.pl "$SRA"_trimmed.fasta -c -j -l 18 -m -p fixed_genome_index -s "$SRA"_processed_reads.fa -t "$SRA"_reads_vs_genome.arf -v;
done < ~/rna_seq_analysis/ref_dataset/sra_data/SRR_Acc_List.txt


# miRDeep2 mapper

mapper.pl ~/rna_seq_analysis/cacao_mirna_analysis/sra_data/SRR26332880.fasta -c -j -k -l 18 -m -p fixed_genome.fa -s SRR26332880reads_collapsed.fa -t SRR26332880reads_collapsed_vs_genome.arf -v

mapper.pl fixed_SRR26332883_trimmed.fasta -c -j -l 18 -m -p fixed_genome_index -s SRR26332883_processed_reads.fa -t SRR26332883_reads_vs_genome.arf -v

# The -c option designates that the input file is a FASTA file (for other input formats, see the README.md file). 
# The -j options removes entries with non-canonical letters (letters other than a, c, g, t, u, n, A, C, G, T, U, or N). 
# The -k option clips adapters. The -l option discards reads shorter than 18 nts. The -m option collapses the reads. 
# The -p option maps the processed reads against the previously indexed genome (cel_cluster). 
# The -s option designates the name of the output file of processed reads and the -t option designates the name of the output file of the genome mappings. 
# Last, -v gives verbose output to the screen.

sed -i 's/ /_/g' ~/rna_seq_analysis/cacao_mirna_analysis/alignment/Theobroma_cacao.fa


#Explanation
s/^(>[^:]+).*/\1/
^> → Matches the FASTA header (lines starting with >)
[^:]+ → Captures everything before the first colon (:)
.* → Matches everything after the colon
\1 → Keeps only the first part before :
s/_dna// → Removes _dna from the remaining header.

src/miRDeep2.pl /home/aswani/rna_seq_analysis/cacao_mirna_analysis/alignment/SRR26332880_processed_reads.fa fixed_genome.fa corrected.arf /home/aswani/rna_seq_analysis/cacao_mirna_analysis/alignment/mirna/pimren_Mature_miRNA_seq.fas fixed_mirna_mirbase.fa none none > mirna_results.txt

# fast quantitation of reads mapping to known miRBase precursors.
# (This step is not required for identification of known and novel miRNAs in the deep sequencing data when using miRDeep2.pl.)
# The miRNA_expressed.csv gives the read counts of the reference miRNAs in the data in tabular format. The results can also be browsed by opening expression_16_19.html with an internet browser.

quantifier.pl -p precursors_ref_this_species.fa -m mature_ref_this_species.fa -r reads_collapsed.fa -t cel -y 16_19

# identification of known and novel miRNAs in the deep sequencing data:

miRDeep2.pl reads_collapsed.fa cel_cluster.fa reads_collapsed_vs_genome.arf mature_ref_this_species.fa mature_ref_other_species.fa precursors_ref_this_species.fa -t C.elegans 2> report.log

src/miRDeep2.pl /home/aswani/rna_seq_analysis/cacao_mirna_analysis/alignment/SRR26332880_processed_reads.fa fixed_genome.fa corrected.arf /home/aswani/rna_seq_analysis/cacao_mirna_analysis/alignment/mirna/pimren_Mature_miRNA_seq.fas fixed_mirna_mirbase.fa none none > mirna_results.txt
mapper.pl SRR13986902aligned_reads.fasta -c -j -m -p fixed_cassava_genome_index -s SRR13986902_processed_reads.fa -t SRR13986902_reads_vs_genome.arf


cut -f6 SRR26332880_reads_vs_genome.arf | sort | uniq > arf_ids.txt

grep ">" fixed_genome.fa | cut -d ' ' -f1 | sed 's/>//' > genome_ids.txt

# remove header length

awk '{if(substr($0,1,1)==">") print $1; else print $0}' hairpin.fa > hairpin_fixed.fa

miRDeep2.pl reads_collapsed.fa cel_cluster.fa reads_collapsed_vs_genome.arf mature_ref_this_species.fa mature_ref_other_species.fa precursors_ref_this_species.fa -t C.elegans 2> report.log
miRDeep2.pl ~/rna_seq_analysis/cacao_mirna_analysis/alignment/SRR26332880_processed_reads.fa ~/rna_seq_analysis/miRDeep2/fixed_genome.fa ~/rna_seq_analysis/miRDeep2/corrected.arf pimren_Mature_miRNA_seq.fas fixed_mature.fa miRNA_stem-loop_seq.fas




