-- task 1
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT c.name AS category, sum(p.amount) AS total_sales_revenue
FROM payment p
JOIN rental r ON r.rental_id = p.payment_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id = i.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE p.payment_date >= date_trunc('quarter', current_date)
	AND p.payment_date < date_trunc('quarter', current_date) + INTERVAL '3 months'
GROUP BY c.category_id
HAVING sum(p.amount) > 0;

SELECT * FROM sales_revenue_by_category_qtr;
--it will show nothing because in current quarter nothing sold

-- task 2
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(p_quarter_date DATE)
RETURNS TABLE (
    category TEXT,
    total_sales_revenue NUMERIC
)
LANGUAGE sql
AS $$
    SELECT
        c.name::TEXT AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM payment p
    JOIN rental r
        ON r.rental_id = p.rental_id
    JOIN inventory i
        ON i.inventory_id = r.inventory_id
    JOIN film_category fc
        ON fc.film_id = i.film_id
    JOIN category c
        ON c.category_id = fc.category_id
    WHERE p.payment_date >= date_trunc('quarter', p_quarter_date)
      AND p.payment_date <  date_trunc('quarter', p_quarter_date) + INTERVAL '3 months'
    GROUP BY c.category_id, c.name
    HAVING SUM(p.amount) > 0
    ORDER BY c.name;
$$;

-- test
-- SELECT * FROM get_sales_revenue_by_category_qtr('2017-01-19'::DATE);

-- task 3
CREATE OR REPLACE FUNCTION new_movie(p_title TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_film_id      INTEGER;
    v_language_id  INTEGER;
BEGIN
    IF p_title IS NULL OR btrim(p_title) = '' THEN
        RAISE EXCEPTION 'Movie title cannot be null or empty';
    END IF;

    SELECT language_id
    INTO v_language_id
    FROM language
    WHERE name = 'Klingon'
    LIMIT 1;

    IF v_language_id IS NULL THEN
        INSERT INTO language (name, last_update)
        VALUES ('Klingon', NOW())
        RETURNING language_id INTO v_language_id;
    END IF;

    v_film_id := nextval(pg_get_serial_sequence('film', 'film_id'));

    INSERT INTO film (
        film_id,
        title,
        description,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        replacement_cost,
        last_update
    )
    VALUES (
        v_film_id,
        p_title,
        'New movie added by function new_movie',
        EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
        v_language_id,
        3,
        4.99,
        19.99,
        NOW()
    );
END;
$$;