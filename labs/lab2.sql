--Q1
create or replace PROCEDURE factorial (n in number, ftr out number ) as
        exce exception;
    BEGIN
        --exceptions for floats and negative nums
        if (mod(n, 1) != 0) or (n < 0) then
            raise exce;
        end if;
        if n = 0 or n = 1 then
            ftr := 1;
        else
            factorial(n-1 , ftr);
            ftr := n * ftr;
        end if;
    EXCEPTION
        --I added this because adding exceptions tends to invite out of memory errors...
        when storage_error then
            DBMS_OUTPUT.PUT_LINE ('A memory error occurred!');
        when exce then
            DBMS_OUTPUT.PUT_LINE ('Non-integers or negative numbers don''t work here. Please use a positive integer.');
    END;
    
declare
    runthisnum number;
begin
    factorial(&input, runthisnum);
        dbms_output.put_line('The factorial of ' || &input || ' is ' || runthisnum);
end;

--Q2
create or replace PROCEDURE fibonacci (n number, fib out number) IS
    --Fibonacci sequence is F(n) = F(n-1) + F(n-2)
    --so first declare n1 and n2 for use in F(n)
    n1 number;
    n2 number;
    exce exception;
BEGIN
    --exceptions for floats and negative nums
    if mod(n, 1) != 0 or n < 0 then
        raise exce;
    end if;
    if n = 0 then
        fib := 0;
    elsif n = 1 then
        fib := 1;
    --general cases below
    --call recursively and determine n1 and n2 whose sum is the required fib
    elsif n > 1 then
        fibonacci(n-1, n1);
        fibonacci(n-2, n2);
        fib := n1 + n2;
    END IF;
    EXCEPTION
        when exce then
            DBMS_OUTPUT.put_line ('The fibonacci sequence is not defined for negative integers.');
END;



declare fibnum number;
begin
    fibonacci(&input, fibnum);
        DBMS_OUTPUT.put_line ('The fibonacci number of ' || &input || ' is ' || fibnum || '.');
end;

--Q3
--category_id is a column in products, so I use another var name to avoid confusion
create or replace procedure update_price_by_cat (insertID products.category_id%type, amount NUMBER) AS
    rows_updated NUMBER;
    BEGIN
        UPDATE PRODUCTS
        SET list_price = list_price + amount
        --category_id in products equals insertID HERE
            WHERE category_id = insertID and list_price > 0;
            rows_updated := sql%rowcount;
        IF rows_updated = 0 then
            DBMS_OUTPUT.PUT_LINE ('Wrong ID inserted');
        ELSE 
            DBMS_OUTPUT.PUT_LINE ('The number of updated rows in PRODUCTS is: ' || rows_updated);
        END IF; 
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE ('Error!');
    END;
    
DECLARE
    --example: category id is 1, by $5
    productType NUMBER := 1;
    byHowMuch NUMBER := 5;
BEGIN
    update_price_by_cat(productType, byHowMuch);
END;

--Q4
Create or Replace procedure update_price_under_avg IS
        --determine average price, compare every list_price with avgp
        --and determine how many rows updated as a result
        avgp products.list_price%type;
        updated_rows number;
    BEGIN
        Select avg(list_price) into avgp from products;
        --in original data average price is around $903 so 1.02 factor applies
        IF avgp <= 1000 THEN
            update products
            set list_price = list_price*1.02
                where list_price < avgp;
                updated_rows := sql%rowcount;
        ELSE
            update products
            set list_price = list_price*1.01
                where list_price < avgp;
                updated_rows := sql%rowcount;
        END IF;
            dbms_output.put_line('Number of updates: ' || updated_rows);
        EXCEPTION
            WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE ('An error occurred!');
    END;

begin
update_price_under_avg();
end;

--Q5

create or replace procedure product_price_report IS
    avg_price number(9,2);
    min_price number(9,2);
    max_price number(9,2);
    cheap_count number;
    fair_count number;
    exp_count number;
BEGIN
    --determine average, minimum, maximum prices
    --count rows of list price where it is in the ranges calculated below
    Select avg(list_price), min(list_price), max(list_price)
        into avg_price, min_price, max_price
            from products;
    Select count(list_price)
        into cheap_count
            from products
                where list_price < (avg_price - min_price)/2;
    Select count(list_price)
        into exp_count
            from products
                where list_price > (max_price - avg_price)/2;
    Select count(list_price)
        into fair_count
            from products
                where list_price <= (max_price - avg_price)/2 and list_price >= (avg_price - min_price)/2;

        dbms_output.put_line('Cheap: ' || cheap_count);
        dbms_output.put_line('Fair: ' || fair_count);
        dbms_output.put_line('Expensive: ' || exp_count);  
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE ('Error!');
END;

begin
product_price_report();
end;
