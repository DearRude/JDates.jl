
quarter(m) = m < 4 ? 1 : m < 7 ? 2 : m < 10 ? 3 : 4


# Accessor functions
day(dt::JDate) = dt.day
day(dt::JDateTime) = dt.date.day
year(dt::JDateTime) = dt.date.year
year(dt::JDate) = dt.year
quarter(dt::JDateTime) = quarter(dt.date.month)
quarter(dt::JDate) = quarter(dt.month)
month(dt::JDateTime) = dt.date.month
month(dt::JDate) = dt.month

hour(dt::JDateTime)   = hour(dt.time)
minute(dt::JDateTime) = minute(dt.time)
second(dt::JDateTime) = second(dt.time)
millisecond(dt::JDateTime) = millisecond(dt.time)

dayofmonth(dt::JDate) = dt.day
dayofmonth(dt::JDateTime) = dt.date.day

yearmonth(dt::JDate) = (dt.year, dt.month)
yearmonth(dt::JDateTime) = (dt.date.year, dt.date.month)
monthday(dt::JDate) = (dt.month, dt.day)
monthday(dt::JDateTime) = (dt.date.month, dt.date.day)
yearmonthday(dt::JDate) = (dt.year, dt.month, dt.day)
yearmonthday(dt::JDateTime) = (dt.date.year, dt.date.month, dt.date.day)

# Documentation for exported accessors
for func in (:year, :month, :quarter)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::TimeType) -> Int64

        The $($name) of a `JDate` or `JDateTime` as an [`Int64`](@ref).
        """ $func(dt::TimeType)
    end
end


for func in (:day, :dayofmonth)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::TimeType) -> Int64

        The day of month of a `JDate` or `JDateTime` as an [`Int64`](@ref).
        """ $func(dt::TimeType)
    end
end

"""
    hour(dt::JDateTime) -> Int64

The hour of day of a `JDateTime` as an [`Int64`](@ref).
"""
hour(dt::JDateTime)

for func in (:minute, :second, :millisecond)
    name = string(func)
    @eval begin
        @doc """
            $($name)(dt::JDateTime) -> Int64

        The $($name) of a `JDateTime` as an [`Int64`](@ref).
        """ $func(dt::JDateTime)
    end
end

for parts in (["year", "month"], ["month", "day"], ["year", "month", "day"])
    name = join(parts)
    func = Symbol(name)
    @eval begin
        @doc """
            $($name)(dt::TimeType) -> ($(join(repeated(Int64, length($parts)), ", ")))

        Simultaneously return the $(join($parts, ", ", " and ")) parts of a `JDate` or
        `JDateTime`.
        """ $func(dt::TimeType)
    end
end

for func in (:hour, :minute, :second, :millisecond, :microsecond, :nanosecond)
    name = string(func)
    @eval begin
        @doc """
            $($name)(t::Time) -> Int64

        The $($name) of a `Time` as an [`Int64`](@ref).
        """ $func(t::Time)
    end
end
