# JalCalendar implements the Jalali Calendar standard (en.wikipedia.org/wiki/Jalali_calendar)
# Jalali calendar is a solar calendar, was compiled during the reign of Jalaluddin Malik-Shah I
# JalCalendar provides interpretation rules for UTInstants to civil date and time parts
struct JalCalendar <: Calendar end

"""
    JDateTime

`JDateTime` wraps a `UTInstant{Millisecond}` and interprets it according to the Jalali calendar.
"""
struct JDateTime <: AbstractDateTime
    instant::UTInstant{Millisecond}
    JDateTime(instant::UTInstant{Millisecond}) = new(instant)
end

"""
    JDate

`JDate` wraps a `UTInstant{Day}` and interprets it according to the Jalali calendar.
"""
struct JDate <: TimeType
    instant::UTInstant{Day}
    JDate(instant::UTInstant{Day}) = new(instant)
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
    rata = ms + 1000 * (s + 60mi + 3600h + 86400 * totaldays(y, m, d))
    return JDateTime(UTM(rata))
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
    return JDate(UTD(totaldays(y, m, d)))
end

function validargs(::Type{JDate}, y::Int64, m::Int64, d::Int64)
    474 < y < 3179 || return argerror("Year: $y out of range (475:3178)")
    0 < m < 13 || return argerror("Month: $m out of range (1:12)")
    0 < d < daysinmonth(y, m) + 1 || return argerror("Day: $d out of range (1:$(daysinmonth(y, m)))")
    return argerror()
end

# Convenience constructors from Periods
function JDateTime(y::Year, m::Month=Month(1), d::Day=Day(1),
                  h::Hour=Hour(0), mi::Minute=Minute(0),
                  s::Second=Second(0), ms::Millisecond=Millisecond(0))
    return JDateTime(value(y), value(m), value(d),
                    value(h), value(mi), value(s), value(ms))
end

JDate(y::Year, m::Month=Month(1), d::Day=Day(1)) = JDate(value(y), value(m), value(d))

# To allow any order/combination of Periods

"""
    JDateTime(periods::Period...) -> JDateTime

Construct a `JDateTime` type by `Period` type parts. Arguments may be in any order. JDateTime
parts not provided will default to the value of `Dates.default(period)`.
"""
function JDateTime(period::Period, periods::Period...)
    y = Year(1); m = Month(1); d = Day(1)
    h = Hour(0); mi = Minute(0); s = Second(0); ms = Millisecond(0)
    for p in (period, periods...)
        isa(p, Year) && (y = p::Year)
        isa(p, Month) && (m = p::Month)
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
    y = Year(1); m = Month(1); d = Day(1)
    for p in (period, periods...)
        isa(p, Year) && (y = p::Year)
        isa(p, Month) && (m = p::Month)
        isa(p, Day) && (d = p::Day)
    end
    return JDate(y, m, d)
end

# To be able convert from ISO Calendar to Jalali Calendar

"""
    JDateTime(dt::DateTime) -> JDateTime

Construct a `JDateTime` type by `DateTime` type. Arguments may be in any order. JDateTime
will convert Dates from ISO (Gregorian) calendar to Jalali calendar.
"""
function JDateTime(dt:DateTime)
    y = Year(dt); m = Month(dt); d = Day(dt)
    h = Hour(dt); mi = Minute(dt); s = Second(dt); ms = Millisecond(dt)
    return JDateTime(JDate(Date(y, m, s)), Time(h, mi, s, ms))
end

"""
    JDate(d::Date) -> JDate

Construct a `JDate` type by `Date` type. Arguments may be in any order. JDate
will convert Dates from ISO (Gregorian) calendar to Jalali calendar.
"""
function JDate(d::Date)
    gregor::DateTime = DateTime(year(d), month(d), day(y), 0, 0, 0)
    y, m, d = datetime2julian(gregor) |> julian2jalali
    return JDate(y, m, d)
end

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
function JDateTime(dt::JDate, t::Time)
    (microsecond(t) > 0 || nanosecond(t) > 0) && throw(InexactError(:JDateTime, JDateTime, t))
    y, m, d = yearmonthday(dt)
    return JDateTime(y, m, d, hour(t), minute(t), second(t), millisecond(t))
end

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
Base.zero(::Type{JDateTime}) = Millisecond(0)
Base.zero(::Type{JDate}) = Day(0)
Base.zero(::Type{Time}) = Nanosecond(0)
Base.zero(::T) where T <: TimeType = zero(T)::Period


Base.typemax(::Union{JDateTime, Type{JDateTime}}) = JDateTime(3178, 12, 31, 23, 59, 59)
Base.typemin(::Union{JDateTime, Type{JDateTime}}) = JDateTime(475, 1, 1, 0, 0, 0)
Base.typemax(::Union{JDate, Type{JDate}}) = JDate(3178, 12, 31)
Base.typemin(::Union{JDate, Type{JDate}}) = JDate(475, 1, 1)
Base.typemax(::Union{Time, Type{Time}}) = Time(23, 59, 59, 999, 999, 999)
Base.typemin(::Union{Time, Type{Time}}) = Time(0)
# JDate-JDateTime promotion, isless, ==
Base.promote_rule(::Type{JDate}, x::Type{JDateTime}) = JDateTime
Base.isless(x::T, y::T) where {T<:TimeType} = isless(value(x), value(y))
Base.isless(x::TimeType, y::TimeType) = isless(promote(x, y)...)
(==)(x::T, y::T) where {T<:TimeType} = (==)(value(x), value(y))
(==)(x::TimeType, y::TimeType) = (===)(promote(x, y)...)
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
