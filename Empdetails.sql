select *from employeedetail;
select * from employee;

-- Q1(a): Find the list of employees whose salary ranges between 2L to 3L.
select EmpName, salary from employee
where salary between 200000 and 300000;

-- Q1(b): Write a query to retrieve the list of employees from the same city.
select t1.* from employee t1, employee t2
where t1.city=t2.city and t1.EmpID!=t2.EmpID;

-- Q1(c): Query to find the null values in empid in the Employee table.
select EmpID from employee
where EmpID is NULL;

-- Q2(a): Query to find the cummulative sum of employee’s salary.
select EmpName, Salary, sum(Salary) over(order by Empid) from employee;


-- Q2(b): What’s the male and female employees ratio.
SELECT 
    (SELECT COUNT(*) FROM Employee WHERE Gender = 'M') AS MaleCount,
    (SELECT COUNT(*) FROM Employee WHERE Gender = 'F') AS FemaleCount,
    (SELECT COUNT(*) FROM Employee WHERE Gender = 'M') / 
    (SELECT COUNT(*) FROM Employee WHERE Gender = 'F') AS MaleFemaleRatio
FROM Employee
LIMIT 1;

-- Q2(c): Write a query to fetch 50% records from the Employee table.
select * from employee
where empid<=(select count(empid)/2 from employee);

-- Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’
-- i.e 12345 will be 123XX
select EmpName,concat(left(Salary,length(salary)-2),'XX') from employee;

-- Q4: Write a query to fetch even and odd rows from Employee table.

select * from (select row_number() over(order by empid) rowno from employee) emp
where emp.rowno % 2 = 0;
select * from (select row_number() over(order by empid) rowno from employee) emp
where emp.rowno % 2 <> 0;

-- select row_number() over(order by empid) rowno, empid from employee;


WITH NumberedRows AS (
    SELECT
        EmpID,
        ROW_NUMBER() OVER (ORDER BY EmpID) AS RowNumber
    FROM
        employee
)
SELECT
    CASE WHEN RowNumber % 2 = 0 THEN 
    EmpID 
    END AS EvenRow,
    CASE WHEN RowNumber % 2 <> 0 THEN 
    EmpID END AS OddRow
FROM
    NumberedRows;
    
-- Q5(a): Write a query to find all the Employee names whose name:
-- • Begin with ‘A’
-- • Contains ‘A’ alphabet at second place
-- • Contains ‘Y’ alphabet at second last place
-- • Ends with ‘L’ and contains 4 alphabets
-- • Begins with ‘V’ and ends with ‘A’

select EmpName from employee
where EmpName like 'a%' or EmpName like '_a%' or EmpName like '%y_' or (EmpName like '%l' and char_length(empname)=4) or EmpName like 'v%a';

-- Q5(b): Write a query to find the list of Employee names which is:
-- • starting with vowels (a, e, i, o, or u), without duplicates
select distinct EmpName from employee
where EmpName like 'a%' or EmpName like 'e%' or EmpName like 'i%' or EmpName like 'o%' or EmpName like 'u%';

-- • ending with vowels (a, e, i, o, or u), without duplicates
select distinct EmpName from employee
where EmpName like '%a' or EmpName like '%e' or EmpName like '%i' or EmpName like '%o' or EmpName like '%u';

-- • starting & ending with vowels (a, e, i, o, or u), without duplicates
select distinct EmpName from employee
where 	(EmpName like 'a%' or EmpName like 'e%' or EmpName like 'i%' or EmpName like 'o%' or EmpName like 'u%')
	and
		(EmpName like '%a' or EmpName like '%e' or EmpName like '%i' or EmpName like '%o' or EmpName like '%u');
   
-- in pgAdmin
SELECT DISTINCT EmpName
FROM Employee
WHERE LOWER(EmpName) SIMILAR TO '[aeiou]%';
SELECT DISTINCT EmpName
FROM Employee
WHERE LOWER(EmpName) SIMILAR TO '%[aeiou]';
SELECT DISTINCT EmpName
FROM Employee
WHERE LOWER(EmpName) SIMILAR TO '[aeiou]%[aeiou]';

-- Q6: Find Nth highest salary from employee table without using the TOP/LIMIT keywords.
SELECT e1.salary from employee e1
where 0 = (select count(distinct e2.salary) from employee e2 -- here n-1=0 ie.1-1 for the first highest salary
				where e2.salary > e1.salary);

-- or --
select e.salary from employee e
where 1 = (select count(distinct ee.salary) from employee ee
			where ee.salary>=e.salary);
            
-- Q7(a): Write a query to find and remove duplicate records from a table.
-- to find
select EmpID,EmpName,Salary,city, count(*) as dubb from employee 
group by EmpID,EmpName,Salary,city
having count(*)>1;
-- to delete
delete from employee
where EmpID in 
(select EmpID from employee
group by empid
having count(empid)>1);

-- Q7(b): Query to retrieve the list of employees working in same project.
select * from employeedetail;
with temp as(
select e1.*,e2.Project from employee e1
join employeedetail e2 on e2.EmpID=e1.EmpID)
select t2.empname, t1.empname, t2.project from temp t1, temp t2
where t1.project=t2.project and t1.empid!=t2.empid and t1.empid>t2.empid;

-- Q8: Show the employee with the highest salary for each project
select e.empname,ed.project,e.salary	from employee e
join employeedetail ed on ed.EmpID=e.EmpID
where (ed.Project, e.salary)
	in (select ed.project,max(e.salary) from employee e
		join employeedetail ed on ed.empid=e.empid
        group by ed.project)
order by e.salary desc;

-- using cte
with cte as(
select e1.empname,ed.project,e1.salary,
row_number() over(partition by ed.project order by e1.salary desc) r from employee e1
join employeedetail ed on ed.empid=e1.empid)
select t.empname,t.project,t.salary from cte t
where  r=1
order by t.salary desc;

-- Q9: Query to find the total count of employees joined each year
select extract(year from ed.DOJ) as yearjoin, count(e.empid) as empno from employeedetail ed
join employee e on e.empid=ed.empid
group by yearjoin
order by yearjoin;

-- Q10: Create 3 groups based on salary col, salary less than 1L is low, between 1 -
-- 2L is medium and above 2L is High
select salary, 
case 
	when salary<100000 then 'Low Salary'
    when salary between 100000 and 200000 then 'medium salary'
    else 'High salary'
end as salary_group 
from employee
order by salary desc;

-- Q. Query to pivot the data in the Employee table and retrieve the total salary for each city.
-- The result should display the EmpID, EmpName, and separate columns for each city (Mathura, Pune, Delhi), containing the corresponding total salary.
select EmpID,EmpName,
sum(case when city='Mathura' then Salary end) as Mathura,
sum(case when city='Pune' then Salary end) as Pune,
sum(case when city='Delhi' then salary end) as Delhi
from employee
group by empid, EmpName;