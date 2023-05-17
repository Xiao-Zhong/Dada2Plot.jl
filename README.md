# Dada2Plot

[![Build Status](https://github.com/Xiao-Zhong/Dada2Plot.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Xiao-Zhong/Dada2Plot.jl/actions/workflows/CI.yml?query=branch%3Amain)

# Introduction
A Julia package can be used for statistics and visualization of Amplicon Sequence Variant (ASV) produced by DADA2. It should be able to be easily tuned for 
ASV or Operational Taxonomic Units (OTUs) matrix tables produced by others. Please check the input tables as an example in the 'test' directory. 

# Usage
```
#start from input CSV files produced by DADA2 (https://benjjneb.github.io/dada2/tutorial.html)
asv_in_file = "dada2_asv_Immuno_8.csv"
taxa_in_file = "dada2_taxa_names_Immuno_8.csv"
sample_in_file =  "samples2_Immuno8_v3.csv"
(asv_in, taxa_in, sample_in) = input2df(asv_in_file, taxa_in_file, sample_in_file)

#find ASV overlapping between treatments/samples
treatment = ["BSF 10 + Immuno", "BSF 30 + Immuno"]
(asv_p, category_p) = asv_taxa_extract(asv_in, taxa_in, sample_in, treatment, 5, 2, "Kingdom", "Bacteria")

#plot venn diagram
venn_plot(asv_p, category_p, 3, "venn.pdf")

#TODO
1, barchart;
2, heatmap;
3, alpha, beta diversity analysis
4, swtich to use available native Julia Plot packages if there is.
```
# Dependency
The current version depends upon ggVennDiagram and ggplot2 for venn diagram plot via RCall.jl. 
