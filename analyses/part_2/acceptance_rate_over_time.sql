{% set grain = var('grain', 'month') %}

select
    date_trunc({{ grain }}, transacted_date) as period_start,
    count(*) as transactions,
    count_if(is_accepted) as accepted_transactions,
    round(accepted_transactions / transactions, 4) as acceptance_rate,
    round(sum(iff(is_accepted, amount_usd, 0)) / sum(amount_usd), 4) as acceptance_rate_by_amount
from {{ ref('fct_transactions') }}
group by period_start
order by period_start
