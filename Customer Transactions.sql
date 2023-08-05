-- What is the unique count and total amount for each transaction type?
select txn_type, count(txn_type) as num_transaction, sum(txn_amount) as Total_amount
from customer_transactions
group by txn_type;


--  What is the average total historical deposit counts and amounts for all customers
with deposit as (select customer_id,count(txn_type) as num_of_deposit, avg(txn_amount) as avg_deposit_per_customer
from customer_transactions
where txn_type = 'deposit'
group by customer_id)

select round(avg(num_of_deposit)) as Average_num_of_deposit, round(avg(avg_deposit_per_customer)) as Average_amount_deposited
from deposit;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with customer_pattern as (select customer_id, monthname(txn_date) as month,
		sum(case when txn_type = 'deposit' then 1 else 0 end) as num_deposit,
        sum(case when txn_type = 'purchase' then 1 else 0 end) as num_purchase,
        sum(case when txn_type = 'withdrawal' then 1 else 0 end) as num_withdraw
from customer_transactions
group by customer_id, month)

select month, count(customer_id)
from customer_pattern
where num_deposit > 1 and num_purchase = 1 or num_withdraw = 1
group by month;

-- What is the closing balance for each customer at the end of the month?
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
select customer_id, month,closing
from closing_balance;

-- What is the percentage of customers who increase their closing balance by more than 5%?
with transactions as (select customer_id, month(txn_date) as month,
		sum(case when txn_type = 'deposit' then txn_amount else 0 end) as amount_deposit,
        sum(case when txn_type = 'purchase' then txn_amount else 0 end) as amount_purchase,
        sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as amount_withdraw
from customer_transactions
group by customer_id, month),
gross as (select customer_id, month, amount_deposit - (amount_purchase + amount_withdraw) as closing_balance
from transactions),
closing_balance as (
	select customer_id, month,
		   SUM(closing_balance) OVER(PARTITION BY customer_id ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as closing
	from gross
	order by customer_id, month),
open as (
			select customer_id, month,closing, lag(closing) over (PARTITION BY customer_id ORDER BY month) as opening_balance
			from closing_balance)

select b.month, round(num*100/nume,1) as percentage_of_customer
from (select month, count(customer_id) as num
		from open 
        where closing > ((0.005*opening_balance) + opening_balance) group by month) as o,
	(select month, count(*) as nume
    from open 
    where month <> 1 group by month) as b
 where o.month = b.month;
 
 ---
 -- 