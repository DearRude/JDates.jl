default_format(::Type{JDateTime}) = ISODateTimeFormat
default_format(::Type{JDate}) = ISODateFormat
default_format(::Type{Time}) = ISOTimeFormat

### API

const Locale = Union{DateLocale, String}

"""
    JDateTime(dt::AbstractString, format::AbstractString; locale="english") -> JDateTime

Construct a `JDateTime` by parsing the `dt` date time string following the
pattern given in the `format` string (see [`DateFormat`](@ref)  for syntax).

This method creates a `DateFormat` object each time it is called. If you are
parsing many date time strings of the same format, consider creating a
[`DateFormat`](@ref) object once and using that as the second argument instead.
"""
function JDateTime(dt::AbstractString, format::AbstractString; locale::Locale=ENGLISH)
    return parse(JDateTime, dt, DateFormat(format, locale))
end

"""
    JDateTime(dt::AbstractString, df::DateFormat=ISODateTimeFormat) -> JDateTime

Construct a `JDateTime` by parsing the `dt` date time string following the
pattern given in the [`DateFormat`](@ref) object, or $ISODateTimeFormat if omitted.

Similar to `JDateTime(::AbstractString, ::AbstractString)` but more efficient when
repeatedly parsing similarly formatted date time strings with a pre-created
`DateFormat` object.
"""
JDateTime(dt::AbstractString, df::DateFormat=ISODateTimeFormat) = parse(JDateTime, dt, df)

"""
    JDate(d::AbstractString, format::AbstractString; locale="english") -> JDate

Construct a `JDate` by parsing the `d` date string following the pattern given
in the `format` string (see [`DateFormat`](@ref) for syntax).

This method creates a `DateFormat` object each time it is called. If you are
parsing many date strings of the same format, consider creating a
[`DateFormat`](@ref) object once and using that as the second argument instead.
"""
function JDate(d::AbstractString, format::AbstractString; locale::Locale=ENGLISH)
    parse(JDate, d, DateFormat(format, locale))
end

"""
    JDate(d::AbstractString, df::DateFormat=ISODateFormat) -> JDate

Construct a `JDate` by parsing the `d` date string following the
pattern given in the [`DateFormat`](@ref) object, or $ISODateFormat if omitted.

Similar to `JDate(::AbstractString, ::AbstractString)` but more efficient when
repeatedly parsing similarly formatted date strings with a pre-created
`DateFormat` object.
"""
JDate(d::AbstractString, df::DateFormat=ISODateFormat) = parse(JDate, d, df)


# show
function Base.print(io::IO, dt::JDateTime)
    str = if millisecond(dt) == 0
        format(dt, dateformat"YYYY-mm-dd\THH:MM:SS", 19)
    else
        format(dt, dateformat"YYYY-mm-dd\THH:MM:SS.sss", 23)
    end
    print(io, str)
end

function Base.print(io::IO, dt::JDate)
    # don't use format - bypassing IOBuffer creation
    # saves a bit of time here.
    y,m,d = yearmonthday(dt)
    yy = lpad(y, 4, "0")
    mm = lpad(m, 2, "0")
    dd = lpad(d, 2, "0")
    print(io, "$yy-$mm-$dd")
end

for date_type in (:JDate, :JDateTime)
    # Human readable output (i.e. "2012-01-01")
    @eval Base.show(io::IO, ::MIME"text/plain", dt::$date_type) = print(io, dt)
    # Parsable output (i.e. JDate("2012-01-01"))
    @eval Base.show(io::IO, dt::$date_type) = print(io, typeof(dt), "(\"", dt, "\")")
    # Parsable output will have type info displayed, thus it is implied
    @eval Base.typeinfo_implicit(::Type{$date_type}) = true
end
