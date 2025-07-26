-- Insert Operation
insert into buildingInfo
values(1, 'Executive Office', 25);

-- Delete Operation
delete from employeeInfo
where employeeId = 10;

-- Update Operation
update employeeInfo
set employeeStatus = 'PT'
where employeeId = 8;

-- Selection Operation
select count (employeeid)
from employeeInfo
where employeeStatus = 'FT';

-- Projection Operation
select employeeId, firstName, lastName
from employeeInfo;

-- Join Operation
select e.employeeid, firstName, lastName, waitListId, waitFrom
from employeeInfo e, parkingWaitList p
where e.employeeId = p.employeeId;

-- Aggregation Operation
select count(employeeId)
from employeeInfo
where employeeStatus = 'PT';

-- Nested Aggregation with Group By
select employeeId, avg (e.age)
from employeeInfo e
group by employeeId
having avg(e.age) <= all (select avg(age)
                                from employeeInfo
                                group by employeeId);

-- Division
select employeeId, lastName, firstName
from employeeInfo e 
where not exists 
(select p.parkingNum 
from parkingInfo p 
Where p.employeeId = e.employeeId)
order by employeeId;
