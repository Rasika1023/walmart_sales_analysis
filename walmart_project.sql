select * from walmart 

--distinct payment_method
select distinct payment_method 
from walmart

--all the transactions by the payment method 
select payment_method, count(*) transactions
from walmart
group by payment_method

--total distinct branches 
select distinct branch
from walmart --error because of column  name in caps.

--alter table walmart rename column Branch to branch(column doesnt exists)
drop table walmart

select branch, count(*)
from walmart
group by branch,city

--BUSINESS PROBLEMS
--Q1: Find different payment methods and number of transactions, number of quantity sold.
select payment_method, count(*) as transactions, sum(quantity) as no_of_quantity
from walmart
group by payment_method

--Q2: Identify the highest-rated category in each barnch, displaying the branch category avg rating.
select * 
from(
	select branch,category, avg(rating) as avg_rating, rank() over(partition by branch order by avg(rating) desc ) as rank
	from walmart 
	group by branch,category) rank
where rank=1

--Q3: identify the busiest day for each branch based on the number of transactions.
select * from walmart

select *
from(
	select branch, 
	to_char(to_date(date,'dd/mm/yy'),'day') as formated_date, 
	count(*) as transac, 
	rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by branch,2) where rank =1

--Q4: calculate the total quantity of items sold per payment method and total quantity.
select payment_method, sum(quantity) as no_of_quantity
from walmart
group by payment_method

--Q5: determine the avg,min,max rating of caetgory for each city.
--list the city, avg_rating, min_rating and max_rating
select * 
from(
	select city,category, avg(rating) as avge,max(rating) maxi, min(rating) as mini,
	rank() over(partition by city order by avg(rating),max(rating),min(rating) desc)
	from walmart 
	group by city,category) where rank=1

--Q6: calculate the total profit for each category by considering total profit as unit_price*quantity*profit_margin
--list category and total profit oredered from highest to lowest.
select category, sum(total*profit_margin) as profit
from walmart
group by category

select * from walmart

--Q7: determine the most common payment method for each branch. Display branch and prefered payment_method
with cte
as
(
select branch,payment_method, count(*) as total_transac, rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by branch, payment_method 
) select * from cte
where rank=1

--Q8: categorize sales into 3 group morning, afternoon, evening . find out which of the shift and number of invoices.
select *, 
time::time
from walmart    --conversion from text to time

select branch,
case
	when extract(hour from(time::time))<12 then 'morning'
	when extract(hour from (time::time))  between 12 and 17 then 'afternoon'
	else 'evening'
end day_time,
count(*)
from walmart
group by 1,2
order by 1,3 desc

--Q9: identify 5 branch with highest decrase ratio in revenue coampre to last year(current year 2023 and last year 2022)
rdr=last_rev-cr_rev/(ls_rev*100)

select *,
extract (year from to_date(date,'dd/mm/yy')) as formated_date
from walmart 

with revenue_2022 as
(
	select branch, sum(total) as revenue
	from walmart
	where extract (year from to_date(date,'dd/mm/yy')) =2022
	group by 1
),
 revenue_2023 as
(
	select branch, sum(total) as revenue
	from walmart
	where extract (year from to_date(date,'dd/mm/yy')) =2023
	group by 1
)
select ls.branch,ls.revenue as last_yr_revnue, cs.revenue as curr_yr_revenue
from revenue_2022 as ls
join revenue_2023 as cs on ls.branch=cs.branch

