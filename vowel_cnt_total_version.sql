--8 vowel_cnt
create or replace function vowel_cnt (nem in varchar2)
return varchar2 is
    retstr varchar2(100);
    m_name staff.name%type;
    m_job staff.job%type;
    reg number;
    counter number := 0;
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
                counter := counter + reg;
            end loop;
            dbms_output.put_line('The total number of vowels in Staff names: ' || counter);
        close countname;
        dbms_output.put_line('Staff job --- Number of vowels');
        open countjob;
            loop
                fetch countjob into m_name, m_job, reg;
                exit when countjob%notfound;
                dbms_output.put_line(m_name || ' --- ' || m_job || ' --- ' || reg);
                counter := counter + reg;
            end loop;
            dbms_output.put_line('The total number of vowels in Staff jobs: ' || counter);
        close countjob;        
        
        return retstr;
        --set exception
        exception
            when others then
                DBMS_OUTPUT.PUT_LINE('An error with names.');
    end;
