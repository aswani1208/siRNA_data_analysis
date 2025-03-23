
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

# remove white space in reads header
while read SRA; do 
sed -i 's/ /_/g' "$SRA"_trimmed.fasta > fixed_"$SRA"_trimmed.fasta
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


# fast quantitation of reads mapping to known miRBase precursors.
# This step is not required to identify known and novel miRNAs in the deep sequencing data when using miRDeep2.pl.
# The miRNA_expressed.csv gives the read counts of the reference miRNAs in the data in tabular format. The results can also be browsed by opening expression_16_19.html with an internet browser.
# Identification of known and novel miRNAs in the deep sequencing data:

while read SRA; do  
miRDeep2.pl "$SRA"_processed_reads.fa fixed_genome.fa "$SRA"_reads_vs_genome.arf Solanum_tuberosum_mature.fa none Solanum_tuberosum_hairpin.fa; 
done < ~/rna_seq_analysis/ref_dataset/sra_data/SRR_Acc_List.txt



