select
    transaction_id,
    globepay_event_id,
    transaction_state,
    country_code,
    currency_code,
    amount_local,
    fx_rate_to_usd,
    amount_usd,
    is_accepted,
    is_cvv_provided,
    is_chargeback,
    has_chargeback_data,
    transacted_at::date as transacted_date,
    transacted_at
from {{ ref('int_transactions_joined') }}
