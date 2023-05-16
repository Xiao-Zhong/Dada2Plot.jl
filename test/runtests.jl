using Dada2Plot
using Test

# @testset "Dada2Plot.jl" begin
#     # Write your tests here.
#     #@test Dada2Plot.greet_your_package_name() != "Hello world!"
#     @test Dada2Plot.input2df("dada2_asv_Immuno_8.csv", "dada2_taxa_names_Immuno_8.csv", "samples2_Immuno8_v3.csv")

# end

##start from input CSV files
asv_in_file = "./test/dada2_asv_Immuno_8.csv"
taxa_in_file = "./test/dada2_taxa_names_Immuno_8.csv"
sample_in_file =  "./test/samples2_Immuno8_v3.csv"
(asv_in, taxa_in, sample_in) = input2df(asv_in_file, taxa_in_file, sample_in_file)
##find ASV overlapping
treatment = ["BSF 10 + Immuno", "BSF 30 + Immuno"]
(asv_p, category_p) = asv_taxa_extract(asv_in, taxa_in, sample_in, treatment, 5, 2, "Kingdom", "Bacteria");
##plot
venn_plot(asv_p, category_p, 3)