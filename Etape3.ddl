-- Étape 3 – Clés primaires 


---------------------------------------------------------------------------------------------------
-- seq auto increment id de a tble Réseau 
CREATE SEQUENCE default_réseau_seq
MINVALUE 100
START WITH 100
INCREMENT BY 1
CACHE 4;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Trigger : insertion id automatique dans la table Réseau 
CREATE OR REPLACE TRIGGER insertion_réseau
	BEFORE INSERT ON Réseau
	FOR EACH ROW
	DECLARE
	new_no_réseau Réseau.id_réseau%TYPE; -- type basé sur colonne
BEGIN
	SELECT default_réseau_seq.NextVal INTO new_no_réseau
		FROM dual;
:new.id_réseau := new_no_réseau;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line ('La requête n''a retourné aucune valeur.');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- scripte de destruction de la sequence id pour table Réseau
DROP SEQUENCE default_réseau_seq;