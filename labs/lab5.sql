--1
--create salaud table
Create table salaud(
    salaudID smallint,
    AUDDATE date,
    SALARY decimal(7,2),
    COMM decimal(7,2),
    ERRORCODE varchar(255)
);

create or replace trigger trigcom
    after
    insert or update 
        on staff
    referencing new as new
    for each row
    --set conditions for the trigger
    --invalid values go first
    --business rules (larger values) go later
        when (new.salary < 0 or new.comm < 0 or new.comm > new.salary * 0.25 or new.comm + new.salary < 50000)
declare
    change_msg varchar2(50);
    error_code varchar2(50);
begin
    --indicates insert or update
    change_msg := case
        when inserting then 'insert'
        when updating then 'update'
    end;
    --rules are simplified as error codes with conditions below
    --because this is a simple case (for if-else below)
    --invalid values precede violations of rules for this logic to work properly
    --and longer statements with 'AND' go first followed by shorter ones
    error_code := case
        when (:new.salary < 0 and :new.comm < 0) then 'inv'
        when :new.salary < 0 then 'invs'
        when :new.comm < 0 then 'invc'
        when (:new.comm > :new.salary * 0.25 and :new.comm + :new.salary < 50000) then 'SC'    
        when :new.comm > :new.salary * 0.25 then 'C'
        when :new.comm + :new.salary < 50000 then 'S'
    end;
    dbms_output.put_line('There is an ' || change_msg || ' of data in Staff with an error.');
    --shows which rule is broken
    --follow the above order of logics to allow longer logics to work
    if error_code = 'inv' then
        dbms_output.put_line('Negative salary');
        dbms_output.put_line('Negative comm');
        raise_application_error(-20001,'a');
    elsif error_code = 'invs' then
        dbms_output.put_line('Negative salary');
        raise_application_error(-20002,'b');
    elsif error_code = 'invc' then
        dbms_output.put_line('Negative comm');
        raise_application_error(-20003,'c');
    elsif error_code = 'SC' then
        dbms_output.put_line('See Salaud for the error code.');
        dbms_output.put_line('Sum rule broken');
        dbms_output.put_line('Commission rule broken');
    elsif error_code = 'C' then
        dbms_output.put_line('See Salaud for the error code.');
        dbms_output.put_line('Commission rule broken');
    elsif error_code = 'S' then
        dbms_output.put_line('See Salaud for the error code.');
        dbms_output.put_line('Sum rule broken');
    end if;
    --insert into salaud; works for both insert and update
    --salaud rows are only about broken rules, not complying values, nor invalid values
    insert into salaud (salaudid, auddate, salary, comm, errorcode)
    values (:new.id, sysdate, :new.salary, :new.comm, error_code);
end;
--PS: another exception would be duplicated ID but that would require an instead of trigger

--for testing purposes
--invalid input
--insert into staff (id, name, dept, job, years, salary, comm) values (1, 'Jon', 20, 'Mgr', 1, -50000, -5000);
--insert into staff (id, name, dept, job, years, salary, comm) values (1, 'Jon', 20, 'Mgr', 1, -50000, 5000);
--insert into staff (id, name, dept, job, years, salary, comm) values (1, 'Jon', 20, 'Mgr', 1, 50000, -5000);

--insert fictional data for 'Jon', 'Andrew', 'Joanna', 'Anne'
--INSERT 1-4
--insert into staff (id, name, dept, job, years, salary, comm) values (1, 'Jon', 20, 'Mgr', 1, 50000, 5000);
--insert into staff (id, name, dept, job, years, salary, comm) values (2, 'Andrew', 20, 'Mgr', 1, 40000, 10001);
--insert into staff (id, name, dept, job, years, salary, comm) values (3, 'Joanna', 20, 'Mgr', 1, 30000, 3000);
--insert into staff (id, name, dept, job, years, salary, comm) values (4, 'Anne', 20, 'Mgr', 1, 30000, 9000);

--update salary and comm for the fictional Jon
--UPDATE 1-4
--update staff set salary = 50000, comm = 5000 where id = 1;
--update staff set salary = 40000, comm = 10001 where id = 1;
--update staff set salary = 30000, comm = 3000 where id = 1;
--update staff set salary = 30000, comm = 9000 where id = 1;


--clean up
--truncate table salaud;
