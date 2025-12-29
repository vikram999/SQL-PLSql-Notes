--NO copy performs better in case of large volume of data is being IN/OUT from a Function 
--It does not pass that actual value ,instead it passes the reference/address where it is kept in memory 
--so it avoids overhead of keeping backandForth 

--in case of OUT as CLOB BLOB LONG , it performs better 
-- if it is smaller cases , then it won't make any sense and benefit 
--it is request to Oracle , not an order , so oracle may ignore this 

--This has side effects also 
--if in between some exception raises then it does not keeps original value passed 
--in case of IN OUT param , it messes the values , few will be before changes few will be changed once 
--Rollback won't make any difference , as that works on database level not on memory variables.
--Below is the example that shows the messed values in case any error occurs 
--one more example is there without NOCOPY , that keeps original values in case of any execeptions 














CREATE OR REPLACE PROCEDURE p_test_nocopy (
   pit_array IN OUT NOCOPY lt_associated_array
) AS
BEGIN
   pit_array.EXTEND;
   pit_array(1) := 'VIKRAM';

   pit_array.EXTEND;
   pit_array(2) := 'SUCCESS';

   -- 🔥 failure AFTER memory mutation
   RAISE_APPLICATION_ERROR(-20001, 'Failure inside procedure');
END;


/
CREATE OR REPLACE PROCEDURE p_test_withcopy (
   pit_array IN OUT lt_associated_array
) AS
BEGIN
   pit_array.EXTEND;
   pit_array(1) := 'VIKRAM';

   pit_array.EXTEND;
   pit_array(2) := 'SUCCESS';

   -- 🔥 failure AFTER memory mutation
   RAISE_APPLICATION_ERROR(-20001, 'Failure inside procedure');
END;

/








--test case

DECLARE
   lv lt_associated_array := lt_associated_array();
BEGIN
   lv.EXTEND;
   lv(1) := 'PENDING';
   --p_test_nocopy(lv);
   p_test_withcopy(lv);
EXCEPTION
   WHEN OTHERS THEN
     IF lv.COUNT = 0 THEN
         DBMS_OUTPUT.put_line('Array is EMPTY');
      ELSE
      DBMS_OUTPUT.put_line('--- After exception (NOCOPY) ---');
      FOR i IN lv.FIRST .. lv.LAST LOOP
         DBMS_OUTPUT.put_line(lv(i));
      END LOOP;
     END IF;
END;
/
