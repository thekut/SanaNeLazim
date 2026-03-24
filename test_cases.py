import math

def iterative(current_savings, target_nest_egg, annual_savings, annual_return_rate):
    years_to_freedom = 0
    while current_savings < target_nest_egg and years_to_freedom < 60:
        current_savings = (current_savings * (1 + annual_return_rate)) + annual_savings
        years_to_freedom += 1
    return years_to_freedom, current_savings

def closed_form(current_savings, target_nest_egg, annual_savings, annual_return_rate):
    # This covers the 0 case and cases where we've already reached the target
    if current_savings >= target_nest_egg:
        return 0, current_savings

    if annual_return_rate == 0:
        if annual_savings > 0:
            years = math.ceil((target_nest_egg - current_savings) / annual_savings)
            years_to_freedom = min(years, 60)
            return years_to_freedom, current_savings + years_to_freedom * annual_savings
        else:
            return 60, current_savings

    PMT_over_r = annual_savings / annual_return_rate
    numerator = target_nest_egg + PMT_over_r
    denominator = current_savings + PMT_over_r

    # If denominator <= 0, we are losing money faster than it grows and won't reach target if numerator > 0
    if denominator <= 0 or numerator <= 0:
        years_to_freedom = 60
    else:
        try:
            n = math.log(numerator / denominator) / math.log(1 + annual_return_rate)
            years_to_freedom = math.ceil(n)
        except ValueError:
            years_to_freedom = 60

    if years_to_freedom > 60:
        years_to_freedom = 60

    final_savings = current_savings * (1 + annual_return_rate)**years_to_freedom + PMT_over_r * ((1 + annual_return_rate)**years_to_freedom - 1)

    return years_to_freedom, final_savings

test_data = [
    (1000, 2000, 100, 0.05),
    (0, 100000, 12000, 0.05),
    (50000, 100000, 0, 0.05),
    (50000, 100000, 1000, 0.00),
    (100000, 50000, 1000, 0.05),
    (1000, 100000000, 10, 0.05), # will hit 60 years
    (1000, 2000, -50, 0.05) # edge case negative savings
]

for p, t, a, r in test_data:
    i_y, i_s = iterative(p, t, a, r)
    c_y, c_s = closed_form(p, t, a, r)
    print(f"P={p}, T={t}, A={a}, R={r} | IT: {i_y}, {i_s:.2f} | CF: {c_y}, {c_s:.2f} | MATCH: {i_y == c_y and math.isclose(i_s, c_s, rel_tol=1e-5)}")
