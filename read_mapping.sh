        
# Install bowtie2

sudo apt install bowtie2
sudo apt install samtools

# Download genome file

mkdir read_mapping
cd read_mapping
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/current/fasta/solanum_tuberosum/ncrna/Solanum_tuberosum.SolTub_3.0.ncrna.fa.gz
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/current/fasta/solanum_tuberosum/dna/Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa.gz
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/current/fasta/solanum_tuberosum/dna_index/	Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa.gz.fai
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/current/gtf/solanum_tuberosum/Solanum_tuberosum.SolTub_3.0.60.gtf.gz


gunzip Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa.gz
# Create index for genomic file

bowtie2-build  Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa Solanum_tuberosum.SolTub_3.0.dna.toplevel_index


# Read mapping with reference genome
while read SRA; do
    bowtie2 -x Solanum_tuberosum.SolTub_3.0.dna.toplevel_index \
    -U /workspace/siRNA_data_analysis/trimmed_fastqc/"$SRA"*"_trimmed_filtered.fastq.gz" \
    -S /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned.sam \
    --very-sensitive --threads 8 \
    --un /workspace/siRNA_data_analysis/read_mapping/"$SRA"_unmapped_host.fastq
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

# view the sam file 

less SRRXXXXX_host_mapped.sam
# sam to bam file conversion

while read SRA; do
samtools view -bS /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned.sam > /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned.bam
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

# sort bam file
while read SRA; do
samtools sort /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned.bam -o /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned_sorted.bam
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

# index the refrence genome file and sorted sam file

samtools faidx Solanum_tuberosum.SolTub_3.0.dna.toplevel.fa

while read SRA; do
samtools index /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned_sorted.bam
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt

# view the alignement summary

while read SRA; do
samtools flagstats /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned_sorted.bam > /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned_sorted.stats.txt
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt
