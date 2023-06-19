--1 preparation work

--select count(*) from employee;
--select count(*) from staff;

--2+3 tables

Create table empaudit(
    EMPID smallint,
    ERRORCODE varchar(255),
    OPERATION varchar(255),
    WORKDEPT varchar(255),
    SALARY decimal(7,2),
    COMM decimal(7,2),
    BONUS decimal(7,2)
);

--4 preparation work
Create table vacation(
    EMPID smallint,
    HIREDATE date,
    VACATIONDAYS smallint
);

--2
--varpaychk
create or replace trigger varpaychk
    after
    insert or update 
        on employee
    referencing new as new
    for each row
    --set conditions for the trigger
    --invalid values go first
    --business rules (larger values) go later
        when (new.salary < 0 or new.comm < 0 or new.bonus < 0 or
        new.bonus >= new.salary * 0.20 or new.comm >= new.salary * 0.25 or new.bonus + new.comm >= new.salary * 0.40)
declare
    operation_code varchar2(50);
    error_code varchar2(50);
begin
    --indicates insert or update
    --this displays in empaudit
    operation_code := case
        when inserting then 'I'
        when updating then 'U'
    end;
    --rules are simplified as error codes with conditions below
    --because this is a simple case (for if-else below)
    --invalid values precede violations of rules for this logic to work properly
    --and longer statements with 'AND' go first followed by shorter ones
    error_code := case
        when :new.salary < 0 then 'negsal'
        when :new.comm < 0 then 'negcomm'
        when :new.bonus < 0 then 'negbonus'
        when :new.bonus >= :new.salary * 0.20 then 'B'
        when :new.comm >= :new.salary * 0.25 then 'C'
        when :new.bonus + :new.comm >= :new.salary * 0.40 then 'S'
    end;
    
    --shows which rule is broken
    --follow the above order of logics to allow longer logics to work
    if error_code = 'negsal' then
        --dbms_output.put_line('Salary is invalid.');
        raise_application_error(-20001,'Salary is invalid.');
    elsif error_code = 'negcomm' then
        --dbms_output.put_line('Comm is invalid.');
        raise_application_error(-20002,'Comm is invalid.');
    elsif error_code = 'negbonus' then
        --dbms_output.put_line('Bonus is invalid.');
        raise_application_error(-20003,'Bonus is invalid.');
    elsif error_code = 'B' then
        dbms_output.put_line('See Empaudit for the error code.');
        dbms_output.put_line('Bonus rule broken');
    elsif error_code = 'C' then
        dbms_output.put_line('See Empaudit for the error code.');
        dbms_output.put_line('Commission rule broken');
    elsif error_code = 'S' then
        dbms_output.put_line('See Empaudit for the error code.');
        dbms_output.put_line('Sum rule broken');
    end if;
    --insert into empaudit; works for both insert and update
    --empaudit rows are only about broken rules, not complying values, nor invalid values
    insert into empaudit (empid, errorcode, operation, workdept, salary, comm, bonus)
    values (:new.empno, error_code, operation_code, :new.workdept, :new.salary, :new.comm, :new.bonus);
    
end;

--for testing purposes
--Note: empno in employee is a string
--insert: invalid salary or invalid bonus or invalid comm
--The raise application error here activates for any single negative value

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), -40000, 7000, 8000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, -7000, 8000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 7000, -8000);

--insert: compliant
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 7000, 5000);
--insert: bonus rule broken
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 9000, 5000);
--insert: commission rule broken
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 5000, 11000);
--insert: sum rule broken
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('18-01-01','YY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 7999, 8001);

--update: compliant
update employee set salary = 40000, bonus = 7000, comm = 5000 where empno = '222222';
--update: bonus rule broken
update employee set salary = 40000, bonus = 9000, comm = 5000 where empno = '222222';
--update: commission rule broken
update employee set salary = 40000, bonus = 5000, comm = 11000 where empno = '222222';
--update: sum rule broken
update employee set salary = 40000, bonus = 7999, comm = 8001 where empno = '222222';

--clean up
--truncate table empaudit;




--3
--preparation work
--Default HR manager
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('999999', 'Default HR', ' ', 'Manager', '000', 0000, to_date('18-01-01','YY-MM-DD'), 'MANAGER', 1, 'n', to_date('18-01-01','YY-MM-DD'), 10000, 0, 0);

create or replace trigger nomgr
    before
    insert or update or delete
        on employee
    referencing new as new old as old
    for each row
    --when (new.workdept <> '000' or new.job <> upper('Manager'))
declare
    operation_code varchar2(50);
    error_code varchar2(50);
    m_empno employee.empno%type;
    m_workdept employee.workdept%type;
    m_salary employee.salary%type;
    m_comm employee.comm%type;
    m_bonus employee.bonus%type;
    m_job employee.job%type;
    cursor curs is
        select empno, workdept, salary, comm, bonus, job from employee where job = upper('manager');
begin
    --indicates insert or update
    operation_code := case
        when inserting then 'I'
        when updating then 'U'
        when deleting then 'D'
    end;
    error_code := case
    --BCS go first
        when :new.bonus >= :new.salary * 0.20 then 'B'
        when :new.comm >= :new.salary * 0.25 then 'C'
        when :new.bonus + :new.comm >= :new.salary * 0.40 then 'S'
        when (:new.job <> 'Manager') then 'M'
        else 'nil'
    end;
    if error_code = 'B' or error_code = 'C' or error_code = 'S' then
        :new.workdept := 'N/A';
    end if;
    if inserting then
        dbms_output.put_line('There is an insertion.');
        update employee set workdept = '000' where empno = :new.empno;
            insert into empaudit (empid, errorcode, operation, workdept, salary, comm, bonus)
            values (:new.empno, error_code, operation_code, :new.workdept, :new.salary, :new.comm, :new.bonus);
    elsif updating then
        dbms_output.put_line('There is an update.');
            insert into empaudit (empid, errorcode, operation, workdept, salary, comm, bonus)
            values (:new.empno, error_code, operation_code, :new.workdept, :new.salary, :new.comm, :new.bonus);
    end if;
    if deleting then
        dbms_output.put_line('There is a delete.');
        --delete from empaudit where empid = :new.empno;
        --if :old.job = 'MANAGER' then
            --update employee set workdept = '000';
        --end if;
            insert into empaudit (empid, errorcode, operation, workdept, salary, comm, bonus)
            values (:old.empno, error_code, operation_code, :old.workdept, :old.salary, :old.comm, :old.bonus);
    end if;
    exception
        when others then
            dbms_output.put_line('Invalid data.');
end;

--insert new entries of a new workdept
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333333', 'Fai', ' ', 'Tse', 'G01', 3333, to_date('18-01-01','YY-MM-DD'), 'operator', 18, 'M', to_date('58-01-01','YY-MM-DD'), 30000, 5000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333444', 'Calvin', ' ', 'Tse', 'G01', 3334, to_date('18-01-01','YY-MM-DD'), 'analyst', 18, 'M', to_date('94-01-01','YY-MM-DD'), 30000, 5000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333555', 'Peter', ' ', 'Tse', 'G01', 3335, to_date('18-01-01','YY-MM-DD'), 'MANAGER', 18, 'M', to_date('54-01-01','YY-MM-DD'), 30000, 5000, 5000);

--update
update employee set salary = 30001, bonus = 5000, comm = 5000 where empno = '333333';
update employee set salary = 30001, bonus = 5000, comm = 5000 where empno = '333444';
update employee set salary = 30001, bonus = 5000, comm = 5000 where empno = '333555';

--delete
delete from employee where empno = '333333' or empno = '333444' or empno = '333555';


--rollback;
--insert for B/C/S violations
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333333', 'Fai', ' ', 'Tse', 'G01', 3333, to_date('18-01-01','YY-MM-DD'), 'operator', 18, 'M', to_date('58-01-01','YY-MM-DD'), 30000, 5000, 15000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333444', 'Calvin', ' ', 'Tse', 'G01', 3334, to_date('18-01-01','YY-MM-DD'), 'analyst', 18, 'M', to_date('94-01-01','YY-MM-DD'), 30000, 15000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm) 
values ('333555', 'Peter', ' ', 'Tse', 'G01', 3335, to_date('18-01-01','YY-MM-DD'), 'MANAGER', 18, 'M', to_date('54-01-01','YY-MM-DD'), 30000, 5000, 7001);

--update for B/C/S violations
update employee set salary = 30000, bonus = 15000, comm = 5000 where empno = '333333';
update employee set salary = 30000, bonus = 5000, comm = 7001 where empno = '333444';
update employee set salary = 30000, bonus = 5000, comm = 15000 where empno = '333555';

--clean up
--truncate table empaudit;

--4
--empvac
create or replace trigger empvac
    after
    insert or update or delete
        on employee
    referencing new as new old as old
    for each row
declare
    --yyyy is the number of years of employment
    yyyy number;
    birthyear number;
    --exception is about employee.hiredate
    --specifically, hiredate cannot be later on sysdate
    inv exception;
begin
    --Calculate difference between today's date and hiredate as months
    --then divided 12 with trunc to get number of years as a whole number e.g. 4.1 years -> 4 years
    yyyy := trunc(months_between(sysdate, :new.hiredate)/12);
    birthyear := trunc(months_between(:new.hiredate, :new.birthdate)/12);
    if yyyy < 0 or birthyear < 0 then
        raise inv;
    end if;
    if inserting then
        dbms_output.put_line('There is an insert in vacation.');
        case
            when yyyy < 10 then
                insert into vacation values (:new.empno, :new.hiredate, 15);
                dbms_output.put_line('Staffer ' || :new.empno || ' is entitled to 15 days of vacation.');
            when yyyy >= 10 and yyyy <= 19 then
                insert into vacation values (:new.empno, :new.hiredate, 20);
                dbms_output.put_line('Staffer ' || :new.empno || ' is entitled to 20 days of vacation.');
            when yyyy >= 20 and yyyy <= 29 then
                insert into vacation values (:new.empno, :new.hiredate, 25);
                dbms_output.put_line('Staffer ' || :new.empno || ' is entitled to 25 days of vacation.');
            when yyyy >= 30 then
                insert into vacation values (:new.empno, :new.hiredate, 30);
                dbms_output.put_line('Staffer ' || :new.empno || ' is entitled to 30 days of vacation.');
        end case;
        
    elsif updating then
        dbms_output.put_line('There is an update in vacation.');
        case
            when yyyy < 10 then
                update vacation set vacationdays = 15 where empid = :old.empno;
                dbms_output.put_line('Staffer ' || :old.empno || ' is entitled to 15 days of vacation.');
            when yyyy >= 10 and yyyy <= 19 then
                update vacation set vacationdays = 20 where empid = :old.empno;
                dbms_output.put_line('Staffer ' || :old.empno || ' is entitled to 20 days of vacation.');
            when yyyy >= 20 and yyyy <= 29 then
                update vacation set vacationdays = 25 where empid = :old.empno;
                dbms_output.put_line('Staffer ' || :old.empno || ' is entitled to 25 days of vacation.');
            when yyyy >= 30 then
                update vacation set vacationdays = 30 where empid = :old.empno;
                dbms_output.put_line('Staffer ' || :old.empno || ' is entitled to 30 days of vacation.');
        end case;
    end if;
    if deleting then
        delete from vacation where empid = :old.empno;
    end if;
    
    exception
        when inv then
            dbms_output.put_line('Invalid hire date or birth date in Employee.');
        when others then
            dbms_output.put_line('Invalid data.');
end;

--insert: compliant (for clarity, I use YYYY instead of YY)
insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('222222', 'Jon', 'A', 'Tse', 'D11', 1111, to_date('2018-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('88-01-01','YY-MM-DD'), 40000, 7000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('333333', 'Jon', 'B', 'Tse', 'D11', 1111, to_date('2007-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('1968-01-01','YYYY-MM-DD'), 40000, 7000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('444444', 'Jon', 'C', 'Tse', 'D11', 1111, to_date('1995-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('1968-01-01','YYYY-MM-DD'), 40000, 7000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('555555', 'Jon', 'D', 'Tse', 'D11', 1111, to_date('1982-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('1958-01-01','YYYY-MM-DD'), 40000, 7000, 5000);

--update: compliant
update employee set salary = 40001, bonus = 7000, comm = 5000 where empno = '222222';
update employee set salary = 40002, bonus = 7000, comm = 5000 where empno = '333333';
update employee set salary = 40003, bonus = 7000, comm = 5000 where empno = '444444';
update employee set salary = 40004, bonus = 7000, comm = 5000 where empno = '555555';

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('666666', 'Jon', 'E', 'Tse', 'D11', 1111, to_date('1982-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('1983-01-01','YYYY-MM-DD'), 40000, 7000, 5000);

insert into employee (empno, firstname, midinit, lastname, workdept, phoneno, hiredate, job, edlevel, sex, birthdate, salary, bonus, comm)
values ('777777', 'Jon', 'F', 'Tse', 'D11', 1111, to_date('2025-01-01','YYYY-MM-DD'), 'designer', 18, 'M', to_date('1983-01-01','YYYY-MM-DD'), 40000, 7000, 5000);

--deleting rows in employee also deletes their rows in vacation
delete from employee where empno = '222222';
delete from employee where empno = '333333';
delete from employee where empno = '444444';
delete from employee where empno = '555555';
delete from employee where empno = '666666';
delete from employee where empno = '777777';
