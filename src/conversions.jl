# Conversion/Promotion

"""
    JDate(dt::JDateTime) -> JDate

Convert a `JDateTime` to a `JDate`. The hour, minute, second, and millisecond parts of
the `JDateTime` are truncated, so only the year, month and day parts are used in
construction.
"""
JDate(dt::TimeType) = convert(JDate, dt)

"""
    JDateTime(dt::JDate) -> JDateTime

Convert a `JDate` to a `JDateTime`. The hour, minute, second, and millisecond parts of
the new `JDateTime` are assumed to be zero.
"""
JDateTime(dt::TimeType) = convert(JDateTime, dt)

"""
    Time(dt::JDateTime) -> Time

Convert a `JDateTime` to a `Time`. The hour, minute, second, and millisecond parts of
the `JDateTime` are used to create the new `Time`. Microsecond and nanoseconds are zero by default.
"""
Time(dt::JDateTime) = convert(Time, dt)

"""
    todate(dt::JDate) -> Date

Convert a `JDate` to a `Date`. Converts a Jalali date to its Gregorian stamp.
"""
todate(dt::JDate) = convert(Date, dt)

"""
    todatetime(dt::JDateTime) -> DateTime

Convert a `JDateTime` to a `DateTime`. Converts a Jalali datetime to its Gregorian stamp.
"""
todatetime(dt::JDate) = convert(DateTime, dt)


Base.convert(::Type{Date}, dt::JDate) = Date(dt)
Base.convert(::Type{DateTime}, dt::JDateTime) = DateTime(dt)

Base.convert(::Type{JDateTime}, dt::JDate) = JDateTime(dt, Time(0, 0, 0))
Base.convert(::Type{JDate}, dt::JDateTime) = dt.date
Base.convert(::Type{Time}, dt::JDateTime) = dt.time
