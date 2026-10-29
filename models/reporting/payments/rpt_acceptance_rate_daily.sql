select
    transacted_date,
    count(*) as transactions,
    count_if(is_accepted) as accepted_transactions,
    accepted_transactions / transactions as acceptance_rate,
    sum(amount_usd) as total_amount_usd,
    sum(iff(is_accepted, amount_usd, 0)) as accepted_amount_usd,
    accepted_amount_usd / nullif(total_amount_usd, 0) as acceptance_rate_by_amount
from {{ ref('fct_transactions') }}
group by transacted_date
