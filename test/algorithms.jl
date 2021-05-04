module AlgorithmsTest

using Test
using JDates

leaps = [1280, 1284, 1288, 1300, 1313, 1346, 1370, 1375]

@testset "Conversion" begin
    for year=475:3178, month=1:12, day=1:29
        @test JDates.jalali2julian(year, month, day) |> JDates.julian2jalali == (year, month, day)
    end
end

@testset "Leap year" begin
    for year=leaps
        @test JDates.isjalalileap(year)
        @test !JDates.isjalalileap(year + 1)
    end
end

@testset "Day in year" begin
    for year=leaps
        @test JDates.getdays_injalaliyear(year) == 366
        @test JDates.getdays_injalaliyear(year + 1) == 365
    end
end

@testset verbose = false "Day in month" begin
    for year=leaps, month=12
        @test JDates.getdays_injalalimonth(year, month) == 30
        @test JDates.getdays_injalalimonth(year + 1, month) == 29
    end
    for year=leaps, month=1:6
        @test JDates.getdays_injalalimonth(year, month) == 31
        @test JDates.getdays_injalalimonth(year + 1, month) == 31
    end
    for year=leaps, month=7:11
        @test JDates.getdays_injalalimonth(year, month) == 30
        @test JDates.getdays_injalalimonth(year + 1, month) == 30
    end
end
end
