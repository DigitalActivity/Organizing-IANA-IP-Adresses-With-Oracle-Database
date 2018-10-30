-- Étape 4 – Restructuration 


---------------------------------------------------------------------------------------------------
-- Renommer la colonne ip 
ALTER TABLE Réseau RENAME COLUMN ip TO adresse_réseau;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Ajouter la colonne adress_numérique qui conserve ip dans un integer
ALTER TABLE Réseau ADD adresse_numérique NUMBER(10) GENERATED ALWAYS AS (
				TO_NUMBER(REGEXP_SUBSTR(début_range_ip,'\w+',1,1))*POWER(2,24)
				+ TO_NUMBER(REGEXP_SUBSTR(début_range_ip,'\w+',1,2))*POWER(2,16)
				+ TO_NUMBER(REGEXP_SUBSTR(début_range_ip,'\w+',1,3))*POWER(2,8)
				+ TO_NUMBER(REGEXP_SUBSTR(début_range_ip,'\w+',1,4))*POWER(2,0) )
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Ajouter les deux champs dans Registraire_local
ALTER TABLE Registraire_local ADD 
	( 
	nombre_ip_alloué NUMBER(12),
	nombre_ip_assigné NUMBER(12)
	);
---------------------------------------------------------------------------------------------------

