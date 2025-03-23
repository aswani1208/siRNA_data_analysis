
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
extract_miRNAs.pl hairpin.fa tcc > hairpin_tcc.fa
extract_miRNAs.pl mature.fa tcc > mature_tcc.fa

# build bowtie index for miRNA seq from pimREN and mirbase
bowtie-build Solanum_tuberosum_mature.fa Solanum_tuberosum_mature_index
bowtie-build Solanum_tuberosum_hairpin.fa Solanum_tuberosum_hairpin_index

bowtie-build hairpin_tcc.fa hairpin_tcc_index
bowtie-build mature_tcc.fa mature_tcc_index

# build bowtie index of the genome 
bowtie-build ~/rna_seq_analysis/ref_dataset/read_mapping/Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa ~/rna_seq_analysis/ref_dataset/read_mapping/Solanum_tuberosum.SolTub_3.0.dna.toplevel_index


