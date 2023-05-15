using Dada2Plot
using Test

@testset "Dada2Plot.jl" begin
    # Write your tests here.
    #@test YourPackageName.greet_your_package_name() == "Hello YourPackageName!"
    @test Dada2Plot.greet_your_package_name() != "Hello world!"

end
