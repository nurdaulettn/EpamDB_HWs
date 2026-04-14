SELECT * FROM film WHERE title = 'Graph Monte-Cristo';

-- film_id = 1003
-- find corresponding inventory
SELECT inventory_id, film_id, store_id
FROM inventory 
WHERE film_id = 1003;

-- find corresponding rentals
SELECT rental_id, inventory_id, customer_id
FROM rental 
WHERE inventory_id IN (
	SELECT inventory_id FROM inventory WHERE film_id = 1003
);

DELETE FROM payment 
WHERE rental_id IN (
	SELECT rental_id
	FROM rental 
	WHERE inventory_id IN (
		SELECT inventory_id FROM inventory WHERE film_id = 1003
	)
);

DELETE FROM rental 
WHERE inventory_id IN (
	SELECT inventory_id FROM inventory WHERE film_id = 1003
);

DELETE FROM inventory WHERE film_id = 1003;

-- find my customer_id
SELECT * FROM customer WHERE first_name = 'Nurdaulet' AND last_name = 'Tolegen';

-- customer_id = 2
-- see rentals, payments of this customer
SELECT rental_id, inventory_id, rental_date FROM rental WHERE customer_id = 2;
SELECT payment_id, customer_id, rental_id, amount FROM payment WHERE customer_id = 2;

-- delete this rentals and payments
DELETE FROM payment WHERE customer_id = 2;
DELETE FROM rental WHERE customer_id = 2;



