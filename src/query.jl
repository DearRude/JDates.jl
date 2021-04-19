# JDate Locales

struct JDateLocale
    months::Vector{String}
    months_abbr::Vector{String}
    days_of_week::Vector{String}
    days_of_week_abbr::Vector{String}
    month_value::Dict{String, Int64}
    month_abbr_value::Dict{String, Int64}
    day_of_week_value::Dict{String, Int64}
    day_of_week_abbr_value::Dict{String, Int64}
end

function locale_dict(names::Vector{<:AbstractString})
    result = Dict{String, Int}()

    # Keep both the common case-sensitive version of the name and an all lowercase
    # version for case-insensitive matches. Storing both allows us to avoid using the
    # lowercase function during parsing.
    for i in 1:length(names)
        name = names[i]
        result[name] = i
        result[lowercase(name)] = i
    end
    return result
end

"""
    DateLocale(["Farvardin", "Ordibehesht",...], ["Far", "Ord",...],
               ["Shanbeh", "YekShanbeh",...], ["Sha", "Yek",...])

Create a locale for parsing or printing textual month names.

Arguments:

- `months::Vector`: 12 month names
- `months_abbr::Vector`: 12 abbreviated month names
- `days_of_week::Vector`: 7 days of week
- `days_of_week_abbr::Vector`: 7 days of week abbreviated

This object is passed as the last argument to `tryparsenext` and `format`
methods defined for each `AbstractDateToken` type.
"""
function JDateLocale(months::Vector, months_abbr::Vector,
                    days_of_week::Vector, days_of_week_abbr::Vector)
    JDateLocale(
        months, months_abbr, days_of_week, days_of_week_abbr,
        locale_dict(months), locale_dict(months_abbr),
        locale_dict(days_of_week), locale_dict(days_of_week_abbr),
    )
end

const ENGLISH = DateLocale(
    ["Farvardin", "Ordibehesht", "Khordad", "Tir", "Mordad", "Shahrivar",
     "Mehr", "Aban", "Azar", "Day", "Bahman", "Esfand"],
    ["Far", "Ord", "Kho", "Tir", "Mor", "Shr",
     "Mhr", "Aba", "Aza", "Day", "Bah", "Esf"],
    ["Shanbeh", "YekShanbeh", "DoShanbeh", "SeShanbeh",
     "ChaharShanbeh", "PanjShanbeh", "Jomeh"],
    ["Sha", "Yek", "Doh", "Seh", "Cha", "Pan", "Jom"],
)

const FARSI = DateLocale(
    ["فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
     "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"],
    ["فرو", "ارد", "خرد", "تیر", "مرد", "شهر",
     "مهر", "آبا", "آذر", "دی", "بهم", "اسف"],
    ["شنبه", "یک‌شنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنج‌شنبه", "جمعه"],
    ["شنب", "یک‌ش", "دوش", "سه‌ش", "چاش", "پن‌ش", "جمه"],
)

const LOCALES = Dict{String, DateLocale}("english" => ENGLISH, "farsi" => FARSI)

for (fn, field) in zip(
    [:dayname_to_value, :dayabbr_to_value, :monthname_to_value, :monthabbr_to_value],
    [:day_of_week_value, :day_of_week_abbr_value, :month_value, :month_abbr_value],
)
    @eval @inline function $fn(word::AbstractString, locale::DateLocale)
        # Maximize performance by attempting to avoid the use of `lowercase` and trying
        # a case-sensitive lookup first
        value = get(locale.$field, word, 0)
        if value == 0
            value = get(locale.$field, lowercase(word), 0)
        end
        value
    end
end

# JDate functions

### Core query functions

# Shanbeh = 1....Jomeh = 7
dayofweek(days) = mod1(days, 7)

# Number of days in year
"""
    daysinyear(dt::TimeType) -> Int

Return 366 if the year of `dt` is a leap year, otherwise return 365.

# Examples
```jldoctest
julia> Dates.daysinyear(1999)
365

julia> Dates.daysinyear(2000)
366
```
"""
daysinyear(y) = 365 + isleapyear(y)

# Day of the year
const MONTHDAYS = (0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336)
dayofyear(m, d) = MONTHDAYS[m] + d

### Days of the Week
"""
    dayofweek(dt::TimeType) -> Int64

Return the day of the week as an [`Int64`](@ref) with `1 = Shanbeh, 2 = YekShanbeh, etc.`.

# Examples
```jldoctest
julia> Dates.dayofweek(JDate("1400-01-01"))
6
```
"""
dayofweek(dt::TimeType) = dayofweek(days(dt))

const Shanbeh, YekShanbeh, DoShanbeh, SeShanbeh, ChaharShanbeh, PanjShanbeh, Jomeh = 1, 2, 3, 4, 5, 6, 7
const Sha, Yek, Doh, Seh, Cha, Pan, Jom = 1, 2, 3, 4, 5, 6, 7
for (ii, day_ind, short_day, long_day) in ((1, "first", :Sha, :Shanbeh), (2, "second", :Yek, :YekShanbeh), (3, "third", :Doh, :DoShanbeh), (4, "fourth", :Seh, :SeShanbeh), (5, "fifth", :Cha, :ChaharShanbeh), (6, "sixth", :Pan, :PanjShanbeh), (7, "seventh", :Jom, :Jomeh))
    short_name = string(short_day)
    long_name = string(long_day)
    name_ind = day_ind
    ind_str = string(ii)
    @eval begin
        @doc """
        $($long_name)
        $($short_name)

        The $($name_ind) day of the week.

        # Examples
        ```jldoctest
        julia> $($long_name)
        $($ind_str)

        julia> $($short_name)
        $($ind_str)
        ```
        """ ($long_day, $short_day)
   end
end
dayname(day::Integer, locale::DateLocale) = locale.days_of_week[day]
dayabbr(day::Integer, locale::DateLocale) = locale.days_of_week_abbr[day]
dayname(day::Integer; locale::AbstractString="english") = dayname(day, LOCALES[locale])
dayabbr(day::Integer; locale::AbstractString="english") = dayabbr(day, LOCALES[locale])

"""
    dayname(dt::TimeType; locale="english") -> String
    dayname(day::Integer; locale="english") -> String

Return the full day name corresponding to the day of the week of the `JDate` or `JDateTime` in
the given `locale`. Also accepts `Integer`.

# Examples
```jldoctest
julia> JDates.dayname(JDate("1400-01-01"))
"PanjShanbeh"

julia> JDates.dayname(2; locale="farsi")
"یک‌شنبه"
```
"""
function dayname(dt::TimeType;locale::AbstractString="english")
    dayname(dayofweek(dt); locale=locale)
end

"""
    dayabbr(dt::TimeType; locale="english") -> String
    dayabbr(day::Integer; locale="english") -> String

Return the abbreviated name corresponding to the day of the week of the `JDate` or `JDateTime`
in the given `locale`. Also accepts `Integer`.

# Examples
```jldoctest
julia> Dates.dayabbr(JDate("1400-01-01"))
"Pan"

julia> Dates.dayabbr(3; locale="farsi")
"دوش"
```
"""
function dayabbr(dt::TimeType;locale::AbstractString="english")
    dayabbr(dayofweek(dt); locale=locale)
end

# Convenience methods for each day
isshanbeh(dt::TimeType) = dayofweek(dt) == Sha
isyekshanbeh(dt::TimeType) = dayofweek(dt) == Yek
isdoshanbeh(dt::TimeType) = dayofweek(dt) == Doh
isseshanbeh(dt::TimeType) = dayofweek(dt) == Seh
ischarshanbeh(dt::TimeType) = dayofweek(dt) == Cha
ispanjshanbeh(dt::TimeType) = dayofweek(dt) == Pan
isjomeh(dt::TimeType) = dayofweek(dt) == Jom

# i.e. 1st Shanbeh? 2nd Shanbeh? 3rd DoShanbeh? 5th Jomeh?
"""
    dayofweekofmonth(dt::TimeType) -> Int

For the day of week of `dt`, return which number it is in `dt`'s month. So if the day of
the week of `dt` is Shanbeh, then `1 = First Shanbeh of the month, 2 = Second Shanbeh of the
month, etc.` In the range 1:5.

# Examples
```jldoctest
julia> Dates.dayofweekofmonth(JDate("1400-02-01"))
1

julia> Dates.dayofweekofmonth(JDate("1400-02-08"))
2

julia> Dates.dayofweekofmonth(JDate("1400-02-15"))
3
```
"""
function dayofweekofmonth(dt::TimeType)
    d = day(dt)
    return d < 8 ? 1 : d < 15 ? 2 : d < 22 ? 3 : d < 29 ? 4 : 5
end

# Total number of a day of week in the month
# e.g. are there 4 or 5 Mondays in this month?
const TWENTYNINE = BitSet([1, 8, 15, 22, 29])
const THIRTY = BitSet([1, 2, 8, 9, 15, 16, 22, 23, 29, 30])
const THIRTYONE = BitSet([1, 2, 3, 8, 9, 10, 15, 16, 17, 22, 23, 24, 29, 30, 31])

"""
    daysofweekinmonth(dt::TimeType) -> Int

For the day of week of `dt`, return the total number of that day of the week in `dt`'s
month. Returns 4 or 5. Useful in temporal expressions for specifying the last day of a week
in a month by including `dayofweekofmonth(dt) == daysofweekinmonth(dt)` in the adjuster
function.

# Examples
```jldoctest
julia> Dates.daysofweekinmonth(JDate("2005-01-01"))
5

julia> Dates.daysofweekinmonth(JDate("2005-01-04"))
4
```
"""
function daysofweekinmonth(dt::TimeType)
    y, m, d = yearmonthday(dt)
    ld = daysinmonth(y, m)
    return ld == 28 ? 4 : ld == 29 ? ((d in TWENTYNINE) ? 5 : 4) :
           ld == 30 ? ((d in THIRTY) ? 5 : 4) :
           (d in THIRTYONE) ? 5 : 4
end

### Months
"""
    Farvardin

The first month of the year.

# Examples
```jldoctest
julia> Farvardin
1
```
"""
const Farvardin = 1

"""
    Far

Abbreviation for [`Farvardin`](@ref).

# Examples
```jldoctest
julia> Far
1
```
"""
const Far = 1

"""
    Ordibehesht

The second month of the year.

# Examples
```jldoctest
julia> Ordibehesht
2
```
"""
const Ordibehesht = 2

"""
    Ord

Abbreviation for [`Ordibehesht`](@ref).

# Examples
```jldoctest
julia> Ord
2
```
"""
const Ord = 2

"""
    Khordad

The third month of the year.

# Examples
```jldoctest
julia> Khordad
3
```
"""
const Khordad = 3

"""
    Kho

Abbreviation for [`Khordad`](@ref).

# Examples
```jldoctest
julia> Kho
3
```
"""
const Kho = 3

"""
    Tir

The fourth month of the year.

# Examples
```jldoctest
julia> Tir
4
```
"""
const Tir = 4


"""
    Mordad

The fifth month of the year.

# Examples
```jldoctest
julia> Mordad
5
```
"""
const Mordad = 5

"""
    Mor

Abbreviation for [`Khordad`](@ref).

# Examples
```jldoctest
julia> Mor
5
```
"""
const Mor = 5

"""
    Shahrivar

The sixth month of the year.

# Examples
```jldoctest
julia> Shahrivar
6
```
"""
const Shahrivar = 6

"""
    Shr

Abbreviation for [`Shahrivar`](@ref).

# Examples
```jldoctest
julia> Shr
6
```
"""
const Shr = 6

"""
    Mehr

The seventh month of the year.

# Examples
```jldoctest
julia> Mehr
7
```
"""
const Mehr = 7

"""
    Mhr

Abbreviation for [`Mehr`](@ref).

# Examples
```jldoctest
julia> Mhr
7
```
"""
const Mhr = 7

"""
    Aban

The eighth month of the year.

# Examples
```jldoctest
julia> Aban
8
```
"""
const Aban = 8

"""
    Aba

Abbreviation for [`Aban`](@ref).

# Examples
```jldoctest
julia> Aba
8
```
"""
const Aba = 8

"""
    Azar

The ninth month of the year.

# Examples
```jldoctest
julia> Azar
9
```
"""
const Azar = 9

"""
    Aza

Abbreviation for [`Azar`](@ref).

# Examples
```jldoctest
julia> Aza
9
```
"""
const Aza = 9

"""
    Day

The tenth month of the year.

# Examples
```jldoctest
julia> Day
10
```
"""
const Day = 10

"""
    Bahman

The eleventh month of the year.

# Examples
```jldoctest
julia> Bahman
11
```
"""
const Bahman = 11

"""
    Bah

Abbreviation for [`Bahman`](@ref).

# Examples
```jldoctest
julia> Bah
11
```
"""
const Bah = 11

"""
    Esfand

The last month of the year.

# Examples
```jldoctest
julia> Esfand
12
```
"""
const Esfand = 12

"""
    Esf

Abbreviation for [`Esfand`](@ref).

# Examples
```jldoctest
julia> Esf
12
```
"""
const Esf = 12

monthname(month::Integer, locale::DateLocale) = locale.months[month]
monthabbr(month::Integer, locale::DateLocale) = locale.months_abbr[month]
monthname(month::Integer; locale::AbstractString="english") = monthname(month, LOCALES[locale])
monthabbr(month::Integer; locale::AbstractString="english") = monthabbr(month, LOCALES[locale])

"""
    monthname(dt::TimeType; locale="english") -> String
    monthname(month::Integer, locale="english") -> String


Return the full name of the month of the `JDate` or `JDateTime` or `Integer` in the given `locale`.

# Examples
```jldoctest
julia> Dates.monthname(JDate("1400-01-04"))
"Farvardin"

julia> Dates.monthname(2; locale="farsi")
"اردیبهشت"
```
"""
function monthname(dt::TimeType; locale::AbstractString="english")
    monthname(month(dt); locale=locale)
end

"""
    monthabbr(dt::TimeType; locale="english") -> String
    monthabbr(month::Integer, locale="english") -> String

Return the abbreviated month name of the `JDate` or `JDateTime` or `Integer` in the given `locale`.

# Examples
```jldoctest
julia> Dates.monthabbr(JDate("1400-01-04"))
"Far"

julia> monthabbr(2; locale="farsi")
"ارد"
```
"""
function monthabbr(dt::TimeType; locale::AbstractString="english")
    monthabbr(month(dt); locale=locale)
end

"""
    daysinmonth(dt::TimeType) -> Int

Return the number of days in the month of `dt`. Value will be 28, 29, 30, or 31.

# Examples
```jldoctest
julia> JDates.daysinmonth(JDate("1400-01"))
31

julia> JDates.daysinmonth(JDate("1400-07"))
30

julia> JDates.daysinmonth(JDate("1400-11"))
30
```
"""
daysinmonth(dt::TimeType) = ((y, m) = yearmonth(dt); return daysinmonth(y, m))

### Years
"""
    isleapyear(dt::TimeType) -> Bool

Return `true` if the year of `dt` is a leap year.

# Examples
```jldoctest
julia> Dates.isleapyear(JDate("1396"))
true

julia> Dates.isleapyear(JDate("1395"))
false
```
"""
isleapyear(dt::TimeType) = isleapyear(year(dt))

"""
    dayofyear(dt::TimeType) -> Int

Return the day of the year for `dt` with Farvardin 1st being day 1.
"""
dayofyear(dt::TimeType) = ((y, m, d) = yearmonthday(dt); return dayofyear(y, m, d))

daysinyear(dt::TimeType) = 365 + isleapyear(dt)

### Quarters
"""
    quarterofyear(dt::TimeType) -> Int

Return the quarter that `dt` resides in. Range of value is 1:4.
"""
quarterofyear(dt::TimeType) = quarter(dt)

const QUARTERDAYS = (0, 31, 62, 0, 31, 62, 0, 30, 60, 0, 30, 59)

"""
    dayofquarter(dt::TimeType) -> Int

Return the day of the current quarter of `dt`. Range of value is 1:92.
"""
function dayofquarter(dt::TimeType)
    (y, m, d) = yearmonthday(dt)
    return QUARTERDAYS[m] + d + (m == 12 && isleapyear(y))
end
