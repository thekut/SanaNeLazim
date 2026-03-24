import time
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

    # FV = P*(1+r)^n + PMT/r * ((1+r)^n - 1)
    # FV + PMT/r = (P + PMT/r) * (1+r)^n
    # n = ln( (FV + PMT/r) / (P + PMT/r) ) / ln(1+r)

    PMT_over_r = annual_savings / annual_return_rate
    numerator = target_nest_egg + PMT_over_r
    denominator = current_savings + PMT_over_r

    # if denominator <= 0, which shouldn't happen here since current_savings >= 0 and PMT > 0
    n = math.log(numerator / denominator) / math.log(1 + annual_return_rate)

    years_to_freedom = math.ceil(n)
    if years_to_freedom > 60:
        years_to_freedom = 60

    # calculate final savings after exactly years_to_freedom whole years
    final_savings = current_savings * (1 + annual_return_rate)**years_to_freedom + annual_savings / annual_return_rate * ((1 + annual_return_rate)**years_to_freedom - 1)

    return years_to_freedom, final_savings

# Test
print(iterative(1000, 2000, 100, 0.05))
print(closed_form(1000, 2000, 100, 0.05))
