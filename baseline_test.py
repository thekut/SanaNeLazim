import math
import timeit

def iterative(current_savings, target_nest_egg, annual_savings, debt_payment, debt_years, annual_return_rate, max_years):
    savings = current_savings
    yrs = 0
    while savings < target_nest_egg and yrs < max_years:
        current_sav = annual_savings + (debt_payment if yrs >= debt_years else 0)
        savings = (savings * (1 + annual_return_rate)) + current_sav
        yrs += 1
    return yrs, savings

def closed_form(current_savings, target_nest_egg, annual_savings, debt_payment, debt_years, annual_return_rate, max_years):
    # Short circuit if already achieved
    if current_savings >= target_nest_egg: return 0, current_savings

    def solve_n(FV, P, PMT, r):
        if r == 0: return float('inf') if PMT <= 0 else (FV - P) / PMT
        num, den = FV + (PMT / r), P + (PMT / r)
        return float('inf') if den <= 0 or num <= 0 else math.log(num / den) / math.log(1 + r)

    def get_fv(P, PMT, r, n):
        if r == 0: return P + PMT * n
        r_plus_1_n = (1 + r)**n
        return P * r_plus_1_n + PMT * ((r_plus_1_n - 1) / r)

    if debt_years > 0:
        n1 = solve_n(target_nest_egg, current_savings, annual_savings, annual_return_rate)
        if n1 <= debt_years:
            yrs = math.ceil(n1)
            return min(yrs, max_years), get_fv(current_savings, annual_savings, annual_return_rate, min(yrs, max_years))

        current_savings = get_fv(current_savings, annual_savings, annual_return_rate, debt_years)
        years_passed = debt_years
    else:
        years_passed = 0

    new_annual_savings = annual_savings + debt_payment
    n2 = solve_n(target_nest_egg, current_savings, new_annual_savings, annual_return_rate)

    total_years = years_passed + math.ceil(n2) if n2 != float('inf') else float('inf')

    if total_years >= max_years:
        return max_years, get_fv(current_savings, new_annual_savings, annual_return_rate, max_years - years_passed)

    return total_years, get_fv(current_savings, new_annual_savings, annual_return_rate, total_years - years_passed)


test_cases = [
    (1000, 20000, 1000, 0, 0, 0.05, 60),
    (5000, 100000, 500, 0, 0, 0.10, 60),
    (0, 100000, 100, 12000, 5, 0.05, 60),
    (50000, 60000, 2000, 12000, 10, 0.05, 60),
    (1000, 20000, 1000, 0, 0, 0.0, 60),
    (100, 1000000, 10, 0, 0, 0.01, 60),
    (10000, 20000, -500, 1000, 10, 0.05, 60),
]

for i, case in enumerate(test_cases):
    i_y, i_s = iterative(*case)
    c_y, c_s = closed_form(*case)
    print(f"Case {i}: IT({i_y}, {i_s:.2f}) vs CF({c_y}, {c_s:.2f})")

print("Iterative long:", timeit.timeit("iterative(0, 10000000, 10, 10, 5, 0.01, 60000)", globals=globals(), number=10000))
print("Closed Form long:", timeit.timeit("closed_form(0, 10000000, 10, 10, 5, 0.01, 60000)", globals=globals(), number=10000))
