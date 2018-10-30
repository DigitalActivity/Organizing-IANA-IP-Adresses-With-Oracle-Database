-- Étape 5 - Données brutes de l’IANA
 

---------------------------------------------------------------------------------------------------
-- Drop IANA if Exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE IANA CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Script de création de la table IANA
CREATE TABLE IANA (
  prefix_iana VARCHAR2(12),
  designation VARCHAR2(200),
  date_iana DATE,
  rdap VARCHAR2(250),
  whois_iana VARCHAR2(180),
  status VARCHAR2(11),
  note VARCHAR2(50)
);
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Déclencheur vérification prefix_iana
CREATE OR REPLACE TRIGGER format_prefix
	BEFORE INSERT OR UPDATE OF prefix_iana ON IANA
	FOR EACH ROW
DECLARE 
	v_prefix VARCHAR2(12);
	prefix_incorrect EXCEPTION;
BEGIN
	SELECT :NEW.prefix_iana INTO v_prefix FROM dual;
	IF NOT REGEXP_LIKE(v_prefix, '^[[:digit:]]+[/][[:digit:]]+$') -- nombres suivis de / suivie de nombres
	THEN RAISE
	prefix_incorrect;
	END IF; 
EXCEPTION
	WHEN prefix_incorrect THEN
	RAISE_APPLICATION_ERROR (-20300, 'prefix format inocorrect');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Fonction valider une date 
CREATE OR REPLACE FUNCTION valider_date(v_date IN VARCHAR2) RETURN NUMBER IS
    v_date1 DATE;
BEGIN
    select to_date(v_date) into v_date1 from dual;
        RETURN 1;
    Exception WHEN Others THEN
        RETURN 0;
END;

-- Déclencheur vérification date_iana
CREATE OR REPLACE TRIGGER verifier_date_iana
	BEFORE INSERT ON IANA
	FOR EACH ROW
DECLARE
	new_date_iana IANA.date_iana%TYPE;
	date_incorrecte EXCEPTION;
BEGIN
	SELECT :new.date_iana INTO new_date_iana FROM dual;
  
	IF valider_date(TO_CHAR(new_date_iana)) = 0 THEN
	RAISE
	date_incorrecte;
	END IF;
  :NEW.date_iana := TO_DATE(TO_CHAR(new_date_iana, 'YYYY-MM-DD'), 'YYYY-MM-DD');
EXCEPTION
	WHEN date_incorrecte THEN
	RAISE_APPLICATION_ERROR (-20300, 'date incorrecte');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- IMPORTER AVEC 
-- Utiliser l'outil SQL developer import tool pour importer les données de ipv4-address-space.csv
-- Clik droit sur la base des données IANA -> Import Data -> choisir le fichier -> cocher la case Header -> spécifier les colonnes
-- Colonne date_iana dans ipv4-address-space.csv est sous format YYYY-MM (il faut le specifier pendant l'importation). 
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Bloc de code anonyme PL/SQL permettant de vérifier les valeurs utilisées :
-- 1. lister toutes les valeurs pour les propriétaires de réseau pour détecter des éventuelles erreurs d’écritures.
SELECT designation 
	FROM IANA;
-- 2. s’assurer que les dates sont avant aujourd’hui.
SELECT COUNT(date_iana) 
	FROM IANA
	WHERE date_iana > CURRENT_DATE; -- Le resultat doit donner 0, si toutes les dates importée sont avant aujourdhui


