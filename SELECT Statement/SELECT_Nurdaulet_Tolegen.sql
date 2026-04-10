-- 1) Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

-- first variant
with sum_of_revenue_per_staff as(
	select s.first_name || ' ' || s.last_name as full_name, s.store_id, revenue.rev
	from staff s 
	join (
		select sum(p.amount) as rev, p.staff_id
		from payment p 
		where extract(year from p.payment_date) = 2017
		group by p.staff_id
	) as revenue 
	on s.staff_id = revenue.staff_id
)
select *
from sum_of_revenue_per_staff t
where rev = (
    select MAX(rev)
    from sum_of_revenue_per_staff
    where store_id = t.store_id
);

-- second variant
select full_name, store_id, rev
from (
	select s.first_name || ' ' || s.last_name as full_name,
		s.store_id,
		sum(p.amount) as rev,
		rank() over (
			partition by s.store_id
			order by sum(p.amount) desc
		) as rnk
	from staff s
	join payment p on s.staff_id = p.staff_id
	where extract (year from p.payment_date) = 2017
	group by s.staff_id
)
where rnk = 1;

-- 2) Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

-- first variant
select f.title, f.rating, count(f.film_id) as rental_count
from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id 
group by f.film_id 
order by rental_count desc
limit 5;

--second variant
with rentals_film as (
	select i.film_id, count(i.film_id) as rentals
	from inventory i
	join rental r on i.inventory_id = r.inventory_id
	group by i.film_id
)

select f.title, f.rating, r.rentals
from film f
join rentals_film r on r.film_id = f.film_id 
order by r.rentals desc
limit 5;

-- 3) Which actors/actresses didn't act for a longer period of time than the others?

-- first variant
with actor_career as (
	select a.actor_id, 
		a.first_name || ' ' || a.last_name as full_name,
		max(f.release_year) - min(f.release_year) as career
	from actor a
	join film_actor fa on a.actor_id = fa.actor_id
	join film f on fa.film_id = f.film_id 
	group by a.actor_id
)

select *
from actor_career
where career = (
	select min(career)
	from actor_career
);

-- second variant
with actor_career as (
	select a.actor_id, 
		a.first_name || ' ' || a.last_name as full_name,
		max(f.release_year) - min(f.release_year) as career
	from actor a
	join film_actor fa on a.actor_id = fa.actor_id
	join film f on fa.film_id = f.film_id 
	group by a.actor_id
)

select * 
from actor_career
order by career asc, actor_id
limit 2;




