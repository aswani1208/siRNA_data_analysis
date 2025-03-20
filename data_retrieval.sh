        # install SRA tool kit to download the data

        sudo apt-get install sra-toolkit

        # configure SRA toolkit to save in current directory

        vdb-config -i

        # Install Fastqc

        wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip

        # Unzip the archive

        unzip fastqc_v0.12.1.zip

        # Install Trimmomatic

        wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
        unzip Trimmomatic-0.39.zip
        java -jar Trimmomatic-0.39/trimmomatic-0.39.jar



        # Install fastp
        wget http://opengene.org/fastp/fastp
        chmod a+x ./fastp


        # downloading data
        # select an accession id from sra
        # example SRR13986902


        mkdir sra_data
        cd sra_data

        # For downloading ultiple files from SRA

        prefetch --option-file /workspace/siRNA_data_analysis/SRR_Acc_List.txt --max-size 100G


        # SRA to single end read extraction

        while read sra; do
            echo "Downloading $sra......"
            fastq-dump $sra --split-files --gzip
        done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt


        # Run fastQC
        cd ..
        mkdir fastqc_results
        while read sra; do
        FastQC/fastqc -o fastqc_results /workspace/siRNA_data_analysis/sra_data/"$sra"_1*.fastq.gz
        done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt


        # Run trimming

        mkdir trimmed_fastqc
        while read SRA; do
        java -jar Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads 8 /workspace/siRNA_data_analysis/sra_data/"$SRA"_1*.fastq.gz trimmed_fastqc/"$SRA"_trimmed.fastq.gz ILLUMINACLIP:Trimmomatic-0.39/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:18
        done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

        ##### Fastp for filtering trimmed reads

        while read SRA; do
        /workspace/siRNA_data_analysis/fastp -i trimmed_fastqc/"$SRA"_trimmed.fastq.gz -o trimmed_fastqc/"$SRA"_trimmed_filtered.fastq.gz --length_required 18 --max_len1 30
        done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt


        # Run fastQC for trimmed reads

        while read SRA; do
        FastQC/fastqc -o fastqc_results trimmed_fastqc/"$SRA"_trimmed_filtered.fastq.gz
        done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

        
sudo apt install bowtie2

