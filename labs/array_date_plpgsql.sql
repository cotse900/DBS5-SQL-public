CREATE OR REPLACE FUNCTION array_date(
  day_array INT[],
  month_array INT[]
) RETURNS TABLE (day_of_week TEXT, date_value DATE) AS $$
DECLARE
  v_date DATE;
  i INT;
  j INT;
BEGIN
  FOR i IN 1..array_length(month_array, 1) LOOP
    FOR j IN 1..array_length(day_array, 1) LOOP
      v_date := TO_DATE(day_array[j] || '-' || month_array[i] || '-' || EXTRACT(YEAR FROM CURRENT_DATE), 'DD-MM-YYYY');
      RETURN QUERY SELECT TO_CHAR(v_date, 'Day'), v_date;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

--use this to run it
SELECT * FROM array_date(ARRAY[1, 5, 7], ARRAY[2, 4]);
--output (current year)
--"Wednesday"	"2023-02-01"
--"Sunday   "	"2023-02-05"
--"Tuesday  "	"2023-02-07"
--"Saturday "	"2023-04-01"
--"Wednesday"	"2023-04-05"
--"Friday   "	"2023-04-07"
