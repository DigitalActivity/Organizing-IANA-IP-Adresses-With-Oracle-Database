-- �tape 9 - Vue 
 
 
---------------------------------------------------------------------------------------------------
-- Vue avec les memes info que IANA avec  les tables de IPWHOIS
CREATE OR REPLACE VIEW view_comme_iana AS
SELECT adresse_r�seau AS ip, 
		nombre_bits AS bts, 
		nom_r�seau AS Designation, 
		�tat_iana.date_etat AS date_iana, 
		Registraire_r�gional.adresse_whois,
		reg_regional_nom, 
		�tat_iana.�tat
	FROM R�seau
	JOIN �tat_iana ON �tat_iana.r�seau_id_r�seau = R�seau.id_r�seau
	JOIN Registraire_r�gional ON Registraire_r�gional.nom_rir = R�seau.reg_regional_nom
	ORDER BY adresse_r�seau ASC;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Visualiser le view 
SELECT * FROM view_comme_iana;