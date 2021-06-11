

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

# now we make a rule for fastqc, that just matches the fqbase wildcard.
# We run each, separately in a temp directory, because the snakemake wrapper
# for this notes that race conditions can occur if running multiple instances
# in the same directory...
rule fastqc:
	input:
		r"{dir}/{{fqbase}}.fq.gz".format(dir = INDIR)
	output:
		html = "results/fastqc_orig/{fqbase}_fastqc.html",
		zip = "results/fastqc_orig/{fqbase}_fastqc.zip"
	params:
		"--quiet"
	log:
		"results/logs/fastqc/{fqbase}.log"
	threads: 1
	wrapper:
		"v0.75.0/bio/fastqc"



# multiqc is effectively an aggregation step, so we want its inputs
# to be all the fastqc.zip files that would come from expanding our IDS
# variable. Note that aggregation always involves
# expanding the **input** of a rule.
rule multiqc:
	input:
		expand("results/fastqc_orig/{fqbase}_fastqc.zip", fqbase=IDS)
	output:
		"results/multiqc/multiqc.html"
	params:
		""
	log:
		"results/logs/multiqc/multiqc.log"
	wrapper:
		"v0.75.0/bio/multiqc"
