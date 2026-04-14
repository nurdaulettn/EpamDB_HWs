-- id of Eng language = 1
UPDATE film
SET rental_duration = 21, rental_rate = 9.99
WHERE title = 'Graph Monte-Cristo'
RETURNING *;

-- find a customer with 10 rental and 10 payment
SELECT c.customer_id, c.first_name, c.last_name, 
	count(DISTINCT r.rental_id) AS rental_coutn, 
	count(DISTINCT p.payment_id) AS payment_count 
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id 
JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id 
HAVING count(DISTINCT r.rental_id) >= 10
	AND count(DISTINCT p.payment_id) >= 10
ORDER BY c.customer_id;

-- select an address, check structure of customer table
SELECT * FROM address;
SELECT * FROM customer WHERE customer_id = 2;

-- Patricia Johnson has 54 rentals and 54 payments and id = 2 and i selected address with id = 2
UPDATE customer 
SET first_name = 'Nurdaulet', 
	last_name = 'Tolegen', 
	address_id = 2,
	email = 'nurdaulettolegen26@gmail.com',
	create_date = current_date,
	last_update = now()
WHERE customer_id = 2
RETURNING *;

