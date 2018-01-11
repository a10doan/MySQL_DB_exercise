use sakila;

SHOW TABLES FROM sakila;
SHOW COLUMNS FROM actor;

-- 1A. SHOWING FIRST AND LAST NAMES OF ACTOR COLUMNS
SELECT first_name, last_name FROM actor;

-- 1B. SHOWING THE FIRST NAMES IN CAPS AND RENAMING THE COLUMN
SELECT first_name AS `Actor Name` FROM actor;

-- 2A. SEARCHING FOR JOE 
SELECT first_name, last_name, actor_id FROM actor WHERE first_name = "JOE";

-- 2B. SEARCHING FOR ANY LAST NAMES CONTAINING "GEN"
SELECT first_name, last_name, actor_id FROM actor WHERE (last_name LIKE "%GEN%");

-- 2C. SEARCHING FOR LAST NAME CONTAINING "LI"
SELECT first_name, last_name, actor_id FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2D. DISPLAY COUNTRIES USING 'IN' CLAUSE
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3A. ADDING NEW COLUMN TO 'ACTOR', SPECIFYING DATA TYPE AS VARCHAR()
ALTER TABLE actor
ADD COLUMN `middle_name` VARCHAR(45) NOT NULL AFTER `first_name`;

-- 3B. CHANGING DATA TYPE OF MIDDLE NAME COLUMN FROM VARCHAR TO BLOB
ALTER TABLE actor
CHANGE COLUMN `middle_name` `middle_name` BLOB NOT NULL;
SHOW COLUMNS FROM actor;

-- 3C. ALTER TABLE TO DELETE MIDDLE_NAME COLUMN
-- SET SQL_SAFE_UPDATES = 0; -- disable safe mode
ALTER TABLE actor 
DROP COLUMN middle_name;
-- SET SQL_SAFE_UPDATES = 1; -- re-enable safe mode

-- 4A. COUNTING THE NUMBER OF LAST NAMES
SELECT last_name FROM actor;
SELECT last_name, count(last_name) as count FROM actor GROUP BY last_name;

-- 4B. FILTER ACTORS THAT SHARE THE SAME LAST NAMES
SELECT last_name, count(last_name) as count FROM actor GROUP BY last_name HAVING count>1;

-- 4C. CHANGING GROUCHO TO HARPO
SELECT actor_id, first_name, last_name FROM actor where first_name = "GROUCHO" AND last_name = "WILLIAMS";
SELECT actor_id FROM actor where first_name = "GROUCHO" AND last_name = "WILLIAMS";
UPDATE actor SET `first_name` = "HARPO" 
	WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
SELECT actor_id, first_name, last_name FROM actor where first_name = "HARPO" AND last_name = "WILLIAMS";

-- ERROR CODE: 1093 fix??
-- UPDATE actor SET `first_name` = "GROUCHO" 
-- 	WHERE actor_id IN
--     (
-- 		SELECT actor_id from (select actor_id from actor where `first_name` = "HARPO" and last_name = "WILLIAMS") as dummy);

-- 4D. 
SELECT actor_id, first_name, last_name from actor where first_name = "HARPO";
UPDATE actor SET `first_name` = "GROUCHO" 
	WHERE actor_id = 172;
SELECT actor_id, first_name, last_name from actor where actor_id = 172;

-- 5A. 
SHOW COLUMNS FROM address;
CREATE TABLE new_address LIKE address;  -- Re-create another schema identical to original
INSERT INTO new_address SELECT * FROM address;  -- insert all data from old table (creating a duplicate table at this point)
-- CREATE TABLE new_address(select * from address);
-- SHOW COLUMNS FROM new_address;
-- DROP TABLE new_address;
SELECT * FROM new_address;
SELECT * FROM address;

-- 6A.
SELECT * FROM staff;
SELECT * FROM address;
SELECT first_name, last_name, address FROM staff INNER JOIN address ON staff.address_id = address.address_id;

-- 6B. 
SELECT * FROM staff;
SELECT * FROM payment;
SELECT first_name, last_name, payment_date, SUM(amount) AS total FROM staff INNER JOIN payment ON staff.staff_id = payment.staff_id 
WHERE payment_date LIKE "2005-08%" GROUP BY last_name;

-- 6C.  
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT title, count(actor_id) FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id GROUP BY title;

-- 6D. 
SELECT * FROM inventory;
SELECT * FROM film;

SELECT COUNT(inventory_id) FROM inventory INNER JOIN film ON film.film_id = inventory.film_id WHERE film.film_id IN
(SELECT film.film_id FROM film WHERE film.title = "HUNCHBACK IMPOSSIBLE");

SELECT film_id FROM film WHERE film.title = "HUNCHBACK IMPOSSIBLE";
SELECT * FROM inventory WHERE film_id = 439;

-- 6E.
SELECT * FROM payment;
SELECT * FROM customer;

SELECT first_name, last_name, SUM(amount) AS Total_Paid FROM payment INNER JOIN customer
ON customer.customer_id = payment.customer_id GROUP BY last_name;

-- 7A. 
SELECT * FROM film;
SELECT * FROM language;

SELECT title FROM film
WHERE ((title LIKE "K%") OR (title LIKE "Q%")) AND title IN (
	SELECT title FROM film 
	WHERE language_id IN (
		SELECT language_id FROM language
		WHERE name = "English"));
        
-- 7B.  
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT first_name, last_name FROM actor 
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
    WHERE film_id IN (
		SELECT film_id FROM film 
        WHERE title = "ALONE TRIP"));
        
-- 7C.  
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;
SELECT * FROM customer;

SELECT first_name, last_name, address, email, country FROM 
(((address INNER JOIN customer ON address.address_id = customer.address_id)
INNER JOIN city ON address.city_id = city.city_id) 
INNER JOIN country ON country.country_id = city.country_id) WHERE country = "Canada";

-- 7D. 
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM category;

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_category
    WHERE category_id IN (
		SELECT category_id FROM category
        WHERE name = "Family"));

-- 7E.  
-- select *, count(customer_id) from rental group by inventory_id;
-- select * from inventory;
-- select * from rental;
-- select * from film;

-- SELECT * FROM rental GROUP BY inventory_id;
-- SELECT *, COUNT(rental_id) FROM rental GROUP BY inventory_id;
-- SELECT *, ( 
-- 			SELECT COUNT(rental_id) 
-- 			FROM rental 
--            WHERE rental.inventory_id = inventory.inventory_id) 
--            FROM inventory;

-- SELECT *, 
-- 	SUM((SELECT COUNT(inventory_id) 
--    FROM rental
--    WHERE rental.inventory_id = inventory.inventory_id)) AS total_rented
--    FROM inventory GROUP BY film_id;

DROP TABLE IF EXISTS rented_value;      
CREATE TABLE rented_value( SELECT film_id,
	SUM((SELECT COUNT(inventory_id) 
    FROM rental
    WHERE rental.inventory_id = inventory.inventory_id)) AS total_rented
    FROM inventory GROUP BY film_id);
SELECT title, total_rented FROM rented_value INNER JOIN film ON rented_value.film_id = film.film_id 
	ORDER BY total_rented DESC;
    
-- 7F. 
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT film_id, store_id, 
 	SUM((SELECT COUNT(rental_id) 
    FROM rental
    WHERE rental.inventory_id = inventory.inventory_id)) AS total_rented
    FROM inventory GROUP BY film_id;
    
select rental.rental_id, inventory_id, payment_id, sum(amount) 
	from rental inner join payment on rental.rental_id = payment.rental_id 
	group by inventory_id;
    