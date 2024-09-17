using my_example_pkg
using Test

@testset "my_example_pkg.jl" begin
    # Write your tests here.
    @test sum_values (2,3) = 5
    @test sum_values (-1,1) = 0
    @test sum_values (0,0) == 0
end
