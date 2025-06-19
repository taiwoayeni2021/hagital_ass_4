USE sakila

-- 1. Retrieve the names of customers who have spent more than the average total spending across all customers
SELECT CONCAT(first_name, ' ',last_name) full_name, SUM(amount) total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY full_name
HAVING total_spent > (SELECT AVG(amount)
FROM payment)
ORDER BY total_spent DESC;

-- 2. Create a view called high_spenders that shows customer name and total spent, only if the total exceeds $150
CREATE VIEW high_spenders AS
SELECT CONCAT(first_name, ' ', last_name) customer_name, SUM(amount) total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY customer_name
HAVING total_spent > 150;

SELECT * FROM high_spenders;

-- 3. Write a stored procedure GetCustomerHistory that takes a customer ID 
-- and returns their rental history (film title, rental date).
DELIMITER //
CREATE PROCEDURE GetCustomerHistory(IN cust_id INT)
BEGIN
    SELECT f.title film_title, r.rental_date
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    WHERE r.customer_id = cust_id
    ORDER BY r.rental_date DESC;
END //
DELIMITER;


-- 4. Rank each customer's spending within their city using a window function
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) customer_name, ci.city, SUM(amount) total_spent,
    RANK() OVER (
        PARTITION BY ci.city_id
        ORDER BY SUM(amount) DESC
    ) spending_rank
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, ci.city_id
ORDER BY ci.city;
