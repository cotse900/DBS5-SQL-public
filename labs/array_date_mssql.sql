CREATE OR ALTER PROCEDURE array_date
    @day_array NVARCHAR(MAX),
    @month_array NVARCHAR(MAX)
AS
BEGIN
    DECLARE @i INT;
    DECLARE @j INT;
    DECLARE @v_date DATE;

    CREATE TABLE #Result (day_of_week NVARCHAR(50), date_value DATE);

    DECLARE @DayTable TABLE (RowNum INT IDENTITY(1,1), Value INT);
    DECLARE @MonthTable TABLE (RowNum INT IDENTITY(1,1), Value INT);

    INSERT INTO @DayTable (Value)
    SELECT CAST(value AS INT) FROM STRING_SPLIT(@day_array, ',');

    INSERT INTO @MonthTable (Value)
    SELECT CAST(value AS INT) FROM STRING_SPLIT(@month_array, ',');

    SET @i = 1;
    WHILE @i <= (SELECT COUNT(*) FROM @MonthTable)
    BEGIN
        SET @j = 1;
        WHILE @j <= (SELECT COUNT(*) FROM @DayTable)
        BEGIN
            SET @v_date = CONVERT(DATE, CAST((SELECT Value FROM @DayTable WHERE RowNum = @j) AS NVARCHAR(2)) + '-' + CAST((SELECT Value FROM @MonthTable WHERE RowNum = @i) AS NVARCHAR(2)) + '-' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)), 105);
            INSERT INTO #Result (day_of_week, date_value) VALUES (DATENAME(WEEKDAY, @v_date), @v_date);
            SET @j = @j + 1;
        END
        SET @i = @i + 1;
    END

    SELECT * FROM #Result;

    DROP TABLE #Result;
END;
--execute
EXEC array_date '1,5,7', '2,4';
--output (current year)
--"Wednesday"	"2023-02-01"
--"Sunday   "	"2023-02-05"
--"Tuesday  "	"2023-02-07"
--"Saturday "	"2023-04-01"
--"Wednesday"	"2023-04-05"
--"Friday   "	"2023-04-07"
