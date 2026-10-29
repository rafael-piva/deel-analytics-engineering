select
    country,
    currency,
    count(*) as transactions,
    count_if(state = 'ACCEPTED') as accepted,
    round(sum(amount::number(18, 2)), 2) as amount_local
from {{ source('globepay', 'globepay_acceptance_report') }}
group by country, currency
order by country
