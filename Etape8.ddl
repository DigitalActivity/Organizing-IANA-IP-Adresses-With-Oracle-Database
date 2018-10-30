-- �tape 8 � Index 


---------------------------------------------------------------------------------------------------
-- index utile pour le Declenceur ( calculer_ip_assign�_rir  Etape7)
CREATE index reg_local_nom_region_nom_idx ON registraire_local( nom_lir, reg_r�gional_nom);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour afficher prop_priv� et son lir
CREATE index propri�taire_priv�_idx ON Propri�taire_priv�(nom_pir, reg_local_nom);
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
-- index pour sous r�seau : cl� �trangere sous_r�seau_id_r�seau 
   CREATE INDEX r�seau_sousr�seau_idx ON R�seau (
      sous_r�seau_id_r�seau);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- index pour (view de Etape9) 
CREATE index r�seau_rir_idx ON R�seau( id_r�seau, reg_regional_nom);
---------------------------------------------------------------------------------------------------
