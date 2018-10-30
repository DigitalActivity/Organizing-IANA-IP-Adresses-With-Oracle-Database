-- Szbechek Mc Gurk & Younes Rabdi
-- Étape 2 – Création des tables de la base de données test IPWHOIS


---------------------------------------------------------------------------------------------------
-- Script pour detruire la table Registraire_régional si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Registraire_régional CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Créer Registraire régional Table
CREATE TABLE Registraire_régional
  (
    nom_rir           VARCHAR2(60) NOT NULL ,
    adresse_whois     VARCHAR2(180) ,
    nombre_ip_alloué  NUMBER(12) ,
    nombre_ip_assigné NUMBER(12) ,
	
	CONSTRAINT registraire_régional_pk PRIMARY KEY ( nom_rir )
  );
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Script pour detruire la table Registraire_local si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Registraire_local CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Créer Registraire local Table
CREATE TABLE Registraire_local
  (
    nom_lir             VARCHAR2(60) NOT NULL ,
    site_web            VARCHAR2(180) ,
    date_enregistrement DATE ,
    reg_régional_nom    VARCHAR2(60) NOT NULL,
	
	CONSTRAINT registraire_local_pk PRIMARY KEY ( nom_lir ),
	
	CONSTRAINT reg_local_reg_regional_fk 
		FOREIGN KEY ( reg_régional_nom ) 
		REFERENCES Registraire_régional ( nom_rir ) 
		ON DELETE CASCADE
  ) ;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Script pour detruire la table Propriétaire_privé si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Propriétaire_privé CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Créer Propriétaire privé Table
CREATE TABLE Propriétaire_privé
  (
    nom_pir       VARCHAR2(100) NOT NULL,
    adresse       VARCHAR2(180),
    site_web      VARCHAR2(180),
    reg_local_nom VARCHAR2(60),
	sous_proprio_pir VARCHAR2(180) ,
	
	CONSTRAINT prop_privé_pk PRIMARY KEY ( nom_pir ),
	
	CONSTRAINT prop_privé_reg_local_fk 
		FOREIGN KEY ( reg_local_nom ) 
		REFERENCES Registraire_local ( nom_lir ) 
		ON DELETE CASCADE
  );
  
  
  
  -- Ajouter la relation réflexive dans la table Propriétaire_privé
  ALTER TABLE Propriétaire_privé ADD CONSTRAINT sprop_privé_id_fk 
	 FOREIGN KEY ( sous_proprio_pir ) 
	 REFERENCES Propriétaire_privé ( nom_pir ) 
	 ON DELETE CASCADE;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- seq auto increment id de a tble Réseau (Étape 3 – Clés primaires )
CREATE SEQUENCE default_réseau_seq
MINVALUE 100
START WITH 100
INCREMENT BY 1
CACHE 4;


-- Script pour detruire la table Réseau si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Réseau CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Creer Table Réseau 
CREATE TABLE Réseau
  (
    id_réseau        NUMBER(10) NOT NULL ,
    ip		         VARCHAR2(60) GENERATED ALWAYS AS ( Trim(BOTH ' ' FROM début_range_ip) ) VIRTUAL ,  -- trim est là just pour avoir une expression
    nombre_bits      NUMBER(5) ,
    début_range_ip 	 VARCHAR2(60) NOT NULL ,
    fin_range_ip   	 VARCHAR2(60) NOT NULL ,
	nombre_adresses  NUMBER(9) GENERATED ALWAYS AS (POWER(2, (32-nombre_bits))) VIRTUAL, 
    classe_cidr      VARCHAR2(3) NOT NULL ,
    nom_réseau       VARCHAR2(80) NOT NULL ,
    reg_regional_nom VARCHAR2(60) ,
    reg_local_nom    VARCHAR2(60) ,
    prop_privé_nom   VARCHAR2(160) ,
    sous_réseau_id_réseau INTEGER ,
	
	CONSTRAINT réseau_pk PRIMARY KEY(id_réseau),
	
	CONSTRAINT réseau_reg_regional_fk 
		FOREIGN KEY ( reg_regional_nom ) 
		REFERENCES Registraire_régional ( nom_rir )
		ON DELETE CASCADE,
		
	CONSTRAINT réseau_reg_local_fk 
		FOREIGN KEY ( reg_local_nom ) 
		REFERENCES Registraire_local ( nom_lir )
		ON DELETE CASCADE,
		
	CONSTRAINT réseau_prop_privé_fk 
		FOREIGN KEY ( prop_privé_nom ) 
		REFERENCES Propriétaire_privé ( nom_pir )
		ON DELETE CASCADE, 
		
	CONSTRAINT début_ip_cck check (REGEXP_LIKE(début_range_ip, '^(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')),
	
	CONSTRAINT fin_ip_cck check (REGEXP_LIKE(fin_range_ip, '^(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')),
	
	CONSTRAINT nombre_bits_cck check (nombre_bits >= 0)
	
  ) ;
  
  
  
-- Ajouter la relation réflexive dans la table Réseau
ALTER TABLE Réseau ADD CONSTRAINT réseau_sous_réseau_fk 
	FOREIGN KEY ( sous_réseau_id_réseau ) 
	REFERENCES Réseau ( id_réseau ) 
	ON DELETE CASCADE;
	
	
	
-- Trigger : insertion id automatique dans la table Réseau (Étape 3 – Clés primaires )
CREATE OR REPLACE TRIGGER insertion_réseau
	BEFORE INSERT ON Réseau
	FOR EACH ROW
DECLARE
	new_no_réseau Réseau.id_réseau%TYPE; -- type basé sur colonne
BEGIN
	SELECT default_réseau_seq.NextVal INTO new_no_réseau
	FROM dual;
	:new.id_réseau := new_no_réseau;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	dbms_output.put_line ('La requête n''a retourné aucune valeur.');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------		
-- Script pour detruire la table État_IANA si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE État_IANA CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- creer IANA Table
CREATE TABLE État_IANA
  (
    date_etat        DATE ,
    état             VARCHAR2(20) ,
    utilisation      VARCHAR2(180) ,
    réseau_id_réseau INTEGER NOT NULL ,
	
	CONSTRAINT état_pk PRIMARY KEY ( réseau_id_réseau ),
	
	CONSTRAINT État_iana_état_cck CHECK (UPPER(état) IN ('ALLOCATED', 'LEGACY', 'RESERVED', 'UNALLOCATED')),
	
	CONSTRAINT état_réseau_fk 
		FOREIGN KEY ( réseau_id_réseau ) 
		REFERENCES Réseau ( id_réseau ) 
		ON DELETE CASCADE
  );
---------------------------------------------------------------------------------------------------

  
