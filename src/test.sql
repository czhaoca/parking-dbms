-- Division
SELECT employeeId
from employeeInfo e
where not exists
        ((select p.parkingNum
            from parkingInfo p
            where p.parkingNum <= 12)
            where not exists
            (select distinct ev.parkingNum
            from evBook ev
            where e.employeeId = ev.employeeId
            and p.employeeId - ev.employeeId));


update logininfo set password = 'abc' where username = 'sharon' and password = 'asdf2q13';

select * from logininfo where username = 'sharon';