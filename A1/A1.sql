--2
Create or replace procedure salary_rating (employeeNum in number, rating in number) as
    eSalary employee.salary%type;
    eBonus employee.bonus%type;
    eComm employee.comm%type;
    nSalary employee.salary%type;
    nBonus employee.bonus%type;
    nComm employee.comm%type;
    wrongRating exception;
BEGIN
    Select salary, bonus, comm into eSalary, eBonus, eComm from employee
    where cast(empno as number) = employeeNum;
    --set rating exceptions
    if rating not in (1,2,3) then
        raise wrongRating;
    end if;
    if rating = 1 then
        nSalary := eSalary + 10000;
        nBonus := eBonus + 300;
        nComm := eComm * 1.05;
    elsif rating = 2 then
        nSalary := eSalary + 5000;
        nBonus := eBonus + 200;
        nComm := eComm * 1.02;
    elsif rating = 3 then
        nSalary := eSalary + 2000;
        nBonus := eBonus;
        nComm := eComm;
    end if;
        dbms_output.put_line ('EMP ID: ' || employeeNum);
        dbms_output.put_line ('OLD SALARY: ' || eSalary);
        dbms_output.put_line ('OLD BONUS: ' || eBonus);   
        dbms_output.put_line ('OLD COMM: ' || eComm);     

        dbms_output.put_line ('NEW SALARY: ' || nSalary);
        dbms_output.put_line ('NEW BONUS: ' || nBonus);    
        dbms_output.put_line ('NEW COMM: ' || nComm);
    exception
        when wrongRating then
            dbms_output.put_line ('Wrong rating. Rating should only be 1, 2, or 3.');
        when no_data_found then
            dbms_output.put_line ('The Employee ID ' || employeeNum || ' does not exist!');
END;


DECLARE
    employeeNum number := &employeeNum;
    rating number := &rating; 
BEGIN
    salary_rating (employeeNum, rating);
END;

--3
create or replace procedure employee_edlevel (employeeNum in number, lvl in char) as
    oldLevel employee.edlevel%type;
    newLevel employee.edlevel%type;
    neverReduceEdLevel exception;

BEGIN
    Select edlevel into oldLevel from employee
    where cast(empno as number) = employeeNum;
    case
        when lvl = 'H' or lvl = 'h' then newLevel := 16;
        when lvl = 'C' or lvl = 'c' then newLevel := 19;
        when lvl = 'U' or lvl = 'u' then newLevel := 20;
        when lvl = 'M' or lvl = 'm' then newLevel := 23;
        when lvl = 'P' or lvl = 'p' then newLevel := 25;
        ELSE
            dbms_output.put_line('Incorrect education level input.');
            dbms_output.put_line('Education levels are: ');
            dbms_output.put_line('H - High School Diploma');
            dbms_output.put_line('C - College Diploma');
            dbms_output.put_line('U - University Degree');
            dbms_output.put_line('M - Master');
            dbms_output.put_line('P - PhD');
    end case;
    --set exception on no reduction of education level
    if newLevel < oldLevel then
        RAISE neverReduceEdLevel;
    end if;
        dbms_output.put_line ('EMP ID: ' || employeeNum);
        dbms_output.put_line ('OLD EDUCATION: ' || oldLevel);
        dbms_output.put_line ('NEW EDUCATION: ' || newLevel);
    exception
        when no_data_found then
            dbms_output.put_line ('The Employee ID does not exist!');
        when neverReduceEdLevel then
            dbms_output.put_line ('The education level can only stay the same or go up, not reduced.');
END;

DECLARE
    employeeNum number := &employeeNum;
    elevel char := '&elevel';
BEGIN
    employee_edlevel (employeeNum, elevel);
END;

--4: in the procedures below, many output lines are done in individual procedures including master_proc
--find_customer
create or replace procedure find_customer (cid in number, found out number) as
    counter number := 0;
BEGIN
    Select customer_id into found from customers
    where customer_id = cid;
    --found = 1, not found = 0
    if counter = 1 then
        found := 1;
    else
        found := 0;
    end if;
    dbms_output.put_line('Customer ID ' || cid || ' found.');
    exception
        when no_data_found then
            found := 0;
            dbms_output.put_line('Customer ID ' || cid || ' not found.');
        when others then
            found := 0;
            dbms_output.put_line('There is an error.');
END;

--find_product
create or replace procedure find_product (pid in number, price out products.list_price%type) as
BEGIN
    Select list_price into price from products
    where product_id = pid;
    dbms_output.put_line('Product ID ' || pid || ' found.');
    --use conventional exceptions
    exception
        when no_data_found then
            price := 0;
            dbms_output.put_line('Product ID ' || pid || ' not found.');
        when others then
            dbms_output.put_line('There is an error.');
END;

--add_order
create or replace procedure add_order (cid in number, new_order_id out number) as
    wrongcust exception;
BEGIN
    Select max(order_id) into new_order_id from orders;
    new_order_id := new_order_id + 1;
     --customer id only between 1 and 318
    if cid < 1 or cid > 318 then
        raise wrongcust;
    end if;
    --order id increments in every case, so there can be no exception
    Insert into orders(order_id, customer_id, status, salesman_id, order_date) values
    (new_order_id, cid, 'Shipped', 56, sysdate);

    dbms_output.put_line('New order for Customer ID ' || cid || ' is added.');
    exception
        when wrongcust then
            dbms_output.put_line('Customer ID ' || cid || ' not found.');
        WHEN no_data_found THEN
            dbms_output.put_line('No order id found.');
        WHEN OTHERS THEN
            dbms_output.put_line('There is an error.');
END;

--add_order_item
create or replace procedure add_order_item
    (insert_orderId IN order_items.order_id%type, 
    insert_itemId IN order_items.item_id%type, 
    insert_productId IN order_items.product_id%type, 
    insert_quantity IN order_items.quantity%type, 
    insert_price IN order_items.unit_price%type)
    as
    orderid_exec exception;
    itemid_exec exception;
    productid_exec exception;
    qty_exec exception;
    price_exec exception;
BEGIN
    --exception for numerical range and only integers are accepted for all except price
    if mod(insert_orderId, 1) != 0 or insert_orderId < 1 or insert_orderId > 999 then
        raise orderid_exec;
    end if;
    if mod(insert_itemId, 1) != 0 or insert_itemId < 1 or insert_itemId > 99 then
        raise itemid_exec;
    end if;
    if mod(insert_productId, 1) != 0 or insert_productId < 1 or insert_productId > 288 then
        raise productid_exec;
    end if;
    if mod(insert_quantity, 1) != 0 or insert_quantity < 1 or insert_quantity > 999 then
        raise qty_exec;
    end if;
    if insert_price < 0 or insert_price > 9999 then
        raise price_exec;
    end if;
    
    Insert into order_items
        (order_id, item_id, product_id, quantity, unit_price)
        values (insert_orderId, insert_itemId, insert_productId, insert_quantity, insert_price);
    dbms_output.put_line('Order ID ' || insert_orderId || 
        ' Item ID ' || insert_itemId || 
        ' Product ID ' || insert_productId || 
        ' Quantity ' || insert_quantity || 
        ' Price ' || insert_price || ' is added.');
    exception
        when orderid_exec then
            dbms_output.put_line('Order ID ' || insert_orderId || ' is invalid.');
        when itemid_exec then
            dbms_output.put_line('Item ID ' || insert_itemId || ' is invalid.');
        when productid_exec then
            dbms_output.put_line('Product ID ' || insert_productId || ' is invalid.');
        when qty_exec then
            dbms_output.put_line('Quantiy ' || insert_quantity || ' is invalid.');
        when price_exec then
            dbms_output.put_line('Price ' || insert_price || ' is invalid.');
        WHEN OTHERS THEN
            dbms_output.put_line('There is an error.');
END;

--display_order
Create or replace procedure display_order (orderNum in number) as
    --join order_items and orders tables
Cursor display is
    select a.order_id as "orderid", b.customer_id as "cid", item_id, product_id, quantity, unit_price, quantity * unit_price as "Total"
    from (order_items a left outer join orders b on a.order_id = b.order_id)
    where a.order_id = orderNum;
    
    orderid     order_items.order_id%type;
    cid         orders.customer_id%type;
    item_id     order_items.item_id%type;
    product_id  order_items.product_id%type;
    qty         order_items.quantity%type;
    unit_price  order_items.unit_price%type;
    total       order_items.unit_price%type;
    total_price number := 0;
    counter number := 0;
    
    BEGIN
        open display;
        --explicit cursor loop
        loop
            counter := counter + 1;
            fetch display into orderid, cid, item_id, product_id, qty, unit_price, total;
            exit when display%notfound;
        
            if counter <= 1 then
                dbms_output.put_line('Order ID   : '|| orderid);
                dbms_output.put_line('Customer ID: '|| cid);
            end if;
        --increment price
            dbms_output.put_line('  Item ID: '|| item_id || ', Product ID: '|| product_id || ', Quantity: '|| qty || ', Price: '|| unit_price);
            total_price :=  total + total_price;
        end loop;
        
        if display%rowcount = 0 then
            dbms_output.put_line('Order ID: '|| orderNum ||' does not exist.');
        else
            dbms_output.put_line('Total price: '|| total_price);
        end if;
        
        close display;
    END;

--master_proc
Create or replace procedure master_proc (task in number, parm1 in number) as
    findcust number;
    findprodprice products.list_price%type;
    orderid number;
    wrongnum exception;
    BEGIN
        Case task
            when 1 then find_customer(parm1, findcust);
            when 2 then find_product(parm1, findprodprice);
            when 3 then add_order(parm1, orderid);
            when 4 then display_order(parm1);
        end case;
        --check integer input for task
        if task < 1 or task > 4 then
            raise wrongnum;
        end if;
        exception
            when wrongnum then
                dbms_output.put_line('Wrong input. Please enter 1, 2, 3, or 4 only.');
            when others then
                dbms_output.put_line('An error has occurred.');
    END;

--execution of all procedures of #3
--add_order and add_order_item change the database content; the rest don't
BEGIN
    --#1
    dbms_output.put_line('1 – find_customer – with a valid customer ID');
        master_proc(1, 187);
    dbms_output.put_line('');
    --#2
    dbms_output.put_line('2 – find_customer – with an invalid customer ID');
        master_proc(1, 319);
    dbms_output.put_line('');
    --#3
    dbms_output.put_line('3 – find_product – with a valid product ID');
        master_proc(2, 228);
    dbms_output.put_line('');
    --#4
    dbms_output.put_line('4 – find_product – with an invalid product ID');
        master_proc(2, 1000);
    dbms_output.put_line('');
    --#5
    dbms_output.put_line('5 – add_order – with a valid customer ID');
        master_proc(3, 1);
    dbms_output.put_line('');
    --#6
    dbms_output.put_line('6 – add_order – with an invalid customer ID');
        master_proc(3, 319);
    dbms_output.put_line('');
    --#7 calling add_order_item 5 times
    dbms_output.put_line('7 – add_order_item – should execute successfully 5 times');
        add_order_item(1, 14, 288, 999, 9999);
        add_order_item(1, 15, 288, 999, 9999);
        add_order_item(1, 16, 288, 999, 9999);
        add_order_item(1, 17, 288, 999, 9999);
        add_order_item(1, 18, 288, 999, 9999);
    dbms_output.put_line('');
    --8
    dbms_output.put_line('8 – add_order_item – should execute with an invalid order ID');
        add_order_item(1000, 1, 288, 999, 9999);
    dbms_output.put_line('');
    --9
    dbms_output.put_line('9 – display_order – with a valid order ID which has at least 5 order items');
        master_proc(4, 2);
    dbms_output.put_line('');
    --10
    dbms_output.put_line('10 – display_order – with an invalid order ID');
        master_proc(4, 1000);
END;
