select
    external_ref as transaction_id,
    to_boolean(chargeback) as is_chargeback,
    _loaded_at
from {{ source('globepay', 'globepay_chargeback_report') }}
