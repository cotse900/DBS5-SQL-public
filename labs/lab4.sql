--1
--pig latin
create or replace function pig_latinay (str in out varchar2)
--this function returns the name column from the Staff table
return varchar2 is
    --expect longer strings than original ones in Staff table
    retstr varchar2(100);
    staffname staff.name%type;
    name staff.name%type;
    --cursor for Staff table
    cursor namelist is
        Select name into staffname from staff;
    begin
        open namelist;
            loop
                fetch namelist into staffname;
                exit when namelist%notfound;
                    --assume (capital) vowel letters
                    --when a staff name starts with a vowel, it only adds "ay"
                    if staffname like 'A%' or staffname like 'E%' or 
                    staffname like 'I%' or staffname like 'O%' or staffname like 'U%' then
                        retstr := initcap(concat(staffname, 'ay'));
                        dbms_output.put_line(retstr);
                    else
                    --when a staff name doesn't start with a vowel
                    --removes first letter
                    --first letter goes to the end
                    --add "ay"
                        retstr := trim(substr(staffname,1,1) from staffname);
                        retstr := concat(retstr, substr(staffname,1,1));
                        retstr := initcap(concat(retstr, 'ay'));
                        dbms_output.put_line(retstr);
                    end if;
            end loop;
        close namelist;
            return retstr;
        --set exception
        exception
            when others then
                dbms_output.put_line('Invalid data.');
    end;

--2
--experience
create or replace function experience (yrs in out integer)
--this function returns the name and years columns from the Staff table
return string is 
    retstr string(15);
    staffname staff.name%type;
    inv exception;
    yr integer;
    years integer;
    --use cursor in staff table
    cursor namelist is
        Select name, years into staffname, yr from staff;
begin
    open namelist;
        dbms_output.put_line('Staff Name' || '   ' || 'Years' || '   ' || 'Experience');
        loop
            fetch namelist into staffname, yr;
            exit when namelist%notfound;
                --set exception
                if yr < 0 then
                    raise inv;
                    end if;
                --some year cells are empty and so assume they mean zero year
                if yr >= 0 and yr <= 4 or yr is null then
                    retstr := 'Junior';
                    dbms_output.put_line(staffname || '   ' || yr || '   ' ||retstr);
                elsif yr >= 5 and yr <= 9 then
                    retstr := 'Intermediate';
                    dbms_output.put_line(staffname || '   ' || yr || '   ' ||retstr);
                elsif yr >= 10 then
                    retstr := 'Experienced';
                    dbms_output.put_line(staffname || '   ' || yr || '   ' ||retstr);
                else
                    raise no_data_found;
                end if;
        end loop;
    close namelist;
        return retstr;
    --set exception
    exception
        when inv then
            dbms_output.put_line('Invalid number of years.');
end;
