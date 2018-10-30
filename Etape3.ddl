-- �tape 3 � Cl�s primaires 


---------------------------------------------------------------------------------------------------
-- seq auto increment id de a tble R�seau 
CREATE SEQUENCE default_r�seau_seq
MINVALUE 100
START WITH 100
INCREMENT BY 1
CACHE 4;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Trigger : insertion id automatique dans la table R�seau 
CREATE OR REPLACE TRIGGER insertion_r�seau
	BEFORE INSERT ON R�seau
	FOR EACH ROW
	DECLARE
	new_no_r�seau R�seau.id_r�seau%TYPE; -- type bas� sur colonne
BEGIN
	SELECT default_r�seau_seq.NextVal INTO new_no_r�seau
		FROM dual;
:new.id_r�seau := new_no_r�seau;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line ('La requ�te n''a retourn� aucune valeur.');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- scripte de destruction de la sequence id pour table R�seau
DROP SEQUENCE default_r�seau_seq;