select
    country_code,
    count(*) as declined_transactions,
    sum(amount_usd) as declined_amount_usd
from {{ ref('fct_transactions') }}
where not is_accepted
group by country_code
having declined_amount_usd > 25000000
order by declined_amount_usd desc
