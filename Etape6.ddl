-- Étape 6 – Chargement de la nouvelle base de données 
--Legende status (www.iana.org): 
	--RESERVED:	designated by the IETF for specific non-global-unicast purposes as noted.
	--LEGACY:	(PIRs/RIRs) allocated by the central Internet Registry (IR) prior to the Regional Internet Registries (RIRs).
	--ALLOCATED:(LIRs) delegated entirely to specific RIR as indicated.
	--UNALLOCATED: not yet allocated or reserved.
	
-- Note :
	-- Dans la liste des adresses sur www.iana.org les noms des LIRs sont remplacés par les noms des RIRs
		-- ex : BeLL possède la plage 70.0.0.0 et dans la liste iana.org la designation Bell est remplacée par : ARIN avec status ALLOCATED
		-- ex : Videotron possède la plage 24.0.0.0 et 216.0.0.0 et sont remplacés dans la liste par : ARIN avec status ALLOCATED
		-- Pour le tp nous allons inserer ces réseaux dans notre la table des LIRs avec le prefix comme nom
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- SCRIPTS EFFACER LES DONNÉES DES TABLES si besoin
DELETE FROM registraire_régional;
DELETE FROM registraire_local;
DELETE FROM propriétaire_privé;
DELETE FROM Réseau;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- SCRIPT Remplir Les registraires Regionals ( plus facile d'extraire avec status ALLOCATED )
INSERT INTO Registraire_régional (nom_rir, adresse_whois)
	SELECT 	LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) AS nom, -- Nom du RIR
			MIN(REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)*]+')) AS web -- Ne garder que le premier website 
		FROM IANA
		WHERE status IN ('ALLOCATED')
		GROUP BY designation;
-- resultat :(doit donner un résultat de 5 registraires régionals) 
---------------------------------------------------------------------------------------------------	



---------------------------------------------------------------------------------------------------	
-- SCRIPT Remplir Les registraires Locals 
-- (Les noms des registraires locals ne sont pas donnés dans la lite d'IANA et sont remplacés par nomRIR)
-- Dans la table IPWHOIS vont être remplacés par leurs prefix (ex : 200/8)
INSERT INTO Registraire_local (nom_lir, reg_régional_nom, site_web, date_enregistrement)
    SELECT 	prefix_iana ,
			REGEXP_SUBSTR(whois_iana, '[^whois\.]+[[:alnum:]]+') ,
			REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)|(/)+]+[^(http:)]') , -- Ne garder que le premier website
			TO_DATE(date_iana)
		FROM IANA
		WHERE status IN ('ALLOCATED') 
			AND LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) IN (SELECT DISTINCT nom_rir FROM Registraire_régional);
---------------------------------------------------------------------------------------------------	

	
	
---------------------------------------------------------------------------------------------------	
-- SCRIPT Remplir table des propriétaires privés
INSERT INTO Propriétaire_privé (nom_pir, site_web)    
	SELECT designation, 
        MIN(REGEXP_SUBSTR(rdap, '[^(https://)|^(http://)]+[[:alnum:]+(\.)|(/)+]+[^(http:)]')) AS website  -- Ne garder que le premier website
		FROM IANA
		WHERE status IN ('LEGACY')
		GROUP BY designation;
---------------------------------------------------------------------------------------------------	



---------------------------------------------------------------------------------------------------
-- SCRIPT Remplir table Réseau
-- 1. Insérer les réseaux qui appartiennent à des RIRs
INSERT INTO Réseau (début_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_réseau, 
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
		
	
-- 2. Insérer les réseaux qui appartiennent à des LIRs 
-- les noms des LIRs vont etre remplacés par leur prefix. (Les vrais noms des LIRs ne sont pas présents dans les lists de IANA)
INSERT INTO Réseau (début_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_réseau, 
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
			AND LOWER(REGEXP_SUBSTR(designation, '^[[:alnum:]]+')) IN (SELECT DISTINCT nom_rir FROM Registraire_régional);
    
	
-- 3. Insérer les réseaux qui ont appartiennent à des PIRs
INSERT INTO Réseau (début_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_réseau, 
					nombre_bits, 
					prop_privé_nom,
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
    
	
-- 4. Insérer les réseaux qui sont reservés
INSERT INTO Réseau (début_range_ip, 
					fin_range_ip, 
					classe_cidr, 
					nom_réseau, 
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
-- SCRIPT remplir état_iana
INSERT INTO état_iana (
            date_etat,
			état,
            utilisation,
			réseau_id_réseau)
	SELECT TO_DATE(date_iana),
		   status,
		   designation,
		   Réseau.id_réseau
		FROM IANA
		INNER JOIN Réseau ON Réseau.début_range_ip = CONCAT(TO_NUMBER(REGEXP_SUBSTR(IANA.prefix_iana, '[[:digit:]]+[^/]')), '.0.0.0');
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Visualiser les données
SELECT * FROM IANA;
SELECT * FROM Réseau;
SELECT * FROM État_iana;
SELECT * FROM Registraire_régional;
SELECT * FROM Registraire_local;
SELECT * FROM propriétaire_privé;