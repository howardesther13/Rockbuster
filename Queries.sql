● Which movies contributed the most/least to revenue gain?
payment -> rental -> inventory -> film

SELECT f.title AS movie_title, p.amount AS revenue_generated
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventroy i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
ORDER BY p.amount ASC

● What was the average rental duration for all videos?
rental -> inventory -> film

SELECT f.title, AVG(return_date - rental_date) as avg_rental_duration 
FROM rental r
JOIN inventory i ON r.rental_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY avg_rental_duration DESC

● Which countries are Rockbuster customers based in?
customer -> address -> city -> country
SELECT DISTINCT co.country
FROM country co
JOIN city ci ON co.country_id = ci.country_id
JOIN address a ON ci.city_id = a.city_id
JOIN customer cust ON a.address_id = cust.address_id
ORDER BY co.country ASC

SELECT COUNT(*) FROM
(
	SELECT DISTINCT co.country
	FROM country co
	JOIN city ci ON co.country_id = ci.country_id
	JOIN address a ON ci.city_id = a.city_id
	JOIN customer cust ON a.address_id = cust.address_id
	ORDER BY co.country ASC
)

● Where are customers with a high lifetime value based?


● Do sales figures vary between geographic regions?
payment -> customer -> address -> city -> country 
SELECT co.country, SUM(p.amount) AS total_sales
FROM payment p
JOIN customer cust ON p.customer_id = cust.customer_id
JOIN address a ON cust.address_id = a.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.city_id
GROUP BY co.country
ORDER BY total_sales DESC


Top 10 countries for Rockbuster in terms of customer numbers
SELECT co.country, COUNT(cust.customer_id) as num_customer
FROM customer cust
JOIN address addr on cust.address_id = addr.address_id
JOIN city ci on addr.city_id = ci.city_id
JOIN country co on ci.country_id = co.country_id
GROUP BY co.country
ORDER BY num_customer DESC

Top 10 cities that fall within the top 10 countries 
SELECT ci.city_id, ci.city, co.country, count(cust.customer_id) as num_customer
FROM customer cust
JOIN address addr on cust.address_id = addr.address_id
JOIN city ci on addr.city_id = ci.city_id
JOIN country co on ci.country_id = co.country_id
WHERE co.country_id IN
(
	SELECT co.country_id
	FROM customer cust
	JOIN address addr on cust.address_id = addr.address_id
	JOIN city ci on addr.city_id = ci.city_id
	JOIN country co on ci.country_id = co.country_id
	GROUP BY co.country_id
	ORDER BY COUNT(cust.customer_id) DESC
	LIMIT 10
)
GROUP BY co.country_id, co.country, ci.city, ci.city_id
ORDER BY num_customer DESC


Top 5 customers from the top 10 cities who've paid the highest total amounts to Rockbuster
SELECT cust.first_name, cust.last_name, cust.email, ci.city, co.country
FROM customer cust
JOIN address addr on cust.address_id = addr.address_id 
JOIN city ci on addr.city_id = ci.city_id
JOIN country co on ci.country_id = co.country_id
WHERE addr.city_id IN
(
	SELECT ci.city_id
	FROM customer cust
	JOIN address addr on cust.address_id = addr.address_id
	JOIN city ci on addr.city_id = ci.city_id
	JOIN country co on ci.country_id = co.country_id
	WHERE co.country_id IN
	(
		SELECT co.country_id
		FROM customer cust
		JOIN address addr on cust.address_id = addr.address_id
		JOIN city ci on addr.city_id = ci.city_id
		JOIN country co on ci.country_id = co.country_id
		GROUP BY co.country_id
		ORDER BY COUNT(cust.customer_id) DESC
		LIMIT 10
	)
	GROUP BY co.country_id, co.country, ci.city, ci.city_id
	ORDER BY count(cust.customer_id) DESC
	LIMIT 10
)
ORDER BY ci.city