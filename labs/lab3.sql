--2
Create or replace procedure name_fun as
    lname employees.last_name%type;
    --use cursor
    --use replace to change vowels to *
    --rpad strings with +
    --get rid of every last name starting with a vowel (capital letters)
    cursor nem1 is
        select rpad(replace(replace(replace(replace(replace(last_name, 'a', '*'), 'e', '*'), 'i', '*'), 'o', '*'), 'u', '*'), 15, '+')
            from employees where not (last_name like 'A%' or last_name like 'E%' 
            or last_name like 'I%' or last_name like 'O%' or last_name like 'U%');
    begin
        DBMS_OUTPUT.PUT_LINE('Employees Table last names, which do not start with a vowel, with vowels in asterisks:');
        open nem1;
            loop
                fetch nem1 into lname;
                exit when nem1%notfound;
                DBMS_OUTPUT.PUT_LINE(lname);
                end loop;
            close nem1;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error with names.');
    end;
    
    
begin
    name_fun();
end;
