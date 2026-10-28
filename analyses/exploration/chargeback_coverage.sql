select
    acceptances.state,
    chargebacks.chargeback,
    count(*) as transactions,
    count_if(chargebacks.external_ref is null) as missing_chargeback_record
from {{ source('globepay', 'globepay_acceptance_report') }} as acceptances
full outer join {{ source('globepay', 'globepay_chargeback_report') }} as chargebacks
    on acceptances.external_ref = chargebacks.external_ref
group by acceptances.state, chargebacks.chargeback
order by acceptances.state, chargebacks.chargeback
