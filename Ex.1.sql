
--import danych

DROP TABLE TEAM;
DROP TABLE LOCATION;
DROP TABLE JOB;

--tabela team
create table team 
(
       team_id number(3) primary key,
       description varchar2(100)
);

--tabela location
create table location
(
         location_id number(3) primary key,
         city varchar(40),
         country varchar2(40)
);

--tabela job
create table job
(
        job_id number(3) primary key,
        location_id number(3) references location(location_id),
        team_id number(3) references  team(team_id),
        title varchar(150),
        created date
)


--WYZWALACZE
create sequence seq_team_team_id;
create sequence seq_location_location_id;
create sequence seq_job_job_id;

--SEKWENCJE
--1
CREATE OR REPLACE TRIGGER T_SET_TEAM_TEAM_ID
BEFORE INSERT 
ON TEAM
FOR EACH ROW
BEGIN
            :NEW.TEAM_ID :=  SEQ_TEAM_TEAM_ID.NEXTVAL;
END;

--2
CREATE OR REPLACE TRIGGER T_SET_LOCATION_LOCATION_ID
BEFORE INSERT 
ON LOCATION
FOR EACH ROW
BEGIN
            :NEW.LOCATION_ID :=  SEQ_LOCATION_LOCATION_ID.NEXTVAL;
END;

--3
CREATE OR REPLACE TRIGGER T_SET_JOB_JOB_ID
BEFORE INSERT 
ON JOB
FOR EACH ROW
BEGIN
            :NEW.JOB_ID :=  SEQ_JOB_JOB_ID.NEXTVAL;
END;



CREATE OR REPLACE TRIGGER ZADANIE_4
BEFORE INSERT OR UPDATE OF TITLE
ON JOB
FOR EACH ROW
BEGIN 
          :NEW.CREATED := SYSDATE();
END;



CREATE OR REPLACE PACKAGE ZADANIE_5 AS
          PROCEDURE ZADANIE_5_A;
          FUNCTION  ZADANIE_5_B(C LOCATION.CITY%TYPE, D TEAM.DESCRIPTION%TYPE) RETURN NUMBER;
          FUNCTION ZADANIE_5_C RETURN VARCHAR2;
END;

CREATE OR REPLACE PACKAGE BODY ZADANIE_5 AS 

PROCEDURE ZADANIE_5_A 
IS
BEGIN

--LOCATION    
          MERGE 
          INTO LOCATION L
          USING(SELECT SUBSTR(LOCATION , 1, INSTR(LOCATION, ',')-1) AS  CITY,  SUBSTR(LOCATION, INSTR(LOCATION, ',')+1)  AS  COUNTRY
                     FROM TEMP1
                     GROUP BY SUBSTR(LOCATION , 1, INSTR(LOCATION, ',')-1) , SUBSTR(LOCATION, INSTR(LOCATION, ',')+1) )   G
          ON (L.CITY=G.CITY AND L.COUNTRY=G.COUNTRY)
          WHEN NOT MATCHED THEN INSERT(L.CITY, L.COUNTRY) VALUES (G.CITY, G.COUNTRY);

--TEAM
          MERGE 
          INTO TEAM T
          USING( SELECT TEAM
                     FROM TEMP1
                     GROUP BY TEAM) E
          ON (T.DESCRIPTION = E.TEAM)
          WHEN NOT MATCHED THEN INSERT(T.DESCRIPTION) VALUES (E.TEAM);
--JOB
          MERGE
          INTO JOB J
          USING(SELECT JOB_TITLE, TEAM_ID, LOCATION_ID
                      FROM TEMP1 T1 JOIN LOCATION L ON (SUBSTR(T1.LOCATION , 1, INSTR(T1.LOCATION, ',')-1) = L.CITY
                      AND SUBSTR(T1.LOCATION, INSTR(T1.LOCATION, ',')+1) = L.COUNTRY  )
                              JOIN TEAM T ON T1.TEAM = T.DESCRIPTION
                      ) F
          ON (J.LOCATION_ID = F.LOCATION_ID AND J.TEAM_ID = F.TEAM_ID AND J.TITLE = F.JOB_TITLE)
          WHEN NOT MATCHED THEN INSERT(J.TITLE, J.TEAM_ID, J.LOCATION_ID) VALUES (F.JOB_TITLE, F.TEAM_ID, F.LOCATION_ID) ;   
          
       
               
END ;

----B
FUNCTION ZADANIE_5_B(C LOCATION.CITY%TYPE, D TEAM.DESCRIPTION%TYPE) RETURN NUMBER IS OFERTY NUMBER;
BEGIN 
        SELECT COUNT(TITLE)
        INTO OFERTY
        FROM JOB
        WHERE TEAM_ID = (SELECT TEAM_ID
                                        FROM TEAM 
                                        WHERE UPPER(DESCRIPTION) = D)
                    AND LOCATION_ID IN (SELECT LOCATION_ID
                                                        FROM LOCATION
                                                         WHERE UPPER(CITY) = C);                
          RETURN OFERTY;
                                                         
END ZADANIE_5_B;
--SELECT ZADANIE_5_B('AMSTERDAM', 'FINANCE') FROM DUAL;


--C
FUNCTION ZADANIE_5_C RETURN VARCHAR2 IS NAZWA VARCHAR2(150) ;
BEGIN
SELECT CITY
INTO NAZWA
FROM JOB J JOIN LOCATION L ON J.LOCATION_ID=L.LOCATION_ID
GROUP BY CITY 
HAVING COUNT(TITLE) = (SELECT MAX(COUNT(TITLE))
                                             FROM JOB J JOIN LOCATION L ON J.LOCATION_ID=L.LOCATION_ID
                                             GROUP BY CITY);
          RETURN NAZWA;               
END ZADANIE_5_C;



END;


EXECUTE ZADANIE_5.ZADANIE_5_A;

SELECT DISTINCT ZADANIE_5.ZADANIE_5_B('AMSTERDAM','FINANCE') as wynik_5_B
FROM JOB; 

SELECT DISTINCT ZADANIE_5.ZADANIE_5_C AS WYNIK_5_C
FROM JOB; 


SELECT* FROM JOB ORDER BY JOB_ID;


--wywolania
SELECT * FROM LOCATION ORDER BY CITY;

SELECT * FROM TEAM ORDER BY DESCRIPTION;

SELECT * FROM JOB ORDER BY TITLE; 

