select
    external_ref as transaction_id,
    ref as globepay_event_id,
    upper(state) as transaction_state,
    upper(country) as country_code,
    upper(currency) as currency_code,
    amount::number(18, 2) as amount_local,
    parse_json(rates) as fx_rates,
    get(fx_rates, currency_code)::float as fx_rate_to_usd,
    (amount_local / fx_rate_to_usd)::number(18, 2) as amount_usd,
    upper(state) = 'ACCEPTED' as is_accepted,
    to_boolean(cvv_provided) as is_cvv_provided,
    convert_timezone('UTC', to_timestamp_tz(date_time))::timestamp_ntz as transacted_at,
    _loaded_at
from {{ source('globepay', 'globepay_acceptance_report') }}
