using Test
using JDates


@testset verbose = true "JDates.jl" begin
    include("algorithms.jl")
end