select
    acceptances.transaction_id,
    acceptances.globepay_event_id,
    acceptances.transaction_state,
    acceptances.country_code,
    acceptances.currency_code,
    acceptances.amount_local,
    acceptances.fx_rate_to_usd,
    acceptances.amount_usd,
    acceptances.is_accepted,
    acceptances.is_cvv_provided,
    chargebacks.is_chargeback,
    chargebacks.transaction_id is not null as has_chargeback_data,
    acceptances.transacted_at
from {{ ref('stg_globepay__acceptances') }} as acceptances
left join {{ ref('stg_globepay__chargebacks') }} as chargebacks
    on acceptances.transaction_id = chargebacks.transaction_id
