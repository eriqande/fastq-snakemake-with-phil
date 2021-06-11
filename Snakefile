

# There are lots of ways to do this, and if this were going to
# be part of a big workflow, a nicer way to do it would be to
# have a TSV or CSV file of samples, with each sample assigned
# a simple ID like s0001, s0002, etc. and the fastq paths associated
# with those.  

# But, we will just do it by picking out the files in a directory.
# This can be done with the glob_wildcards function from snakemake

# here is the directory where all my fastqs are:
INDIR = "/Users/eriq/Documents/work/teaching/CSU-computing-for-genomics-2020/assignment-repos/tiny-genomic-data/chinook-wgs-3-Mb-on-chr-32/fastq"

# here we get the variable parts of those fastq names. This is the list
# of base IDs and names we want to deal with.
IDS, = glob_wildcards(r"{dir}/{{fqbase}}.fq.gz".format(dir = INDIR))


# this is a small case for testing
#IDS = ["DPCh_plate1_A05_S5.R1", "DPCh_plate1_A05_S5.R2", "DPCh_plate1_A06_S6.R1", "DPCh_plate1_A06_S6.R2", "DPCh_plate1_A11_S11.R1", "DPCh_plate1_A11_S11.R2"]



rule all:
	input:
		"results/multiqc/multiqc.html"

# now we make a rule for fastqc, that just matches the fqbase wildcard
rule fastqc:
	input:
		fq = r"{dir}/{{fqbase}}.fq.gz".format(dir = INDIR)
	output:
		html = "results/fastqc_orig/{fqbase}_fastqc.html",
		zipf = "results/fastqc_orig/{fqbase}_fastqc.zip"
	log:
		"results/logs/fastqc/{fqbase}.log"
	conda:
		"envs/fastqc.yaml"
	shell:
		"fastqc -o results/fastqc_orig {input.fq} > {log} 2>&1"



# multiqc is effectively an aggregation step, so we want its inputs
# to be all the fastqc.zip files that would come from expanding our IDS
# variable.
rule multiqc:
	input:
		expand("results/fastqc_orig/{fqbase}_fastqc.zip", fqbase=IDS)
	output:
		"results/multiqc/multiqc.html"
	conda:
		"envs/multiqc.yaml"
	log:
		"results/logs/multiqc/multiqc.log"
	shell:
		"multiqc --force -o results/multiqc -n multiqc.html {input} > {log} 2>&1 "
