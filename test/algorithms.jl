leaps = [1280, 1284, 1288, 1300, 1313, 1346, 1370, 1375]

@testset verbose = false "Conversion" begin
    for year=475:3178, month=1:12, day=1:29
        @test julian2jalali(jalali2julian(year, month, day)) == (year, month, day)
    end
end

@testset verbose = false "Leap year" begin
    for year=leaps
        @test isjalalileap(year)
        @test !isjalalileap(year + 1)
    end
end

@testset verbose = false "Day in year" begin
    for year=leaps
        @test getdays_injalaliyear(year) == 366
        @test getdays_injalaliyear(year + 1) == 365
    end
end

@testset verbose = false "Day in month" begin
    for year=leaps, month=12
        @test getdays_injalalimonth(year, month) == 30
        @test getdays_injalalimonth(year + 1, month) == 29
    end
    for year=leaps, month=1:6
        @test getdays_injalalimonth(year, month) == 31
        @test getdays_injalalimonth(year + 1, month) == 31
    end
    for year=leaps, month=7:11
        @test getdays_injalalimonth(year, month) == 30
        @test getdays_injalalimonth(year + 1, month) == 30
    end
end
