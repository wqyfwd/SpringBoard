/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM `Facilities` 
WHERE membercost != 0;

Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0 ;

4


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance
      AND membercost != 0;

Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court
      

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);



/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
       (CASE WHEN monthlymaintenance > 100 THEN 'expensive'
             ELSE 'cheap' END ) AS label
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = 
      (SELECT MAX(joindate)
       FROM Members);
       
Darren Smith


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT_WS(' ',m.firstname, m.surname) as membername, f.name
FROM Members AS m
INNER JOIN Bookings AS b
ON b.memid = m.memid
INNER JOIN Facilities AS f
ON f.facid = b.facid
WHERE f.name LIKE 'Tennis%'
      AND firstname != 'GUEST'
ORDER BY membername;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT_WS(' ',m.firstname, m.surname) AS membername,
        f.name,
        SUM(b.slots * f.membercost) AS cost
FROM Members AS m
INNER JOIN Bookings AS b
ON b.memid = m.memid
INNER JOIN Facilities AS f
ON f.facid = b.facid
WHERE b.starttime LIKE '2012-09-14%'
      AND firstname != 'GUEST'
GROUP BY membername
HAVING cost > 30
UNION ALL
SELECT CONCAT_WS(' ',m.firstname, m.surname) AS membername,
        f.name,
        b.slots * f.guestcost AS cost
FROM Members AS m
INNER JOIN Bookings AS b
ON b.memid = m.memid
INNER JOIN Facilities AS f
ON f.facid = b.facid
WHERE b.starttime LIKE '2012-09-14%'
      AND firstname = 'GUEST'
HAVING cost > 30 
ORDER BY cost DESC;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT CONCAT_WS(' ',s.firstname, s.surname) AS membername,
       s.name,
       SUM(s.slots * s.membercost) AS cost
FROM 
   (
   SELECT m.firstname,
          m.surname,
          b.slots,
          f.name,
          f.guestcost,
          f.membercost
   FROM 
          Members AS m
      INNER JOIN 
          Bookings AS b USING (memid)
      INNER JOIN 
          Facilities AS f USING (facid)
   WHERE b.starttime LIKE '2012-09-14%'
    ) AS s
WHERE s.firstname != 'GUEST'
GROUP BY membername
HAVING cost > 30
UNION ALL
SELECT CONCAT_WS(' ',s.firstname, s.surname) AS membername,
       s.name,
      (s.slots * s.guestcost) AS cost
FROM 
   (
   SELECT m.firstname,
          m.surname,
          b.slots,
          f.name,
          f.guestcost,
          f.membercost
   FROM 
          Members AS m
      INNER JOIN 
          Bookings AS b USING (memid)
      INNER JOIN 
          Facilities AS f USING (facid)
   WHERE b.starttime LIKE '2012-09-14%'
    ) AS s
WHERE s.firstname='GUEST'
HAVING cost > 30
ORDER BY cost DESC;




/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT f.name,
       sum(ss.cost) - f.monthlymaintenance * 3 AS TotalRevenue
FROM Facilities AS f
INNER JOIN 
(SELECT CONCAT_WS(' ',s.firstname, s.surname) AS membername,
       s.name,
       (s.slots * s.membercost) AS cost
FROM 
   (
   SELECT m.firstname,
          m.surname,
          b.slots,
          f.name,
          f.guestcost,
          f.membercost
   FROM 
          Members AS m
      INNER JOIN 
          Bookings AS b USING (memid)
      INNER JOIN 
          Facilities AS f USING (facid)
    ) AS s
WHERE s.firstname != 'GUEST'
UNION ALL
SELECT CONCAT_WS(' ',s.firstname, s.surname) AS membername,
       s.name,
      (s.slots * s.guestcost) AS cost
FROM 
   (
   SELECT m.firstname,
          m.surname,
          b.slots,
          f.name,
          f.guestcost,
          f.membercost
   FROM 
          Members AS m
      INNER JOIN 
          Bookings AS b USING (memid)
      INNER JOIN 
          Facilities AS f USING (facid)
    ) AS s
WHERE s.firstname='GUEST') AS ss
 USING(name)
GROUP BY name
HAVING TotalRevenue < 1000;

output

('Pool Table', 225)
('Snooker Table', 195)
('Table Tennis', 150)


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
 query1 = """
        SELECT m.firstname,
               m.surname, 
               m.recommendedby, 
               s.firstname AS recommenderFirstname, 
               s.surname AS recommenderSurname
        FROM Members AS m
        INNER JOIN (SELECT memid,firstname, surname
                    FROM Members 
                    WHERE firstname != 'GUEST') AS s
        ON s.memid = m.recommendedby
        WHERE m.firstname != 'GUEST'
        ORDER BY m.firstname, m.surname;
        """
        
output:
 ('Anna', 'Mackenzie', '1', 'Darren', 'Smith')
('Anne', 'Baker', '9', 'Ponder', 'Stibbons')
('Charles', 'Owen', '1', 'Darren', 'Smith')
('David', 'Jones', '4', 'Janice', 'Joplette')
('David', 'Pinker', '13', 'Jemima', 'Farrell')
('Douglas', 'Jones', '11', 'David', 'Jones')
('Erica', 'Crumpet', '2', 'Tracy', 'Smith')
('Florence', 'Bader', '9', 'Ponder', 'Stibbons')
('Gerald', 'Butters', '1', 'Darren', 'Smith')
('Henrietta', 'Rumney', '20', 'Matthew', 'Genting')
('Henry', 'Worthington-Smyth', '2', 'Tracy', 'Smith')
('Jack', 'Smith', '1', 'Darren', 'Smith')
('Janice', 'Joplette', '1', 'Darren', 'Smith')
('Joan', 'Coplin', '16', 'Timothy', 'Baker')
('John', 'Hunt', '30', 'Millicent', 'Purview')
('Matthew', 'Genting', '5', 'Gerald', 'Butters')
('Millicent', 'Purview', '2', 'Tracy', 'Smith')
('Nancy', 'Dare', '4', 'Janice', 'Joplette')
('Ponder', 'Stibbons', '6', 'Burton', 'Tracy')
('Ramnaresh', 'Sarwin', '15', 'Florence', 'Bader')
('Tim', 'Boothe', '3', 'Tim', 'Rownam')
('Timothy', 'Baker', '13', 'Jemima', 'Farrell')
​


SELECT m.firstname,
       m.surname, 
       m.recommendedby, 
       CONCAT_WS(' ',s.firstname, s.surname) recommenderName
FROM Members AS m
INNER JOIN (SELECT memid,firstname, surname
            FROM Members 
            WHERE firstname != 'GUEST') AS s
ON s.memid = m.recommendedby
WHERE m.firstname != 'GUEST'
ORDER BY recommenderName;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name,
       COUNT(b.facid) AS usaget,
       sum(b.slots) * 0.5 AS usage_in_hour
FROM Facilities AS f
INNER JOIN Bookings AS b
  USING(facid)
WHERE b.memid != 0
GROUP BY facid;

output:
('Tennis Court 1', 308, 478.5)
('Tennis Court 2', 276, 441.0)
('Badminton Court', 344, 543.0)
('Table Tennis', 385, 397.0)
('Massage Room 1', 421, 442.0)
('Massage Room 2', 27, 27.0)
('Squash Court', 195, 209.0)
('Snooker Table', 421, 430.0)
('Pool Table', 783, 428.0)


/* Q13: Find the facilities usage by month, but not guests */

/*  IN PHPMyAdmin: creating 6 new columns:
    s7.usage_in_JULY : times used in July
    s7.usage_in_hour_JULY : total hours the facility has been used in July
    s8.usage_in_AUG :  times the facility has been used in August
    s8.usage_in_hour_AUG: total hours the facility has been used in August
    s9.usage_in_SEP: times the facility has been used in Sep
    s9.usage_in_hour_SEP: total hours the facility has been used in Sep   */
   
SELECT f.name,
       s7.usage_in_JULY,
       s7.usage_in_hour_JULY,
       s8.usage_in_AUG,
       s8.usage_in_hour_AUG,
       s9.usage_in_SEP,
       s9.usage_in_hour_SEP
FROM Facilities AS f
INNER JOIN (SELECT f.name,
                   COUNT(b.facid) AS usage_in_JULY,
                   sum(b.slots) * 0.5 AS usage_in_hour_JULY
            FROM Facilities AS f
            INNER JOIN Bookings AS b
            USING(facid)
            WHERE b.memid != 0
               AND MONTH(b.starttime)='07'
            GROUP BY facid) as s7
 USING(name)
INNER JOIN (SELECT f.name,
                   COUNT(b.facid) AS usage_in_AUG,
                   sum(b.slots) * 0.5 AS usage_in_hour_AUG
            FROM Facilities AS f
            INNER JOIN Bookings AS b
            USING(facid)
            WHERE b.memid != 0
               AND MONTH(b.starttime)='08'
            GROUP BY facid) as s8
  USING(name)
INNER JOIN (SELECT f.name,
                   COUNT(b.facid) AS usage_in_SEP,
                   sum(b.slots) * 0.5 AS usage_in_hour_SEP
            FROM Facilities AS f
            INNER JOIN Bookings AS b
            USING(facid)
            WHERE b.memid != 0
               AND MONTH(b.starttime)='09'
            GROUP BY facid) as s9
  USING(name)
ORDER BY name;
  
/* in Jupyter Notebook, use strftime() function instead of MONTH()            
SELECT f.name,
              s7.usage_in_JULY,
              s7.usage_in_hour_JULY,
              s8.usage_in_AUG,
              s8.usage_in_hour_AUG,
              s9.usage_in_SEP,
              s9.usage_in_hour_SEP
      FROM Facilities AS f
      INNER JOIN (SELECT f.name,
                         COUNT(b.facid) AS usage_in_JULY,
                         sum(b.slots) * 0.5 AS usage_in_hour_JULY
                  FROM Facilities AS f
                  INNER JOIN Bookings AS b
                    USING(facid)
                  WHERE b.memid != 0
                    AND strftime('%m',b.starttime)='07'
                  GROUP BY facid) as s7
        USING(name)
      INNER JOIN (SELECT f.name,
                         COUNT(b.facid) AS usage_in_AUG,
                         sum(b.slots) * 0.5 AS usage_in_hour_AUG
                  FROM Facilities AS f
                  INNER JOIN Bookings AS b
                    USING(facid)
                  WHERE b.memid != 0
                     AND strftime('%m',b.starttime)='08'
                  GROUP BY facid) as s8
        USING(name)
      INNER JOIN (SELECT f.name,
                         COUNT(b.facid) AS usage_in_SEP,
                         sum(b.slots) * 0.5 AS usage_in_hour_SEP
                  FROM Facilities AS f
                  INNER JOIN Bookings AS b
                    USING(facid)
                  WHERE b.memid != 0
                    AND strftime('%m',b.starttime)='09'
                  GROUP BY facid) as s9
        USING(name)
      ORDER BY name;


OUTPUT:
('Badminton Court', 51, 82.5, 132, 207.0, 161, 253.5)
('Massage Room 1', 77, 83.0, 153, 158.0, 191, 201.0)
('Massage Room 2', 4, 4.0, 9, 9.0, 14, 14.0)
('Pool Table', 103, 55.0, 272, 151.5, 408, 221.5)
('Snooker Table', 68, 70.0, 154, 158.0, 199, 202.0)
('Squash Court', 23, 25.0, 85, 92.0, 87, 92.0)
('Table Tennis', 48, 49.0, 143, 148.0, 194, 200.0)
('Tennis Court 1', 65, 100.5, 111, 169.5, 132, 208.5)
('Tennis Court 2', 41, 61.5, 109, 172.5, 126, 207.0)
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            