
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