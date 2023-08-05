-- running customer balance column that includes the impact each transaction
with transactions as (select customer_id,
		sum(case when txn_type = 'deposit' then txn_amount else 0 end) as amount_deposit,
        sum(case when txn_type = 'purchase' then txn_amount else 0 end) as amount_purchase,
        sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as amount_withdraw
from customer_transactions
group by customer_id),
net_balance as (select customer_id, amount_deposit, amount_purchase, amount_withdraw, amount_deposit - (amount_purchase+ amount_withdraw) as Total_balance
from transactions)
select *
from net_balance;



-- customer balance at the end of each month
with transactions as (select customer_id, month(txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount else 0 end) as amount_deposit,
        sum(case when txn_type = 'purchase' then txn_amount else 0 end) as amount_purchase,
        sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as amount_withdraw
from customer_transactions
group by customer_id, month),
net_balance as (select customer_id, month, amount_deposit - (amount_purchase+ amount_withdraw) as closing_balance
from transactions)
select *
from net_balance;



-- minimum, average and maximum values of the running balance for each customer
with transactions as (select customer_id, month(txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount else 0 end) as amount_deposit,
        sum(case when txn_type = 'purchase' then txn_amount else 0 end) as amount_purchase,
        sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as amount_withdraw
from customer_transactions
group by customer_id, month),
gross as (select customer_id, month, amount_deposit - (amount_purchase+ amount_withdraw) as closing_balance
from transactions),
closing_balance as (select customer_id, month,SUM(closing_balance) OVER(PARTITION BY customer_id ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as closing
from gross
order by customer_id, month)
select customer_id, avg(closing) as average_running_balacne, min(closing) as min_running_balacne, max(closing) as max_running_balacne
from closing_balance
group by customer_id;

-- 