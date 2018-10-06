-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(upper(first_name), ' ', upper(last_name)) as Actor_Name 
from sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from sakila.actor
where upper(first_name) = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
select *
from sakila.actor
where upper(last_name) like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
-- in that order:
select *
from sakila.actor
where upper(last_name) like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from sakila.country
where upper(country) in('AFGHANISTAN', 'BANGLADESH', 'CHINA');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type 
-- BLOB, as the difference between it and VARCHAR are significant).
alter table sakila.actor
add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
alter table sakila.actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as lname_count
from sakila.actor
group by 1;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared 
-- by at least two actors
select last_name, count(last_name) as lname_count
from sakila.actor
group by 1
having lname_count > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
update sakila.actor
set first_name = 'HARPO'
where upper(first_name)='GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update sakila.actor
set first_name = 'GROUCHO'
where upper(first_name)='HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
select a.first_name, a.last_name, b.address
from sakila.staff a
inner join sakila.address b on a.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select a.staff_id, sum(amount) as total_amount
from sakila.staff a
inner join sakila.payment b on a.staff_id = b.staff_id
where cast(payment_date as date) between date'2005-08-01' and date'2005-08-31'
group by a.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select a.title, count(actor_id) as num_of_actors
from sakila.film a
left join sakila.film_actor b on a.film_id = b.film_id
group by 1;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(a.inventory_id) as num_of_copies
from sakila.inventory a
inner join sakila.film b on a.film_id = b.film_id
where upper(b.title) = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select a.first_name, a.last_name, sum(b.amount) as total_paid
from sakila.customer a
left join sakila.payment b on a.customer_id = b.customer_id
group by a.first_name, a.last_name
order by a.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of 
-- movies starting with the letters K and Q whose language is English.
select title from sakila.film
where (upper(title) like 'K%'
or upper(title) like 'Q%')
and language_id in(select language_id from sakila.language where upper(name) = 'ENGLISH');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name, a.last_name
from sakila.actor a
inner join sakila.film_actor b on a.actor_id = b.actor_id
inner join sakila.film c on b.film_id = c.film_id
where upper(c.title) = 'ALONE TRIP';

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.
select a.first_name, a.last_name, a.email
from sakila.customer a
inner join sakila.address b on a.address_id = b.address_id
inner join sakila.city c on b.city_id = c.city_id
inner join sakila.country d on c.country_id = d.country_id and upper(d.country) = 'CANADA';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select a.title
from sakila.film a
inner join sakila.film_category b on a.film_id = b.film_id
inner join sakila.category c on b.category_id = c.category_id and upper(c.name) = 'FAMILY';

-- 7e. Display the most frequently rented movies in descending order.
-- Made it a LEFT JOIN to capture movies that have not been rented
select a.title, count(c.rental_id) as rental_cnt
from sakila.film a
left join sakila.inventory b on a.film_id = b.film_id
left join sakila.rental c on b.inventory_id = c.inventory_id
group by a.title
order by rental_cnt desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select a.store_id, sum(c.amount) as total_business
from sakila.store a
inner join sakila.staff b on a.store_id = b.store_id
inner join sakila.payment c on b.staff_id = c.staff_id
group by a.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select a.store_id, c.city, d.country
from sakila.store a
inner join sakila.address b on a.address_id = b.address_id
inner join sakila.city c on b.city_id = c.city_id
inner join sakila.country d on c.country_id = d.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select a.name, sum(e.amount) as gross_revenue
from sakila.category a
inner join sakila.film_category b on a.category_id = b.category_id
inner join sakila.inventory c on b.film_id = c.film_id
inner join sakila.rental d on c.inventory_id = d.inventory_id
inner join sakila.payment e on d.rental_id = e.rental_id
group by a.name
order by gross_revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top 
-- five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view sakila.top5genres as
select a.name, sum(e.amount) as gross_revenue
from sakila.category a
inner join sakila.film_category b on a.category_id = b.category_id
inner join sakila.inventory c on b.film_id = c.film_id
inner join sakila.rental d on c.inventory_id = d.inventory_id
inner join sakila.payment e on d.rental_id = e.rental_id
group by a.name
order by gross_revenue desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from sakila.top5genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view sakila.top5genres;