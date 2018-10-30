-- Étape 7 – Déclencheurs


---------------------------------------------------------------------------------------------------
--1. Le premier déclencheur : mettre à jour colonne RIR.nombre_de_IP_alloué
CREATE OR REPLACE TRIGGER calculer_ip_alloué_rir
	AFTER INSERT ON Réseau
BEGIN
  UPDATE Registraire_régional
  SET nombre_ip_alloué = (SELECT ROUND(SUM(nombre_adresses))
                            FROM Réseau
                            WHERE Réseau.reg_regional_nom = Registraire_régional.nom_rir);
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
--2. Le deuxième déclencheur  : mettre à jour la colonne RIR.nombre_de_IP_assigné 
CREATE OR REPLACE TRIGGER calculer_ip_assigné_rir
	AFTER INSERT OR UPDATE OR DELETE ON Réseau
BEGIN
  UPDATE Registraire_régional
  SET nombre_ip_assigné = (SELECT ROUND(SUM(nombre_adresses)) 
                            FROM Réseau
                            JOIN registraire_local ON registraire_local.nom_lir = Réseau.reg_local_nom
                            WHERE registraire_local.reg_régional_nom = Registraire_régional.nom_rir);
END;
