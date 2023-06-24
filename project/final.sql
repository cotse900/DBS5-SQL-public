/*
DBS501
Chungon Tse
Final project
4 Dec 2022
*/

--1 preparation work

--select count(*) from employee;
--select count(*) from staff;


--2 staff_add

create or replace procedure staff_add
(
m_name staff.name%type,
m_job staff.job%type,
m_salary staff.salary%type,
m_comm staff.comm%type
)
as
    inv exception;
    begin
        insert into staff (id, name, dept, job, years, salary, comm)
        values ((select (max(id)+10) from staff), m_name, 90, m_job, 1, m_salary, m_comm);
        
        if m_job = 'Sales' or m_job = 'Clerk' or m_job = 'Mgr' then
            dbms_output.put_line('Row inserted.');
        else
            dbms_output.put_line('Invalid job name. Job name is only ''Sales'', ''Clerk'', or ''Mgr''.');
        end if;
        --set exceptions
        if m_salary < 0 and m_comm < 0 then
            raise inv;
        elsif m_salary < 0 then
            raise inv;
        elsif m_comm < 0 then
            raise inv;
        end if;
        exception
            when inv then
                dbms_output.put_line('Invalid value(s).');
        --this happens with for example input of more than 5 characters because the job column only allows 5 chars
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--test valid
declare
    i_name staff.name%type := 'Jon';
    i_job staff.job%type := 'Mgr';
    i_salary staff.salary%type := 10000;
    i_comm staff.comm%type := 100;
begin
    staff_add(i_name, i_job, i_salary, i_comm);
end;

--clean up
delete from staff where name = 'Jon';


--3 ins_job
--preparation
--drop table staffaudtbl;

Create table staffaudtbl(
    id smallint,
    incjob char(5)
);

create or replace trigger ins_job
    after
        insert on staff
    referencing new as new
    for each row
    when (new.job <> 'Sales' and new.job <> 'Clerk' and new.job <> 'Mgr')
    
    begin
        insert into staffaudtbl (id, incjob)
            values (:new.id, :new.job);
        exception
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--test
--valid
begin
    staff_add('Jon', 'Sales', 10000, 1000);
end;
--invalid and shows on staffaudtbl
begin
    staff_add('Jon', 'Sale', 10000, 1000);
end;

--clean up
delete from staff where name = 'Jon';
truncate table staffaudtbl;


--4 total_cmp

create or replace function total_cmp (idee in smallint)
return number is
    id_ smallint;
    salary_ staff.salary%type;
    comm_ staff.comm%type;
    inv exception;
    total decimal(7,2);
    
    begin
        select id, salary, comm, salary+comm into id_, salary_, comm_, total from staff where id = idee;
        total := salary_ + comm_;
        if sql%found then
            dbms_output.put_line('Total compensation: $' || total);
        else raise inv;
        end if;
        return total;
        
        --set exception
        exception
            when inv then
                dbms_output.put_line('The table is empty.');
            when others then
                dbms_output.put_line('Wrong ID/Invalid data.');
    end;
    
    declare
        idy smallint := 0;
    begin
        idy := total_cmp(20);
        --idy := total_cmp(21);
        --dbms_output.put_line(idy);
    end;


--5 set_comm

alter table staffaudtbl
add oldcomm decimal(9,2);
alter table staffaudtbl
add newcomm decimal(9,2);

--optional: correct null values of comm values (11 rows of Mgr)
update staff set comm = 0 where comm is null;


create or replace procedure set_comm is
    m_name staff.name%type;
    m_job staff.job%type;
    m_salary staff.salary%type;
    m_comm staff.comm%type;
    inv exception;
    cursor curs is
        select name, job, salary, comm from staff;
    begin
        dbms_output.put_line('Staff -- Job -- Salary -- New comm');
        update staff set comm = salary * 0.2 where job like initcap('Mgr%');
        update staff set comm = salary * 0.1 where job = 'Clerk';
        update staff set comm = salary * 0.3 where job = 'Sales';
        update staff set comm = salary * 0.5 where job = 'Prez';
            open curs;
                loop
                    fetch curs into m_name, m_job, m_salary, m_comm;
                    exit when curs%notfound;
                        dbms_output.put_line(m_name || ' -- ' || m_job || ' -- ' || m_salary || ' -- ' || m_comm);
                end loop;
            close curs;
        exception
            when inv then
                dbms_output.put_line('Invalid value(s).');
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--for reference: the above is the same as these:
Select name, salary, salary*0.2 from staff where job like 'Mgr%';
Select name, salary, salary*0.1 from staff where job = 'Clerk';
Select name, salary, salary*0.3 from staff where job = 'Sales';
Select name, salary, salary*0.5 from staff where job = 'Prez';


--clean up
--truncate table staffaudtbl;
--reset
--truncate table staff;


create or replace trigger upd_comm
    after
    update on staff
    referencing new as new old as old
    for each row
    
    begin
    
        insert into staffaudtbl (id, incjob, oldcomm, newcomm)
        values (:old.id, null, :old.comm, :new.comm);
        
        exception
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--execute to update comm
begin
  set_comm();
end;


--6
--combine triggers ins_job and upd_comm into staff_trig

--new staffaudtbl
drop table staffaudtbl;

Create table staffaudtbl(
    id smallint,
    action varchar2(10),
    incjob char(5),
    oldcomm decimal(9,2),
    newcomm decimal(9,2)
);

create or replace trigger staff_trig
    before
    insert or update or delete
        on staff
    referencing new as new old as old
    for each row
    declare
        action_code varchar2(10);
        m_incjob varchar2(10);
        m_id smallint;
    begin
        action_code := case
            when inserting then 'I'
            when updating then 'U'
            when deleting then 'D'
        end;
        --if job is invalid then it is entered into staffaudtbl
        --otherwise it is null
        --inserting assumes no old comm, and new comm should come up in staffaudtbl
        --new insertions with valid job write only ID, action, and new comm
        --new insertions with invalid job write ID, action, incjob, and new comm
        if inserting then
            --invalid job
            if (:new.job <> 'Sales' and :new.job <> 'Clerk' and :new.job <> 'Mgr') then
                m_incjob := :new.job;
                m_id := :new.id;
            --valid job
            else
                m_incjob := null;
                m_id := :new.id;
            end if;
            
            insert into staffaudtbl (id, action, incjob, oldcomm, newcomm)
            values (m_id, action_code, m_incjob, :old.comm, :new.comm);
        --like inserting
        elsif updating then
            if (:new.job <> 'Sales' and :new.job <> 'Clerk' and :new.job <> 'Mgr') then
                m_incjob := :new.job;
                m_id := :new.id;
            else
                m_incjob := null;
                m_id := :new.id;
            end if;
            if (:old.comm = :new.comm) then
                insert into staffaudtbl (id, action, incjob, oldcomm, newcomm)
                values (m_id, action_code, m_incjob, null, null);
            else
                insert into staffaudtbl (id, action, incjob, oldcomm, newcomm)
                values (m_id, action_code, m_incjob, :old.comm, :new.comm);
            end if;
        elsif deleting then
            m_id := :old.id;
            
            insert into staffaudtbl (id, action, incjob, oldcomm, newcomm)
            values (m_id, action_code, m_incjob, :old.comm, :new.comm);            
        end if;

        exception
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--testing 1
--Use set_comm for the original staff table

--testing 2

begin
    staff_add('Jon', 'Sales', 10000, 1000);
end;
begin
    staff_add('Jon', 'Sale', 10000, 1000);
end;
update staff set job = 'Mgr' where id = '360';
update staff set comm = 1100 where name = 'Jon';
delete from staff where name = 'Jon';

--clean up
--truncate table staffaudtbl;
--truncate table staff;


--7 fun_name
--should use select here
create or replace function fun_name (nem in varchar2)
return varchar2 is
    retstr varchar2(100);
    m_name staff.name%type;
    letter varchar2(1);
    output varchar(9);--same as staff.name
    begin
        select name into m_name from staff where name = nem;
        for i in 1..length(nem) loop
            letter := substr(nem, i, 1);
            output := output ||
                case mod(i,2)
                    when 0 then lower(letter)
                    else upper(letter)
                end;
        end loop;
            dbms_output.put_line(output);
        return retstr;
        --set exception
        exception
            when others then
                DBMS_OUTPUT.PUT_LINE('The entered name is not found in the staff table.');
    end;


--8 vowel_cnt
create or replace function vowel_cnt (nem in varchar2)
return varchar2 is
    retstr varchar2(100);
    m_name staff.name%type;
    m_job staff.job%type;
    reg number;
    cursor countname is
        --select name from staff;
        select name, regexp_count(name, '[aeiouAEIOU]', 1, 'i') as vowels from staff;
    cursor countjob is
        select name, job, regexp_count(job, '[aeiouAEIOU]', 1, 'i') as vowels2 from staff;
    begin
        dbms_output.put_line('Staff name --- Number of vowels');
        open countname;
            loop
                fetch countname into m_name, reg;
                exit when countname%notfound;
                dbms_output.put_line(m_name || ' --- ' || reg);
            end loop;
        close countname;
        dbms_output.put_line('Staff job --- Number of vowels');
        open countjob;
            loop
                fetch countjob into m_name, m_job, reg;
                exit when countjob%notfound;
                dbms_output.put_line(m_name || ' --- ' || m_job || ' --- ' || reg);
            end loop;
        close countjob;        
        
        return retstr;
        --set exception
        exception
            when others then
                DBMS_OUTPUT.PUT_LINE('An error with names.');
    end;


--9
--package
Create or replace package staff_pck is
    --2
    procedure staff_add
        (
        m_name staff.name%type,
        m_job staff.job%type,
        m_salary staff.salary%type,
        m_comm staff.comm%type
        );
    --4
    function total_cmp (idee in smallint)
        return number;
    --5
    procedure set_comm;
    --7
    function fun_name (nem in varchar2)
        return varchar2;
    --8
    function vowel_cnt (nem in varchar2)
        return varchar2;
end;

    --merge 3, 5, 6
    --trigger staff_trig;

--package body
Create or replace package body staff_pck as
    --2
    procedure staff_add
        (
        m_name staff.name%type,
        m_job staff.job%type,
        m_salary staff.salary%type,
        m_comm staff.comm%type
        )
    as
        inv exception;
        begin
            insert into staff (id, name, dept, job, years, salary, comm)
            values ((select (max(id)+10) from staff), m_name, 90, m_job, 1, m_salary, m_comm);
            
            if m_job = 'Sales' or m_job = 'Clerk' or m_job = 'Mgr' then
                dbms_output.put_line('Row inserted.');
            else
                dbms_output.put_line('Invalid job name. Job name is only ''Sales'', ''Clerk'', or ''Mgr''.');
            end if;
            --set exceptions
            if m_salary < 0 and m_comm < 0 then
                raise inv;
            elsif m_salary < 0 then
                raise inv;
            elsif m_comm < 0 then
                raise inv;
            end if;
            exception
                when inv then
                    dbms_output.put_line('Invalid value(s).');
            --this happens with for example input of more than 5 characters because the job column only allows 5 chars
                when others then
                    dbms_output.put_line('Invalid data.');
        end;
    --4
    function total_cmp (idee in smallint)
        return number is
            id_ smallint;
            salary_ staff.salary%type;
            comm_ staff.comm%type;
            inv exception;
            total decimal(7,2);
            
            begin
                select id, salary, comm, salary+comm into id_, salary_, comm_, total from staff where id = idee;
                total := salary_ + comm_;
                if sql%found then
                    dbms_output.put_line('Total compensation: $' || total);
                else raise inv;
                end if;
                return total;
                
                --set exception
                exception
                    when inv then
                        dbms_output.put_line('The table is empty.');
                    when others then
                        dbms_output.put_line('Wrong ID/Invalid data.');
            end;
    --5
    procedure set_comm is
        m_name staff.name%type;
        m_job staff.job%type;
        m_salary staff.salary%type;
        m_comm staff.comm%type;
        inv exception;
        cursor curs is
            select name, job, salary, comm from staff;
        begin
            dbms_output.put_line('Staff -- Job -- Salary -- New comm');
            update staff set comm = salary * 0.2 where job like initcap('Mgr%');
            update staff set comm = salary * 0.1 where job = 'Clerk';
            update staff set comm = salary * 0.3 where job = 'Sales';
            update staff set comm = salary * 0.5 where job = 'Prez';
                open curs;
                    loop
                        fetch curs into m_name, m_job, m_salary, m_comm;
                        exit when curs%notfound;
                            dbms_output.put_line(m_name || ' -- ' || m_job || ' -- ' || m_salary || ' -- ' || m_comm);
                    end loop;
                close curs;
            exception
                when inv then
                    dbms_output.put_line('Invalid value(s).');
                when others then
                    dbms_output.put_line('Invalid data.');
        end;
    --7
    function fun_name (nem in varchar2)
    return varchar2 is
        retstr varchar2(100);
        m_name staff.name%type;
        letter varchar2(1);
        output varchar(9);--same as staff.name
        begin
            select name into m_name from staff where name = nem;
            for i in 1..length(nem) loop
                letter := substr(nem, i, 1);
                output := output ||
                    case mod(i,2)
                        when 0 then lower(letter)
                        else upper(letter)
                    end;
            end loop;
                dbms_output.put_line(output);
            return retstr;
            --set exception
            exception
                when others then
                    DBMS_OUTPUT.PUT_LINE('The entered name is not found in the staff table.');
        end;
    --8
    function vowel_cnt (nem in varchar2)
    return varchar2 is
        retstr varchar2(100);
        m_name staff.name%type;
        m_job staff.job%type;
        reg number;
        cursor countname is
            --select name from staff;
            select name, regexp_count(name, '[aeiouAEIOU]', 1, 'i') as vowels from staff;
        cursor countjob is
            select name, job, regexp_count(job, '[aeiouAEIOU]', 1, 'i') as vowels2 from staff;
        begin
            dbms_output.put_line('Staff name --- Number of vowels');
            open countname;
                loop
                    fetch countname into m_name, reg;
                    exit when countname%notfound;
                    dbms_output.put_line(m_name || ' --- ' || reg);
                end loop;
            close countname;
            dbms_output.put_line('Staff job --- Number of vowels');
            open countjob;
                loop
                    fetch countjob into m_name, m_job, reg;
                    exit when countjob%notfound;
                    dbms_output.put_line(m_name || ' --- ' || m_job || ' --- ' || reg);
                end loop;
            close countjob;        
            
            return retstr;
            --set exception
            exception
                when others then
                    DBMS_OUTPUT.PUT_LINE('An error with names.');
        end;
end;

--calling through staff_pck
--declare all required types already defined in their respective procedure/function
declare
    m_name staff.name%type;
    m_job staff.job%type;
    m_salary staff.salary%type;
    m_comm staff.comm%type;
    idee smallint;
    nem varchar2(100);
begin
    staff_pck.staff_add('Jon', 'Sales', 10000, 1000);
    staff_pck.staff_add('Jon', 'Sale', 10000, 1000);
    idee := staff_pck.total_cmp(20);
    staff_pck.set_comm();
    nem := staff_pck.fun_name('Sneider');
    --vowel_cnt can take any characters including null
    nem := staff_pck.vowel_cnt('');
end;
