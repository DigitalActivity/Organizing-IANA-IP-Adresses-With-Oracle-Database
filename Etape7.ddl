-- �tape 7 � D�clencheurs


---------------------------------------------------------------------------------------------------
--1. Le premier d�clencheur : mettre � jour colonne RIR.nombre_de_IP_allou�
CREATE OR REPLACE TRIGGER calculer_ip_allou�_rir
	AFTER INSERT ON R�seau
BEGIN
  UPDATE Registraire_r�gional
  SET nombre_ip_allou� = (SELECT ROUND(SUM(nombre_adresses))
                            FROM R�seau
                            WHERE R�seau.reg_regional_nom = Registraire_r�gional.nom_rir);
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
--2. Le deuxi�me d�clencheur  : mettre � jour la colonne RIR.nombre_de_IP_assign� 
CREATE OR REPLACE TRIGGER calculer_ip_assign�_rir
	AFTER INSERT OR UPDATE OR DELETE ON R�seau
BEGIN
  UPDATE Registraire_r�gional
  SET nombre_ip_assign� = (SELECT ROUND(SUM(nombre_adresses)) 
                            FROM R�seau
                            JOIN registraire_local ON registraire_local.nom_lir = R�seau.reg_local_nom
                            WHERE registraire_local.reg_r�gional_nom = Registraire_r�gional.nom_rir);
END;
