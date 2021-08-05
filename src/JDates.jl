"""
    JDates

The `JDates` module provides `JDate`, `JDate`, `Time` types, and related functions.

The types are not aware of time zones, based on UT seconds
(86400 seconds a day, avoiding leap seconds), and
use the Jalali calendar, as specified [here](https://en.wikipedia.org/wiki/Jalali_calendar).
For time zone functionality, see the TimeZones.jl package.

```jldoctest
julia> dt = JDate(1394,12,31,23,59,59,999)
1394-12-31T23:59:59.999

julia> d1 = JDate(JDates.Month(12), JDates.Year(1394))
1394-12-01

julia> d2 = JDate("1394-12-31", JDates.DateFormat("y-m-d"))
1394-12-31

julia> JDates.yearmonthday(d2)
(1394, 12, 31)

julia> d2-d1
30 days
```

Please see the manual section on [`JDate`](@ref) and [`JDate`](@ref)
for more information.
"""
module JDates

import Base: ==, div, fld, mod, rem, gcd, lcm, +, -, *, /, %, broadcast
using Printf: @sprintf
using Dates
import Dates: Calendar, DatePeriod, AbstractDateTime, AbstractTime,
    UTInstant, AMPM, DateLocale, FixedPeriod, argerror, TWENTYFOURHOUR,
    adjusthour, UTM, hour, minute, second, millisecond,
    format
using Base.Iterators

include("types.jl")
include("algorithms.jl")
include("accessors.jl")
include("query.jl")
include("conversions.jl")
include("ranges.jl")
include("io.jl")

export Microsecond, Nanosecond,
       Year, Quarter, Month, Week, Day, Hour, Minute, Second, Millisecond,
       TimeZone, UTC, TimeType, JDate, JDateTime, Time, Date, DateTime,
       # accessors.jl
       yearmonthday, yearmonth, monthday, year, month, week, day,
       hour, minute, second, millisecond, dayofmonth,
       microsecond, nanosecond,
       # query.jl
       dayofweek, isleapyear, daysinmonth, daysinyear, dayofyear, dayname, dayabbr,
       dayofweekofmonth, daysofweekinmonth, monthname, monthabbr,
       quarterofyear, dayofquarter,
       Shanbeh, YekShanbeh, DoShanbeh, SeShanbeh, ChaharShanbeh, PanjShanbeh, Jomeh,
       Sha, Yek, Doh, Seh, Cha, Pan, Jom,
       Farvardin, Ordibehesht, Khordad, Tir, Mordad, Shahrivar,
       Mehr, Aban, Azar, Dey, Bahman, Esfand,
       Far, Ord, Kho, Tir, Mor, Shr, Mhr, Aba, Aza, Dey, Bah, Esf,
       # conversions.jl
       now, today

end # module
