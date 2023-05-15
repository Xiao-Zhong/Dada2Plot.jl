module Dada2Plot

using DataFrames, CSV
using RCall

# Write your package code here.
export input2df, df_merger, asv_filter, asv_taxa_extract, venn_plot
include("functions.jl")

##start from input CSV files
asv_in_file = "test/dada2_asv_Immuno_8.csv"
taxa_in_file = "test/dada2_taxa_names_Immuno_8.csv"
sample_in_file =  "test/samples2_Immuno8_v3.csv"
(asv_in, taxa_in, sample_in) = input2df(asv_in_file, taxa_in_file, sample_in_file)

##find ASV overlapping
treatment = ["FM control + Immuno", "BSF 10 + Immuno", "BSF 30 + Immuno"]
(asv_p, category_p) = asv_taxa_extract(asv_in, taxa_in, sample_in, treatment, 5, 2, "Kingdom", "Bacteria");

##plot
if length(asv_p) >= 2
    venn_plot(asv_p, category_p, 3, "BSF30_Immuno-samples-only.pdf")
else
    println("Cannot find overlapping ASV between any two groups!")
end

end
