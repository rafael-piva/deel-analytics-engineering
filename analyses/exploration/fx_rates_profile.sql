select
    rates.key as currency,
    count(*) as observations,
    min(rates.value::float) as min_rate,
    max(rates.value::float) as max_rate,
    round(max(rates.value::float) / min(rates.value::float) - 1, 3) as max_swing
from {{ source('globepay', 'globepay_acceptance_report') }} as acceptances,
    lateral flatten(input => parse_json(acceptances.rates)) as rates
group by rates.key
order by rates.key
