@testset verbose = false "Conversion" begin
    for year=475:3178, month=1:12, day=1:29
        @test julian2jalali(jalali2julian(year, month, day)) == (year, month, day)
    end
end

@testset verbose = false "Leap year" begin
    leaps = [1280, 1284, 1288, 1300, 1313, 1346, 1370, 1375]
    for year=leaps
        @test isjalalileap(year)
    end
end
