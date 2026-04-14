-- task 1
CREATE ROLE rentaluser LOGIN PASSWORD 'rentalpassword';
REVOKE ALL PRIVILEGES ON DATABASE dvdrental FROM rentaluser;
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

-- task 2
GRANT USAGE ON SCHEMA public TO rentaluser;
GRANT SELECT ON public.customer TO rentaluser;

SET ROLE rentaluser;
SELECT * FROM customer;

RESET ROLE;

-- task 3
CREATE ROLE rental;
GRANT rental TO rentaluser;

-- task 4
GRANT INSERT, UPDATE ON rental TO rental;
GRANT USAGE, SELECT ON SEQUENCE public.rental_rental_id_seq TO rental;
GRANT USAGE ON SCHEMA public TO rental;

SET ROLE rental

INSERT INTO rental (inventory_id, rental_date, customer_id, return_date, staff_id)
VALUES (100, '2026-01-01 10:00:00'::DATE, 2, '2026-02-01 10:00:00'::DATE, 1);

-- to use a statement where in update statement
GRANT SELECT ON rental TO rental;

UPDATE rental 
SET rental_date = '2026-02-01 19:00:00'::DATE 
WHERE rental_id = 3;

RESET ROLE;

SELECT * FROM rental WHERE rental_date = '2026-01-01 10:00:00'::DATE;
SELECT * FROM rental WHERE rental_id = 3;

-- task 5
REVOKE INSERT ON rental FROM rental;

SET ROLE rental;

INSERT INTO rental (inventory_id, rental_date, customer_id, return_date, staff_id)
VALUES (101, '2026-01-01 10:00:00'::DATE, 4, '2026-02-02 10:00:00'::DATE, 2);

RESET ROLE;

-- task 6
DROP TABLE IF EXISTS chosen_client;

CREATE TEMP TABLE chosen_client AS
SELECT c.customer_id, c.first_name, c.last_name, lower('client_' || c.first_name || '_' || c.last_name) AS role_name
FROM customer c
WHERE customer_id = 1;

SELECT * FROM chosen_client;

CREATE ROLE client_mary_smith LOGIN PASSWORD 'clientpass';

GRANT CONNECT ON DATABASE dvdrental TO client_mary_smith;
GRANT USAGE ON SCHEMA public TO client_mary_smith;
GRANT SELECT ON rental TO client_mary_smith;
GRANT SELECT ON rental TO client_mary_smith;

ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rental_client_policy ON rental;
DROP POLICY IF EXISTS payment_client_policy ON payment;

CREATE POLICY rental_client_policy
ON rental
FOR SELECT
TO PUBLIC
USING (
    customer_id = (
        SELECT c.customer_id
        FROM customer c
        WHERE lower('client_' || c.first_name || '_' || c.last_name) = current_user
        LIMIT 1
    )
);

CREATE POLICY payment_client_policy
ON payment
FOR SELECT
TO PUBLIC
USING (
    customer_id = (
        SELECT c.customer_id
        FROM customer c
        WHERE lower('client_' || c.first_name || '_' || c.last_name) = current_user
        LIMIT 1
    )
);

SET ROLE client_mary_smith;

SELECT * FROM rental;
SELECT * FROM payment;

RESET ROLE;

