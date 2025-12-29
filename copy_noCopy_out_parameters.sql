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
