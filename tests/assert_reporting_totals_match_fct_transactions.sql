with

fct as (

    select
        count(*) as transactions,
        count_if(not is_accepted) as declined_transactions
    from {{ ref('fct_transactions') }}

)

select 'rpt_acceptance_rate_daily' as model_name
from {{ ref('rpt_acceptance_rate_daily') }}
having sum(transactions) <> (select transactions from fct)

union all

select 'rpt_declined_transactions_by_country' as model_name
from {{ ref('rpt_declined_transactions_by_country') }}
having sum(transactions) <> (select transactions from fct)
    or sum(declined_transactions) <> (select declined_transactions from fct)
