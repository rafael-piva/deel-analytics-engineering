select
    count(*) as row_count,
    count(distinct external_ref) as distinct_external_ref,
    count(distinct ref) as distinct_ref,
    count_if(external_ref is null or ref is null) as missing_ids,
    min(date_time) as first_transaction,
    max(date_time) as last_transaction,
    count(distinct left(date_time, 10)) as distinct_days,
    count(distinct status) as distinct_status,
    count(distinct source) as distinct_source,
    count_if(state = 'ACCEPTED') as accepted,
    count_if(state = 'DECLINED') as declined,
    count_if(cvv_provided = 'TRUE') as cvv_provided,
    min(amount::number(18, 2)) as min_amount,
    max(amount::number(18, 2)) as max_amount,
    median(amount::number(18, 2)) as median_amount,
    count_if(amount::number(18, 2) <= 0) as non_positive_amounts,
    count(distinct rates) as distinct_rate_sets
from {{ source('globepay', 'globepay_acceptance_report') }}
