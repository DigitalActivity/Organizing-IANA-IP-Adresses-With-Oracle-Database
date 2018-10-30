-- �tape 4 � Restructuration 


---------------------------------------------------------------------------------------------------
-- Renommer la colonne ip 
ALTER TABLE R�seau RENAME COLUMN ip TO adresse_r�seau;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Ajouter la colonne adress_num�rique qui conserve ip dans un integer
ALTER TABLE R�seau ADD adresse_num�rique NUMBER(10) GENERATED ALWAYS AS (
				TO_NUMBER(REGEXP_SUBSTR(d�but_range_ip,'\w+',1,1))*POWER(2,24)
				+ TO_NUMBER(REGEXP_SUBSTR(d�but_range_ip,'\w+',1,2))*POWER(2,16)
				+ TO_NUMBER(REGEXP_SUBSTR(d�but_range_ip,'\w+',1,3))*POWER(2,8)
				+ TO_NUMBER(REGEXP_SUBSTR(d�but_range_ip,'\w+',1,4))*POWER(2,0) )
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Ajouter les deux champs dans Registraire_local
ALTER TABLE Registraire_local ADD 
	( 
	nombre_ip_allou� NUMBER(12),
	nombre_ip_assign� NUMBER(12)
	);
---------------------------------------------------------------------------------------------------

