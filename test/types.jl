module TypesTest

using Test
using JDates

# Jalali Conversion constructions
@testset "Jalali Construction" begin
    for year=475:3178, month=1:12, day=1:29
        @test JDates.JDate(year, month, day) |> JDates.Date |> JDates.JDate |> JDates.yearmonthday == (year, month, day)
        @test JDates.JDateTime(year, month, day) |> JDates.DateTime |> JDates.JDateTime |> JDates.yearmonthday == (year, month, day)
    end
end

# Days in jalali month
@testset "daysinmonth" begin
    @test JDates.daysinmonth(1399, 1) == 31
    @test JDates.daysinmonth(1399, 2) == 31
    @test JDates.daysinmonth(1399, 3) == 31
    @test JDates.daysinmonth(1399, 4) == 31
    @test JDates.daysinmonth(1399, 5) == 31
    @test JDates.daysinmonth(1399, 6) == 31
    @test JDates.daysinmonth(1399, 7) == 30
    @test JDates.daysinmonth(1399, 8) == 30
    @test JDates.daysinmonth(1399, 9) == 30
    @test JDates.daysinmonth(1399, 10) == 30
    @test JDates.daysinmonth(1399, 11) == 30
    @test JDates.daysinmonth(1399, 12) == 30
    @test JDates.daysinmonth(1400, 12) == 29
end

# Leap year
leaps = [1280, 1284, 1288, 1300, 1313, 1346, 1370, 1375]
@testset "isleapyear" begin
    for leap in leaps
        @test JDates.isleapyear(leap) == true
    end
end

# Create "test" check manually
y = JDates.JYear(1400)
m = JDates.JMonth(1)
w = JDates.JWeek(1)
d = JDates.Day(1)
h = JDates.Hour(1)
mi = JDates.Minute(1)
s = JDates.Second(1)
ms = JDates.Millisecond(1)
@testset "DateTime construction by parts" begin
    test = JDates.JDateTime(1400)
    @test JDates.JDateTime(1400) == test
    @test JDates.JDateTime(1400, 1) == test
    @test JDates.JDateTime(1400, 1, 1) == test
    @test JDates.JDateTime(1400, 1, 1, 0) == test
    @test JDates.JDateTime(1400, 1, 1, 0, 0) == test
    @test JDates.JDateTime(1400, 1, 1, 0, 0, 0) == test
    @test JDates.JDateTime(1400, 1, 1, 0, 0, 0, 0) == test

    @test JDates.JDateTime(y) == JDates.JDateTime(1400)
    @test JDates.JDateTime(y, m) == JDates.JDateTime(1400, 1)
    @test JDates.JDateTime(y, m, d) == JDates.JDateTime(1400, 1, 1)
    @test JDates.JDateTime(y, m, d, h) == JDates.JDateTime(1400, 1, 1, 1)
    @test JDates.JDateTime(y, m, d, h, mi) == JDates.JDateTime(1400, 1, 1, 1, 1)
    @test JDates.JDateTime(y, m, d, h, mi, s) == JDates.JDateTime(1400, 1, 1, 1, 1, 1)
    @test JDates.JDateTime(y, m, d, h, mi, s, ms) == JDates.JDateTime(1400, 1, 1, 1, 1, 1, 1)
    @test JDates.JDateTime(JDates.Day(10), JDates.JMonth(2), y) == JDates.JDateTime(1400, 2, 10)
    @test JDates.JDateTime(JDates.Second(10), JDates.JMonth(2), y, JDates.Hour(4)) == JDates.JDateTime(1400, 2, 1, 4, 0, 10)
    @test JDates.JDateTime(JDates.JYear(1400), JDates.JMonth(2), JDates.Day(1),
                         JDates.Hour(4), JDates.Second(10)) == JDates.JDateTime(1400, 2, 1, 4, 0, 10)
end

@testset "Date construction by parts" begin
    test = JDates.JDate(1400)
    @test JDates.JDate(1400) == test
    @test JDates.JDate(1400, 1) == test
    @test JDates.JDate(1400, 1, 1) == test
    @test JDates.JDate(y) == JDates.JDate(1400)
    @test JDates.JDate(y, m) == JDates.JDate(1400, 1)
    @test JDates.JDate(y, m, d) == JDates.JDate(1400, 1, 1)
    @test JDates.JDate(JDates.Day(10), JDates.JMonth(2), y) == JDates.JDate(1400, 2, 10)
end

@testset "various input types for Date/DateTime" begin
    test = JDates.JDate(1400, 1, 1)
    @test JDates.JDate(Int16(1400), Int8(1), Int8(1)) == test
    @test JDates.JDate(UInt16(1400), UInt8(1), UInt8(1)) == test
    @test JDates.JDate(Int16(1400), Int16(1), Int16(1)) == test
    @test JDates.JDate(UInt16(1400), UInt8(1), UInt8(1)) == test
    @test JDates.JDate(Int32(1400), Int32(1), Int32(1)) == test
    @test JDates.JDate(UInt32(1400), UInt32(1), UInt32(1)) == test
    @test JDates.JDate(Int64(1400), Int64(1), Int64(1)) == test
    @test JDates.JDate(1400, true, true) == test
    @test_throws ArgumentError JDates.JDate(false, true, false)
    @test_throws ArgumentError JDates.JDate(true, true, false)
    @test JDates.JDate(UInt64(1400), UInt64(1), UInt64(1)) == test
    @test JDates.JDate(Int128(1400), Int128(1), Int128(1)) == test
    @test JDates.JDate(UInt128(1400), UInt128(1), UInt128(1)) == test
    @test JDates.JDate(big(1400), big(1), big(1)) == test
    @test JDates.JDate(big(1400), big(1), big(1)) == test
    # Potentially won't work if can't losslessly convert to Int64
    @test JDates.JDate(BigFloat(1400), BigFloat(1), BigFloat(1)) == test
    @test JDates.JDate(complex(1400), complex(1), complex(1)) == test
    @test JDates.JDate(Float64(1400), Float64(1), Float64(1)) == test
    @test JDates.JDate(Float32(1400), Float32(1), Float32(1)) == test
    @test JDates.JDate(Float16(1400), Float16(1), Float16(1)) == test
    @test JDates.JDate(Rational(1400), Rational(1), Rational(1)) == test
    @test_throws InexactError JDates.JDate(BigFloat(1.2), BigFloat(1), BigFloat(1))
    @test_throws InexactError JDates.JDate(1 + im, complex(1), complex(1))
    @test_throws InexactError JDates.JDate(1.2, 1.0, 1.0)
    @test_throws InexactError JDates.JDate(1.2f0, 1.f0, 1.f0)
    @test_throws InexactError JDates.JDate(3//4, Rational(1), Rational(1)) == test

    # Months, days, hours, minutes, seconds, and milliseconds must be in range
    @test_throws ArgumentError JDates.JDate(474)
    @test_throws ArgumentError JDates.JDate(3179)
    @test_throws ArgumentError JDates.JDate(1399, 0, 1)
    @test_throws ArgumentError JDates.JDate(1399, 13, 1)
    @test_throws ArgumentError JDates.JDate(1399, 1, 0)
    @test_throws ArgumentError JDates.JDate(1399, 1, 32)
    @test_throws ArgumentError JDates.JDateTime(1399, 0, 1)
    @test_throws ArgumentError JDates.JDateTime(1399, 13, 1)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 0)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 32)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 25)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, -1)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, -1)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, 60)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, 0, -1)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, 0, 60)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, 0, 0, -1)
    @test_throws ArgumentError JDates.JDateTime(1399, 1, 1, 0, 0, 0, 1000)
end
a = JDates.JDateTime(2000)
b = JDates.JDate(2000)
c = JDates.Time(0)
@testset "DateTime traits" begin
    @test JDates.calendar(a) == JDates.JalCalendar
    @test JDates.calendar(b) == JDates.JalCalendar
    @test eps(JDateTime) == JDates.Millisecond(1)
    @test eps(JDate) == JDates.Day(1)
    @test eps(a) == JDates.Millisecond(1)
    @test eps(b) == JDates.Day(1)
    @test zero(JDateTime) == JDates.Year(475)
    @test zero(JDate) == JDates.Year(475)
    @test zero(a) == JDates.Year(475)
    @test zero(b) == JDates.Year(475)
    @test isfinite(JDates.JDate)
    @test isfinite(JDates.JDateTime)
    @test c == c
    @test c == (c + JDates.Hour(24))
    @test hash(c) == hash(c + JDates.Hour(24))
    @test hash(c + JDates.Nanosecond(10)) == hash(c + JDates.Hour(24) + JDates.Nanosecond(10))
end

# Uncomment when io-printing is fixed

# @testset "Date-DateTime conversion/promotion" begin
#     global a, b, c, d
#     @test JDates.JDateTime(a) == a
#     @test JDates.JDate(a) == b
#     @test JDates.JDateTime(b) == a
#     @test JDates.JDate(b) == b
#     @test a == b
#     @test a == a
#     @test b == a
#     @test b == b
#     @test !(a < b)
#     @test !(b < a)
#     c = JDates.JDateTime(2000)
#     d = JDates.JDate(2000)
#     @test ==(a, c)
#     @test ==(c, a)
#     @test ==(d, b)
#     @test ==(b, d)
#     @test ==(a, d)
#     @test ==(d, a)
#     @test ==(b, c)
#     @test ==(c, b)
#     b = JDates.JDate(2001)
#     @test b > a
#     @test a < b
#     @test a != b
#     @test JDates.JDate(JDates.DateTime(JDates.JDate(2012, 7, 1))) == JDates.JDate(2012, 7, 1)
# end

# @testset "min and max" begin
#     for (a, b) in [(JDates.JDate(2000), JDates.JDate(2001)),
#                     (JDates.JDateTime(3000), JDates.JDateTime(3001)),
#                     (JDates.JWeek(42), JDates.JWeek(1972)),
#                     (JDates.JQuarter(3), JDates.JQuarter(52))]
#         @test min(a, b) == a
#         @test min(b, a) == a
#         @test min(a) == a
#         @test max(a, b) == b
#         @test max(b, a) == b
#         @test max(b) == b
#         @test minmax(a, b) == (a, b)
#         @test minmax(b, a) == (a, b)
#         @test minmax(a) == (a, a)
#     end
# end

end
