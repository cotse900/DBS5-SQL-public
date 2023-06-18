--1
CREATE OR REPLACE PROCEDURE array_date(
  day_array IN SYS.ODCINUMBERLIST,
  month_array IN SYS.ODCINUMBERLIST
) IS
  v_date DATE;
BEGIN
  FOR i IN 1..month_array.COUNT LOOP
    FOR j IN 1..day_array.COUNT LOOP
      v_date := TO_DATE(day_array(j) || '-' || month_array(i) || '-' || EXTRACT(YEAR FROM SYSDATE), 'DD-MM-YYYY');
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_date, 'Day') || ', ' || TO_CHAR(v_date, 'Month') || ' ' || TO_CHAR(v_date, 'DD, YYYY'));
    END LOOP;
  END LOOP;
END;
/

BEGIN
  array_date(ODCINUMBERLIST(1, 5, 7), ODCINUMBERLIST(2, 4));
END;
/

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
