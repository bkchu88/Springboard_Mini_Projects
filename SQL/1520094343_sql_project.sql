/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

-- Answer: Massage Room 1, Massage Room 2, Tennis Court 1, Tennis Court 2, Squash Court
SELECT name 
FROM  `Facilities` 
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */

-- Answer: 4
SELECT Count(*)
FROM  `Facilities` 
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

-- Answer: Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2, Squash Court
SELECT facid, name AS  "facility name", membercost AS  "member cost", monthlymaintenance AS "monthly maintenance"
FROM  `Facilities` 
WHERE membercost >0
AND membercost < ( 0.2 * monthlymaintenance ) 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE facid IN ( 1, 5 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
	CASE WHEN monthlymaintenance <100 THEN  'cheap'
	ELSE  'expensive' END AS label
FROM  `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
JOIN 
-- subquery to determine max joindate, so we can link to members table
(
	SELECT MAX(joindate) AS join_date
	FROM Members) m 
ON Members.joindate = m.join_date

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

-- showed Tennis Court 1 and 2 separately because the question requested the output of the name of the court.
SELECT DISTINCT CONCAT( Members.surname,  ', ', Members.firstname ) AS member_name, Facilities.name AS facility_name
FROM  `Bookings` 
JOIN Members ON Bookings.memid = Members.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE  '%Tennis Court%'
ORDER BY member_name, facility_name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Bookings.starttime, Facilities.name as facility_name,concat(Members.surname,', ',Members.firstname) as member_name,
	-- cost = member or guest fee * number of half hour slots
	CASE WHEN Members.memid = 0 THEN Facilities.guestcost * Bookings.slots
	ELSE Facilities.membercost * Bookings.slots END as cost
FROM Bookings
JOIN Members ON Bookings.memid = Members.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE DATE(Bookings.starttime) = '2012-09-14' AND 	
	CASE WHEN Members.memid = 0 THEN Facilities.guestcost * Bookings.slots
	ELSE Facilities.membercost * Bookings.slots END > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT b.starttime, Facilities.name as facility_name, concat(Members.surname, ', ', Members.firstname) as member_name,
	CASE WHEN Members.memid = 0 THEN Facilities.guestcost * b.slots
	ELSE Facilities.membercost * b.slots END AS cost
FROM 
(
    SELECT starttime, memid, facid, slots
	FROM Bookings
	WHERE DATE(starttime) = '2012-09-14') b
JOIN Members ON b.memid = Members.memid
JOIN Facilities ON b.facid = Facilities.facid
WHERE 	
	CASE WHEN Members.memid = 0 THEN Facilities.guestcost * b.slots > 30
	ELSE Facilities.membercost * b.slots > 30 END 
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facility_name, SUM(revenue) total_revenue
FROM
	-- subquery to calculate revenue by booking, so it can be aggregated in the outer query
	(SELECT Facilities.name as facility_name,
		CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
		ELSE Facilities.membercost * Bookings.slots END AS revenue
	FROM Bookings
	JOIN Facilities
	ON Bookings.facid = Facilities.facid) sub
GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue