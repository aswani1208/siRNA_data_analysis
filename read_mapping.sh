        
# Install bowtie2

sudo apt install bowtie2

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

while read SRA; do
    bowtie2 -x Solanum_tuberosum.SolTub_3.0.dna.toplevel_index \
    -U /workspace/siRNA_data_analysis/trimmed_fastqc/"$SRA"*"_trimmed_filtered.fastq.gz" \
    -S /workspace/siRNA_data_analysis/read_mapping/"$SRA"_host_aligned.sam \
    --very-sensitive --threads 8 \
    --un /workspace/siRNA_data_analysis/read_mapping/"$SRA"_unmapped_host.fastq
done < /workspace/siRNA_data_analysis/SRR_Acc_List.txt
