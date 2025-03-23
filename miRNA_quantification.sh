
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
