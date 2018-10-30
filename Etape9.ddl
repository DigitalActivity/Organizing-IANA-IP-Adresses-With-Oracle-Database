-- Étape 9 - Vue 
 
 
---------------------------------------------------------------------------------------------------
-- Vue avec les memes info que IANA avec  les tables de IPWHOIS
CREATE OR REPLACE VIEW view_comme_iana AS
SELECT adresse_réseau AS ip, 
		nombre_bits AS bts, 
		nom_réseau AS Designation, 
		État_iana.date_etat AS date_iana, 
		Registraire_régional.adresse_whois,
		reg_regional_nom, 
		État_iana.état
	FROM Réseau
	JOIN État_iana ON État_iana.réseau_id_réseau = Réseau.id_réseau
	JOIN Registraire_régional ON Registraire_régional.nom_rir = Réseau.reg_regional_nom
	ORDER BY adresse_réseau ASC;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Visualiser le view 
SELECT * FROM view_comme_iana;