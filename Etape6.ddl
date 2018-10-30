-- �tape 6 � Chargement de la nouvelle base de donn�es 
--Legende status (www.iana.org): 
	--RESERVED:	designated by the IETF for specific non-global-unicast purposes as noted.
	--LEGACY:	(PIRs/RIRs) allocated by the central Internet Registry (IR) prior to the Regional Internet Registries (RIRs).
	--ALLOCATED:(LIRs) delegated entirely to specific RIR as indicated.
	--UNALLOCATED: not yet allocated or reserved.
	
-- Note :
	-- Dans la liste des adresses sur www.iana.org les noms des LIRs sont remplac�s par les noms des RIRs
		-- ex : BeLL poss�de la plage 70.0.0.0 et dans la liste iana.org la designation Bell est remplac�e par : ARIN avec status ALLOCATED
		-- ex : Videotron poss�de la plage 24.0.0.0 et 216.0.0.0 et sont remplac�s dans la liste par : ARIN avec status ALLOCATED
		-- Pour le tp nous allons inserer ces r�seaux dans notre la table des LIRs avec le prefix comme nom
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- SCRIPTS EFFACER LES DONN�ES DES TABLES si besoin
DELETE FROM registraire_r�gional;
DELETE FROM registraire_local;
DELETE FROM propri�taire_priv�;
DELETE FROM R�seau;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- SCRIPT Remplir Les registraires Regionals ( plus facile d'extraire avec status ALLOCATED )
INSERT INTO Registraire_r�gional (nom_rir, adresse_whois)
	SELECT 	LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) AS nom, -- Nom du RIR
			MIN(REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)*]+')) AS web -- Ne garder que le premier website 
		FROM IANA
		WHERE status IN ('ALLOCATED')
		GROUP BY designation;
-- resultat :(doit donner un r�sultat de 5 registraires r�gionals) 
---------------------------------------------------------------------------------------------------	



---------------------------------------------------------------------------------------------------	
-- SCRIPT Remplir Les registraires Locals 
-- (Les noms des registraires locals ne sont pas donn�s dans la lite d'IANA et sont remplac�s par nomRIR)
-- Dans la table IPWHOIS vont �tre remplac�s par leurs prefix (ex : 200/8)
INSERT INTO Registraire_local (nom_lir, reg_r�gional_nom, site_web, date_enregistrement)
    SELECT 	prefix_iana ,
			REGEXP_SUBSTR(whois_iana, '[^whois\.]+[[:alnum:]]+') ,
			REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)|(/)+]+[^(http:)]') , -- Ne garder que le premier website
			TO_DATE(date_iana)
		FROM IANA
		WHERE status IN ('ALLOCATED') 
			AND LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) IN (SELECT DISTINCT nom_rir FROM Registraire_r�gional);
---------------------------------------------------------------------------------------------------	

	
	
---------------------------------------------------------------------------------------------------	
-- SCRIPT Remplir table des propri�taires priv�s
INSERT INTO Propri�taire_priv� (nom_pir, site_web)    
	SELECT designation, 
        MIN(REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)|(/)+]+[^(http:)]')) AS website  -- Ne garder que le premier website
		FROM IANA
		WHERE status IN ('LEGACY')
		GROUP BY designation;
---------------------------------------------------------------------------------------------------	



---------------------------------------------------------------------------------------------------
-- SCRIPT Remplir table R�seau
-- 1. Ins�rer les r�seaux qui appartiennent � des RIRs
INSERT INTO R�seau (d�but_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_r�seau, 
					nombre_bits, 
					reg_regional_nom)	-- (TO_NUMBER())permet d'enlever les zeros successifs 
	SELECT CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0') AS ip_depart,	
			CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.255.255.255') AS ip_fin,
			'A',
			designation, 
			8, 
			LOWER(REGEXP_SUBSTR(whois_iana, '[^whois\.]+[[:alnum:]]+'))
		FROM IANA
		WHERE status IN ('ALLOCATED');
		
	
-- 2. Ins�rer les r�seaux qui appartiennent � des LIRs 
-- les noms des LIRs vont etre remplac�s par leur prefix. (Les vrais noms des LIRs ne sont pas pr�sents dans les lists de IANA)
INSERT INTO R�seau (d�but_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_r�seau, 
					nombre_bits, 
					reg_local_nom,
					reg_regional_nom)    
	SELECT CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0') AS ip_depart,	
			CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.255.255.255') AS ip_fin,
			'A',
			designation, 
			8, 
			prefix_iana,
			LOWER(REGEXP_SUBSTR(whois_iana, '[^whois\.]+[[:alnum:]]+'))
		FROM IANA
		WHERE status IN ('ALLOCATED') 
			AND LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) IN (SELECT DISTINCT nom_rir FROM Registraire_r�gional);
    
	
-- 3. Ins�rer les r�seaux qui ont appartiennent � des PIRs
INSERT INTO R�seau (d�but_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_r�seau, 
					nombre_bits, 
					prop_priv�_nom,
					reg_regional_nom)    
	SELECT CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0') AS ip_depart,	
			CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.255.255.255') AS ip_fin,
			'A',
			designation, 
			8, 
			designation,
			LOWER(REGEXP_SUBSTR(whois_iana, '[^whois\.]+[[:alnum:]]+'))
		FROM IANA
		WHERE status IN ('LEGACY') AND NOT REGEXP_LIKE(designation, '^(Administered by )[[:alnum:]]+');
    
	
-- 4. Ins�rer les r�seaux qui sont reserv�s
INSERT INTO R�seau (d�but_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_r�seau, 
					nombre_bits)    
	SELECT CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0') AS ip_depart,	
			CONCAT(TO_NUMBER(REGEXP_SUBSTR(prefix_iana, '[[:digit:]]+[^/]')), '.255.255.255') AS ip_fin,
			'A',
			designation, 
			8
		FROM IANA
		WHERE status IN ('RESERVED');
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- SCRIPT remplir �tat_iana
INSERT INTO �tat_iana (
            date_etat,
			�tat,
            utilisation,
			r�seau_id_r�seau)
	SELECT TO_DATE(date_iana),
		   status,
		   designation,
		   R�seau.id_r�seau
		FROM IANA
		INNER JOIN R�seau ON R�seau.d�but_range_ip = CONCAT(TO_NUMBER(REGEXP_SUBSTR(IANA.prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0');
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Visualiser les donn�es
SELECT * FROM IANA;
SELECT * FROM R�seau;
SELECT * FROM �tat_iana;
SELECT * FROM Registraire_r�gional;
SELECT * FROM Registraire_local;
SELECT * FROM propri�taire_priv�;