# JalCalendar implements the Jalali Calendar standard (en.wikipedia.org/wiki/Jalali_calendar)
# Jalali calendar is a solar calendar, was compiled during the reign of Jalaluddin Malik-Shah I
# JalCalendar provides interpretation rules for UTInstants to civil date and time parts
struct JalCalendar <: Calendar end


for T in (:JYear, :JQuarter, :JMonth, :JWeek)
    @eval struct $T <: DatePeriod
        value::Int64
        $T(v::Number) = new(v)
    end
end

"""
    JDate

`JDate` wraps `JYear`, `JMonth`, `Day` and interprets it according to the Jalali calendar.
"""
struct JDate <: TimeType
    year::Int64
    month::Int64
    day::Int64
    JDate(y::JYear, m::JMonth, d::Day) = new(y.value, m.value, d.value)
end

"""
    JDateTime

`JDateTime` wraps a `UTInstant{Millisecond}`, `JDate` and interprets it according to the Jalali calendar.
"""
struct JDateTime <: AbstractDateTime
    date::JDate
    time::Time
    JDateTime(date::JDate, time::Time) = new(date, time)
end

### CONSTRUCTORS ###
# Core constructors
"""
    JDateTime(y, [m, d, h, mi, s, ms]) -> JDateTime

Construct a `JDateTime` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function JDateTime(y::Int64, m::Int64=1, d::Int64=1,
                  h::Int64=0, mi::Int64=0, s::Int64=0, ms::Int64=0, ampm::AMPM=TWENTYFOURHOUR)
    err = validargs(JDateTime, y, m, d, h, mi, s, ms, ampm)
    err === nothing || throw(err)
    h = adjusthour(h, ampm)
    time = 1000(ms + 1000(s + 60mi + 3600h)) |> Nanosecond |> Time
    date = JDate(y, m, d)
    return JDateTime(date, time)
end

function validargs(::Type{JDateTime}, y::Int64, m::Int64, d::Int64,
                   h::Int64, mi::Int64, s::Int64, ms::Int64, ampm::AMPM=TWENTYFOURHOUR)
    474 < y < 3179 || return argerror("Year: $y out of range (475:3178)")
    0 < m < 13 || return argerror("Month: $m out of range (1:12)")
    0 < d < daysinmonth(y, m) + 1 || return argerror("Day: $d out of range (1:$(daysinmonth(y, m)))")
    if ampm == TWENTYFOURHOUR # 24-hour clock
        -1 < h < 24 || (h == 24 && mi==s==ms==0) ||
            return argerror("Hour: $h out of range (0:23)")
    else
        0 < h < 13 || return argerror("Hour: $h out of range (1:12)")
    end
    -1 < mi < 60 || return argerror("Minute: $mi out of range (0:59)")
    -1 < s < 60 || return argerror("Second: $s out of range (0:59)")
    -1 < ms < 1000 || return argerror("Millisecond: $ms out of range (0:999)")
    return argerror()
end

"""
    JDate(y, [m, d]) -> JDate

Construct a `JDate` type by parts. Arguments must be convertible to [`Int64`](@ref).
"""
function JDate(y::Int64, m::Int64=1, d::Int64=1)
    err = validargs(JDate, y, m, d)
    err === nothing || throw(err)
    return JDate(JYear(y), JMonth(m), Day(d))
end

function validargs(::Type{JDate}, y::Int64, m::Int64, d::Int64)
    474 < y < 3179 || return argerror("Year: $y out of range (475:3178)")
    0 < m < 13 || return argerror("Month: $m out of range (1:12)")
    0 < d < daysinmonth(y, m) + 1 || return argerror("Day: $d out of range (1:$(daysinmonth(y, m)))")
    return argerror()
end

# Convenience constructors from Periods
function JDateTime(y::JYear, m::JMonth=JMonth(1), d::Day=Day(1),
                  h::Hour=Hour(0), mi::Minute=Minute(0),
                  s::Second=Second(0), ms::Millisecond=Millisecond(0))
    JDateTime(y.value, m.value, d.value,
              h.value, mi.value, s.value, ms.value)
end

# To allow any order/combination of Periods

"""
    JDateTime(periods::Period...) -> JDateTime

Construct a `JDateTime` type by `Period` type parts. Arguments may be in any order. JDateTime
parts not provided will default to the value of `Dates.default(period)`.
"""
function JDateTime(period::Period, periods::Period...)
    y = JYear(1); m = JMonth(1); d = Day(1)
    h = Hour(0); mi = Minute(0); s = Second(0); ms = Millisecond(0)
    for p in (period, periods...)
        isa(p, JYear) && (y = p::JYear)
        isa(p, JMonth) && (m = p::JMonth)
        isa(p, Day) && (d = p::Day)
        isa(p, Hour) && (h = p::Hour)
        isa(p, Minute) && (mi = p::Minute)
        isa(p, Second) && (s = p::Second)
        isa(p, Millisecond) && (ms = p::Millisecond)
    end
    return JDateTime(y, m, d, h, mi, s, ms)
end

"""
    JDate(period::Period...) -> JDate

Construct a `JDate` type by `Period` type parts. Arguments may be in any order. `JDate` parts
not provided will default to the value of `JDates.default(period)`.
"""
function JDate(period::Period, periods::Period...)
    y = JYear(1); m = JMonth(1); d = Day(1)
    for p in (period, periods...)
        isa(p, JYear) && (y = p::JYear)
        isa(p, JMonth) && (m = p::JMonth)
        isa(p, Day) && (d = p::Day)
    end
    return JDate(y, m, d)
end

# To be able convert from ISO Calendar to Jalali Calendar

# TODO: Replce calling attributes with something else
"""
    JDateTime(dt::DateTime) -> JDateTime

Construct a `JDateTime` type by `DateTime` type. Arguments may be in any order. JDateTime
will convert Dates from ISO (Gregorian) calendar to Jalali calendar.
"""
JDateTime(dt::DateTime) = JDateTime(JDate(Date(dt)), Time(dt))

"""
    JDate(d::Date) -> JDate

Construct a `JDate` type by `Date` type. Arguments may be in any order. JDate
will convert Dates from ISO (Gregorian) calendar to Jalali calendar.
"""
function JDate(d::Date)
    y, m, d = d |> DateTime |> datetime2julian |> julian2jalali
    return JDate(y, m, d)
end

# To be able convert from Jalali Calendar to ISO Calendar

# TODO: Replce calling attributes with something else
"""
    DateTime(dt::JDateTime) -> DateTime

Construct a `DateTime` type by `JDateTime` type. Arguments may be in any order. DateTime
will convert Dates from Jalali calendar to ISO (Gregorian) calendar.
"""
DateTime(dt::JDateTime) = DateTime(Date(JDate(dt)), Time(dt))

"""
    Date(d::JDate) -> Date

Construct a `Date` type by `JDate` type. Arguments may be in any order. Date
will convert JDates from Jalali calendar to ISO (Gregorian) calendar.
"""
Date(d::JDate) = jalali2julian(yearmonthday(d)...) |> julian2datetime |> Date

# Convenience constructor for JDateTime from JDate and Time
"""
    JDateTime(d::JDate, t::Time)

Construct a `JDateTime` type by `JDate` and `Time`.
Non-zero microseconds or nanoseconds in the `Time` type will result in an
`InexactError`.

!!! compat "Julia 1.1"
    This function requires at least Julia 1.1.

```jldoctest
julia> d = JDate(1400, 1, 1)
1400-01-01

julia> t = Time(8, 15, 42)
08:15:42

julia> JDateTime(d, t)
1400-01-01T08:15:42
```
"""

# Fallback constructors
JDateTime(y, m=1, d=1, h=0, mi=0, s=0, ms=0, ampm::AMPM=TWENTYFOURHOUR) = JDateTime(Int64(y), Int64(m), Int64(d), Int64(h), Int64(mi), Int64(s), Int64(ms), ampm)
JDate(y, m=1, d=1) = JDate(Int64(y), Int64(m), Int64(d))

# Traits, Equality
Base.isfinite(::Union{Type{T}, T}) where {T<:TimeType} = true
calendar(dt::JDateTime) = JalCalendar
calendar(dt::JDate) = JalCalendar

"""
    eps(::Type{JDateTime}) -> Millisecond
    eps(::Type{JDate}) -> Day
    eps(::Type{Time}) -> Nanosecond
    eps(::TimeType) -> Period

Return the smallest unit value supported by the `TimeType`.

# Examples
```jldoctest
julia> eps(JDateTime)
1 millisecond

julia> eps(JDate)
1 day

julia> eps(Time)
1 nanosecond
```
"""
Base.eps(::Union{Type{JDateTime}, Type{JDate}, Type{Time}, TimeType})

Base.eps(::Type{JDateTime}) = Millisecond(1)
Base.eps(::Type{JDate}) = Day(1)
Base.eps(::Type{Time}) = Nanosecond(1)
Base.eps(::T) where T <: TimeType = eps(T)::Period

# zero returns dt::T - dt::T
Base.zero(::Type{JDateTime}) = Year(475)
Base.zero(::Type{JDate}) = Year(475)
Base.zero(::Type{Time}) = Nanosecond(0)
Base.zero(::T) where T <: TimeType = zero(T)::Period


Base.typemax(::Union{JDateTime, Type{JDateTime}}) = JDateTime(3178, 12, 31, 23, 59, 59)
Base.typemin(::Union{JDateTime, Type{JDateTime}}) = JDateTime(475, 1, 1, 0, 0, 0)
Base.typemax(::Union{JDate, Type{JDate}}) = JDate(3178, 12, 31)
Base.typemin(::Union{JDate, Type{JDate}}) = JDate(475, 1, 1)
Base.typemax(::Union{Time, Type{Time}}) = Time(23, 59, 59, 999)
Base.typemin(::Union{Time, Type{Time}}) = Time(0)
# JDate-JDateTime promotion, isless, ==
Base.promote_rule(::Type{JDate}, x::Type{JDateTime}) = JDateTime
Base.isless(x::JDate, y::JDate) =
        x.year != y.year ? isless(x.year, y.year) :
        x.month != y.month ? isless(x.month, y.month) :
        isless(x.day, x.day)
Base.isless(x::JDateTime, y::JDateTime) = x.date != y.date ? isless(x.time, y.time) : isless(x.date, x.date)
Base.isless(x::JDate, y::JDateTime) = x != y.date ? isless(x, y.date) : isless(Time(0), y.time)
Base.isless(x::JDateTime, y::JDate) = x.date != y ? isless(x.date, y) : isless(x.time, Time(0))
(==)(x::JDate, y::JDate) = (==)(x.year, y.year) && (==)(x.month, y.month) && (==)(x.day, y.day)
(==)(x::JDateTime, y::JDateTime) = (==)(x.date, y.date) && (==)(x.time, y.time)
Base.min(x::AbstractTime) = x
Base.max(x::AbstractTime) = x
Base.minmax(x::AbstractTime) = (x, x)
Base.hash(x::Time, h::UInt) =
    hash(hour(x), hash(minute(x), hash(second(x),
        hash(millisecond(x), hash(microsecond(x), hash(nanosecond(x), h))))))

Base.sleep(duration::Period) = sleep(toms(duration) / 1000)

function Base.Timer(delay::Period; interval::Period=Second(0))
    Timer(toms(delay) / 1000, interval=toms(interval) / 1000)
end

function Base.timedwait(testcb::Function, timeout::Period; pollint::Period=Millisecond(100))
    timedwait(testcb, toms(timeout) / 1000, pollint=toms(pollint) / 1000)
end

Base.OrderStyle(::Type{<:AbstractTime}) = Base.Ordered()
Base.ArithmeticStyle(::Type{<:AbstractTime}) = Base.ArithmeticWraps()
