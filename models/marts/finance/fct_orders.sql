select
    order_id,
    customer_id,
    amount
    

from {{ ref("stg_jaffle_shop__orders") }}
join {{ ref('stg_stripe__payment') }} using(order_id)
