module JDateTests

for file in readlines(joinpath(@__DIR__, "testgroups"))
    startswith(file, "#") || include(file * ".jl")
end

end
