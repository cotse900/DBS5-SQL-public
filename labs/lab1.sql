/*
DBS501
Fall 2022
Chungon Tse
Lab1
25 Sep 2022
*/

-- Q1 even_odd
CREATE OR REPLACE PROCEDURE even_odd (yournum in number)
    as
    BEGIN
        if mod(yournum, 2) = 0
            then dbms_output.put_line('The number ' || yournum || ' is even.');
        else
            dbms_output.put_line('The number ' || yournum || ' is odd.');
        end if;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE ('Error!');
	END;

BEGIN
    even_odd(&input);
END;

-- Q2 factorial
DECLARE
    ftr number := 1;
    --determine factorial of n
    n number := &n;
    display number := n;
    --set exception below
    exce EXCEPTION;
BEGIN
    --exception: factorial does not work with negative numbers
    IF n < 0 THEN
        RAISE exce;
    END IF;
    WHILE (n > 0)
        LOOP
            ftr := n* ftr; -- n*(n-1)*(n-2)*...*1
            n := n-1;
        END LOOP;
    DBMS_OUTPUT.PUT_LINE ('The factorial of ' || display  || ' is ' || ftr);
    EXCEPTION
        WHEN exce THEN
            DBMS_OUTPUT.PUT_LINE ('An error occurred!');
	END;

-- Q3 calculate_salary

CREATE OR REPLACE PROCEDURE calculate_salary (empno in number) as
    fname employees.first_name%type;
    lname employees.last_name%type;
    --initial value 10000
    salary number(8,3) := 10000;
    --number of years
    hire number;
    counter number := 0;
    BEGIN
        select first_name, last_name, trunc(To_char(SYSDATE - hire_date) / 365) 
            into fname, lname, hire
        from employees
        where employee_id = empno;

    LOOP
        --after 1st year, salary increments by 5% and so counter increments until counter equals hire
        salary := salary * 1.05;
        counter := counter + 1;
        EXIT WHEN counter = hire;
    END LOOP;
        DBMS_OUTPUT.PUT_LINE ('First name: ' || fname);
        DBMS_OUTPUT.PUT_LINE ('Last name: ' || lname);
        DBMS_OUTPUT.PUT_LINE ('Salary: $' || round(salary, 2));--to round up
    EXCEPTION
        WHEN TOO_MANY_ROWS
        THEN 
                DBMS_OUTPUT.PUT_LINE ('Too Many Rows Returned!');
        WHEN NO_DATA_FOUND
        THEN 
            DBMS_OUTPUT.PUT_LINE ('Employee ID ' || empno || ' does not exist.');
        WHEN OTHERS
        THEN 
                DBMS_OUTPUT.PUT_LINE ('Error!');
	END calculate_salary;

BEGIN
	calculate_salary(&input);
end;
    
-- Q4 find_employee
CREATE OR REPLACE PROCEDURE find_employee (empno number)
    IS
        fname employees.first_name%type;
        lname employees.last_name%type;
        email_ employees.email%type;
        phone_ employees.phone%type;
        hire date;
        jobT employees.job_title%type;
    BEGIN
        Select first_name, last_name, email, phone, hire_date, job_title
        into fname, lname, email_, phone_, hire, jobT
        from employees
        where employee_id = empno;
        DBMS_OUTPUT.PUT_LINE ('First name: ' || fname);
        DBMS_OUTPUT.PUT_LINE ('Last name: ' || lname);
        DBMS_OUTPUT.PUT_LINE ('Email: ' || email_);
        DBMS_OUTPUT.PUT_LINE ('Phone: ' || phone_);
        --Date format is two digits for day, three-letter short forms for month, and two digits for year
        DBMS_OUTPUT.PUT_LINE ('Hire date: ' || to_char(hire, 'dd-MON-yy'));
        DBMS_OUTPUT.PUT_LINE ('Job title: ' || jobT);
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE ('Employee ID ' || empno || ' does not exist.');
	END find_employee;

BEGIN
	find_employee(&input);
end;
