import math

def iterative(current_savings, target_nest_egg, annual_savings, annual_return_rate):
    years_to_freedom = 0
    while current_savings < target_nest_egg and years_to_freedom < 60:
        current_savings = (current_savings * (1 + annual_return_rate)) + annual_savings
        years_to_freedom += 1
    return years_to_freedom, current_savings

def closed_form(current_savings, target_nest_egg, annual_savings, annual_return_rate):
    if current_savings >= target_nest_egg:
        return 0, current_savings
    if annual_return_rate == 0:
        if annual_savings > 0:
            years = math.ceil((target_nest_egg - current_savings) / annual_savings)
            return min(years, 60), current_savings + min(years, 60) * annual_savings
        else:
            return 60, current_savings

    PMT_over_r = annual_savings / annual_return_rate

    # We solve for n in: FV = P*(1+r)^n + PMT * ((1+r)^n - 1) / r
    # This assumes PMT is added at the end of the year, but the iterative loop has:
    # current_savings = (current_savings * (1 + r)) + PMT
    # This means PMT is added at the end of the year. Let's verify:
    # Year 1: P*(1+r) + PMT
    # Year 2: (P*(1+r) + PMT)*(1+r) + PMT = P*(1+r)^2 + PMT*(1+r) + PMT
    # Year n: P*(1+r)^n + PMT * ((1+r)^n - 1) / r. Correct.

    # If current_savings*(1+r)^n + PMT/r * ((1+r)^n - 1) >= target_nest_egg
    # (current_savings + PMT/r) * (1+r)^n - PMT/r >= target_nest_egg
    # (current_savings + PMT/r) * (1+r)^n >= target_nest_egg + PMT/r

    # It might be that current_savings + PMT/r <= 0, which happens if PMT < 0 and we are losing money.
    # But annual_savings > 0 because of earlier check "if annual_savings <= 0".

    numerator = target_nest_egg + PMT_over_r
    denominator = current_savings + PMT_over_r

    n = math.log(numerator / denominator) / math.log(1 + annual_return_rate)

    years_to_freedom = math.ceil(n)

    if years_to_freedom > 60:
        years_to_freedom = 60

    final_savings = current_savings * (1 + annual_return_rate)**years_to_freedom + PMT_over_r * ((1 + annual_return_rate)**years_to_freedom - 1)

    return years_to_freedom, final_savings

import timeit

print("iterative:", timeit.timeit("iterative(1000, 20000000, 100, 0.05)", globals=globals(), number=100000))
print("closed_form:", timeit.timeit("closed_form(1000, 20000000, 100, 0.05)", globals=globals(), number=100000))
