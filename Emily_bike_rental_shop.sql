select * from customer;
select * from bike;
select * from rental;
select * from membership_type;
select * from membership;

--Problem 5. Total revenue from rentals by month, year and all time across all the years

select extract(year from start_timestamp) as yrs
	  , extract(month from start_timestamp) as mnth
	  , sum(total_paid) as revenue
from rental
group by grouping sets ( (yrs, mnth),(yrs),() )
order by yrs, mnth

--Problem 7
-->total membership revenue for each month specific to each membership type
-->total membership revenue specific to each membership type
-->total membership revenue

select name,
	extract(month from start_date) as mnth,
	sum(total_paid) as total_revenue
from membership m
join membership_type mt
on mt.id = m.membership_type_id
group by cube (name, mnth)
order by name, mnth
--group by extensions
--grouping sets, rollup, cube

--Problem 1.
-->no of bikes the shop owns by category
--> category name & no. of bikes the shop owns in each category (number of bikes)
--> categories where no. of bikes > 2
select category
	, count(id) as number_of_bikes
from bike
group by category
having count(id) > 2

--Problem 2
-->customer names with total number of memberships purchased by each
--> display customer's name, count of membership purchased(membership_count)
-->order by membership count (desc order)
--> customers who haven't bought membership display (#) for membership count
select c.name,
		count(m.id) as membership_count
from membership m
right join customer c
on m.customer_id = c.id
group by c.name
order by membership_count desc

--Problem 3
-->new rental prices
--> display bike id, category, old price per hr(old_price_per_hour), discounted price per hour(new_price_per_hour), old price per day(old_price_per_day),
	discounted price per day(new_price_per_day )
-->electric bikes - 10% discount for hourly rentals, 20% discount for daily
-->mountain bikes - 20% hourly , 50% daily
-->others - 50% discount for all types of rentals
-->ROUND TO 2 DECIMAL PLACES
select id, category, 
	price_per_hour as old_price_per_hour,
	case when category = 'electric' then round (price_per_hour - (price_per_hour * 0.1), 2)
		 when category = 'mountain bike' then round (price_per_hour -(price_per_hour * 0.2), 2)
		else round (price_per_hour - (price_per_hour * 0.5), 2)
		end as new_price_per_hour
	,price_per_day as old_price_per_day
	, case when category = 'electric' then round(price_per_day - (price_per_day * 0.2), 2)
	  		when category = 'mountain bike' then round(price_per_day - (price_per_day * 0.5), 2)
			else round(price_per_day - (price_per_day * 0.5), 2)
			end as new_price_per_day
from bike;


--Problem 4
-->count of the rented bikes and available bikes in each category
-->display no. of available bikes(available_bikes_count), no. of rented bikes(rented_bikes_count) by category
select category,
	count(case when status = 'available' then 1 end) as available_bikes_count,
	count(case when status = 'rented' then 1 end) as rented_bikes_count
from bike
group by category;


--Problem 6
-->total revenue from memberships each year, month, membership type
-->display year, month, name of membership type(membership_type_name), total revenue(total_revenue)
--> order by year, month, name of membership type name
select name as membership_type_name,
		extract(year from start_date) as yr,
		extract(month from start_date) as mnth,
		sum(total_paid) as total_revenue
from membership m
join  membership_type mt
on mt.id = m.membership_type_id
group by yr, mnth, membership_type_name
order by yr, mnth, membership_type_name

--Problem 8
-->segment customers based on no. of rentals
-->count of customers in each segment
CATEGORIZE BASED ON THE BELOW
-->more than 10 rentals (more then 10)
--> 5-10 rentals(inclusive) as (between 5 and 10)
--> fewer than 5 rentals (fewer than 5)
--> no.of customers in each category
--> display 2 columns(rental_count_category) & customer_count- no. of customers in each category

with cte as
	(select customer_id, count(id),
		  case when count(id) > 10 then 'more than 10'
		   when count(id) between 5 and 10 then 'between 5 and 10'
		   else 'fewer than 5'
		   end as category
		   from rental
	        group by customer_id)
select category as rental_count_category,
   count(*) as customer_count
from cte
group by category
order by customer_count
