select
    country_code,
    count(*) as transactions,
    count_if(not is_accepted) as declined_transactions,
    sum(iff(not is_accepted, amount_usd, 0)) as declined_amount_usd
from {{ ref('fct_transactions') }}
group by country_code
