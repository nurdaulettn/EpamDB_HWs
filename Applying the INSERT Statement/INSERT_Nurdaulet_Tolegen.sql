-- id of Eng language = 1
INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating) 
VALUES ('Graph Monte-Cristo','Very interesting drama, triller film' , 2024, 1, 14, 4.99, 178, 19.99, 'NC-17')
RETURNING *;

-- film_id = 1003
INSERT INTO actor (first_name, last_name) 
VALUES ('Pierrre', 'Niney'), ('Laurent', 'Lafitte'), ('Bastien', 'Bouillon') 
RETURNING *;

-- ids of this actors 207, 208, 209
INSERT INTO film_actor (actor_id, film_id) 
VALUES (207, 1003), (208, 1003), (209, 1003) 
RETURNING *;

INSERT INTO inventory (film_id, store_id) VALUES (1003, 1) RETURNING *;
