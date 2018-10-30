-- Étape 8 – Index 


---------------------------------------------------------------------------------------------------
-- index utile pour le Declenceur ( calculer_ip_assigné_rir  Etape7)
CREATE index reg_local_nom_region_nom_idx ON registraire_local( nom_lir, reg_régional_nom);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour afficher prop_privé et son lir
CREATE index propriétaire_privé_idx ON Propriétaire_privé(nom_pir, reg_local_nom);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour IANA : designation , premier site
CREATE INDEX iana_desig_siteweb_idx ON IANA (
			designation,
			rdap);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour IANA : designation, nomRir, site, date
CREATE INDEX iana_desi_rir_site_date_idx ON IANA (
      prefix_iana ,
			whois_iana ,
			rdap,
			date_iana);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour sous réseau : clé étrangere sous_réseau_id_réseau 
   CREATE INDEX réseau_sousréseau_idx ON Réseau (
      sous_réseau_id_réseau);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour (view de Etape9) 
CREATE index réseau_rir_idx ON Réseau( id_réseau, reg_regional_nom);
---------------------------------------------------------------------------------------------------
