--Learn sql questions level - medium
-- website : https://www.sql-practice.com/

--Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade.
--Sort the list starting from the earliest birth_date.

select first_name,last_name, birth_date
from patients
where year(birth_date) >=1970 and year(birth_date) <=1979
order by birth_date asc

--Que: We want to display each patient's full name in a single column.
--Their last_name in all upper letters must appear first, then first_name in all lower case letters.
--Separate the last_name and first_name with a comma. Order the list by the first_name in decending order
--EX: SMITH,jane

select concat(upper(last_name),',',lower (first_name))
from patients
order by first_name desc

--Que: Show the province_id(s), sum of height;
--where the total sum of its patient's height is greater than or equal to 7,000.

select province_id,sum(height)
from patients
group by province_id
having sum(height) >= 7000

--Que: Show the difference between the largest weight and smallest weight
--for patients with the last name 'Maroni'

select max(weight)- min(weight) -- '-' sql allows using max, min functions with maths operators
from patients
where last_name = 'Maroni'

--Show all of the days of the month (1-31) and
--how many admission_dates occurred on that day.
--Sort by the day with most admissions to least admissions.

select day(admission_date) as day_number , count(patient_id)
from admissions
group by day(admission_date) --  aggregate "admission" done on admission_Date of day of any month
order by count(patient_id) desc

--Show all columns for patient_id 542's most recent admission_date.

select *
from admissions
where patient_id='542'
order by admission_date   -- list all admissions with 542 id and find top desc(latest) date,
desc limit 1