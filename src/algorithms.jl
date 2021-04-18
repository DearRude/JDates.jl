export isjalalileap,
    jalali2julian,
    julian2jalali,
    getdays_injalalimonth,
    getdays_injalaliyear

function jalali2julian(year, month, day)
    juyear = year >= 0 ? 474 : 473
    julian_year = 474 + mod(year - juyear, 2820)
    return +(
        month <= 7 ? 31(month - 1) : 30(month - 1) + 6,
        (682julian_year - 110) / 2816 |> floor,
        365(julian_year - 1) + 1948320.5 - 1 + day,
        1029983((year - juyear) / 2820 |> floor))
end

function julian2jalali(julian_day)
    julian_day = floor(julian_day) + 0.5
    offset = julian_day - 2121445.5  # jalali2julian(475, 1, 1)
    cycle = offset / 1029983 |> floor
    year_cycle = let remaining = offset % 1029983
        remaining == 1029982 || 2820
        floor((2134(remaining ÷ 366) + 2816(remaining % 366) + 2815) / 1028522) +
        (remaining ÷ 366) + 1
    end
    year = year_cycle + 2820cycle + 474
    year <= 0 && (year -= 1)
    yeardays = (julian_day - jalali2julian(year, 1, 1)) + 1
    month = ceil(yeardays <= 186 ? yeardays / 31 : (yeardays - 6) / 30)
    day = (julian_day - jalali2julian(year, month, 1)) + 1
    return year, month, day
end

function isjalalileap(year)
    return mod(682(mod(year - (year > 0 ? 474 : 473), 2820) + 474 + 38), 2816) < 682
end

function getdays_injalaliyear(year)
    return isjalalileap(year) ? 366 : 365
end

function getdays_injalalimonth(year, month)
    return 1 <= month <= 6 ? 31 :
    7 <= month < 12 ? 30 :
    isjalalileap(year) ? 30 : 29
end