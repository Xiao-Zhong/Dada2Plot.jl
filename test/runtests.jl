using Dada2Plot
using Test

@testset "Dada2Plot.jl" begin
    # Write your tests here.
    #@test Dada2Plot.greet_your_package_name() != "Hello world!"
    @test Dada2Plot.input2df("dada2_asv_Immuno_8.csv", "dada2_taxa_names_Immuno_8.csv", "samples2_Immuno8_v3.csv")

end
