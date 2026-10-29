select
    transaction_id,
    globepay_event_id,
    transacted_at,
    transaction_state,
    country_code,
    amount_usd
from {{ ref('fct_transactions') }}
where not has_chargeback_data
