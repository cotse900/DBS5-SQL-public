--2
--my_median
create or replace function my_median (med in out integer)
--this function returns the name and years columns from the Staff table
return string is 
    retstr string(15);
    targetmedian number;
    salary staff.salary%type;
    sal staff.salary%type;
    inv exception;
    count_ number;
    --set cursor of salary column in the staff table
    cursor salarylist is
        select  salary into sal from staff order by 1;

    begin
        select count(*) into count_ from staff;
        select median(salary) into targetmedian from staff;
        open salarylist;
                fetch salarylist into sal;
                    --if empty list
                    if count_ = 0 then
                        raise inv;
                    else
                        dbms_output.put_line('With ' || count_ || ' rows in this table, the median is ' || targetmedian || '.');
                    end if;
        close salarylist;
            return med;
        --set exception
        exception
            when inv then
                dbms_output.put_line('The table is empty.');
            when others then
                dbms_output.put_line('Invalid data.');
    end;



--for use in #2
--for an odd number of elements, use the original staff table
--with 35 entries (odd number), the median is 76858.2 (18th highest)

--for an even number of elements, for instance, add this entry to staff table:
--Insert into staff (id, name, dept, job, years, salary, comm) values (360, 'Tse', 38, 'Sales', 1, 77000.00, 852.00);
--with 35+1 entries (even number), the median is the average of 18th and 19th highest salary
--i.e. 77000.0 and 76858.2
--With different data, recompile the above function before running for a different result of median



--an empty list can be done by
--Truncate table staff;



--3
--my_mode
create or replace function my_mode (mo_de in out integer)
--this function returns the mode from the Staff table
return string is 
    ret number;
    dept staff.dept%type;
    dept_ staff.dept%type;
    count1 staff.dept%type;
    count3 staff.dept%type;
    inv exception;
    count_ number;
    --set cursor of salary column in the staff table
    cursor modelist is
        --count(dept) or count(*) would return staff table group by dept
        --8 depts with 4 or 5 employees
        --count1 and count2 are the same
        --add the max statement to get all 3 modes in staff table
        Select dept, count1
            from (select dept, count(dept) as count1 from staff group by dept)
                where count1 = (select max(count2)
                    from (select count(dept) as count2 from staff group by dept));
    begin
        --count rows
        select count(*) into count_ from staff;
        --count number of distinct rows from count1 as count3
        Select count(distinct count1) into count3
        from (select dept, count(dept) as count1 from staff group by dept);
        --if empty list
        if count_ = 0 then
            raise inv;
        end if;
        open modelist;
            --count3 = 1 means all depts have the same number of staff aka no mode at all
            if count3 = 1 then
                dbms_output.put_line('There is no mode.');
            else
                dbms_output.put_line('The mode(s) are:');
                loop
                    fetch modelist into dept_, count1;
                    exit when modelist%notfound;
                        dbms_output.put_line(dept_);
                end loop;
            end if;
        close modelist;
            return ret;
        --set exception
        exception
            when inv then
                dbms_output.put_line('The table is empty.');
            when others then
                dbms_output.put_line('Invalid data.');
    end;



--for use in #3
--1 mode
--dept 38, 51, 66 are the modes in the original table with 5 staffers
--With different data, recompile the above function before running for a different result of mode
--Insert into staff (id, name, dept, job, years, salary, comm) values (360, 'Tse', 38, 'Sales', 1, 77000.00, 852.00);
--adding this 1 entry means only 38 is the mode (6 staffers)

--2 modes
--Insert into staff (id, name, dept, job, years, salary, comm) values (360, 'Tse', 38, 'Sales', 1, 77000.00, 852.00);
--Insert into staff (id, name, dept, job, years, salary, comm) values (370, 'Ta', 51, 'Sales', 1, 77000.00, 852.00);
--adding these 2 entries will make 38 and 51 the modes (6 staffers in both)

--0 mode
--to eliminate modes, delete 1 entry each from dept 51, 66, 38 (all depts have 4 staffers, so there is no mode)
--delete from staff where id = 30; --dept 38
--delete from staff where id = 140; --dept 51
--delete from staff where id = 270; --dept 66

--an empty list can be done by
--Truncate table staff;



Create or replace function my_math_all (val in out integer)
return integer is
    --median, mode and mean all use number as an out param type
    ret number;
    salary staff.salary%type;
    avgsal staff.salary%type;
    count_ number;
    inv exception;
    --set cursor for avg in the staff table, say, salary column
    cursor salarylist is
        select avg(salary) into avgsal from staff;
    begin
        --set count of rows
        select count(*) into count_ from staff;
        --if empty list
        if count_ = 0 then
            raise inv;
        end if;
        open salarylist;
            fetch salarylist into avgsal;
            dbms_output.put_line('The mean of salary in the staff table: ' || avgsal);
            dbms_output.put_line(my_median(ret));
            dbms_output.put_line(my_mode(ret));
        close salarylist;
            return ret;
        --set exception
        exception
            when inv then
                dbms_output.put_line('The table is empty.');
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--To call the functions separately, these lines can help:
declare
    num number;
begin
    dbms_output.put_line(my_median(num)); 
end;

declare
    num number;
begin
    dbms_output.put_line(my_mode(num)); 
end;

declare
    num number;
begin
    dbms_output.put_line(my_math_all(num)); 
end;
