with customers as (

    select *
    from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select *
    from {{ ref('stg_jaffle_shop__orders') }}

),

customer_payment as (
    select
        order_id,
        sum(case when status = 'success' then amount end) as total

    from {{ ref("stg_stripe__payment") }}

    group by 1
),

customer_orders as (

    select
        customer_id,
    

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(total) as total

    from orders
    left join customer_payment using(order_id)

    group by 1

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(customer_orders.total,0) as lifetime_value

    from customers

    left join customer_orders using (customer_id)

)

select * from final