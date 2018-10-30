-- Szbechek Mc Gurk & Younes Rabdi
-- �tape 2 � Cr�ation des tables de la base de donn�es test IPWHOIS


---------------------------------------------------------------------------------------------------
-- Script pour detruire la table Registraire_r�gional si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Registraire_r�gional CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Cr�er Registraire r�gional Table
CREATE TABLE Registraire_r�gional
  (
    nom_rir           VARCHAR2(60) NOT NULL ,
    adresse_whois     VARCHAR2(180) ,
    nombre_ip_allou�  NUMBER(12) ,
    nombre_ip_assign� NUMBER(12) ,
	
	CONSTRAINT registraire_r�gional_pk PRIMARY KEY ( nom_rir )
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
-- Cr�er Registraire local Table
CREATE TABLE Registraire_local
  (
    nom_lir             VARCHAR2(60) NOT NULL ,
    site_web            VARCHAR2(180) ,
    date_enregistrement DATE ,
    reg_r�gional_nom    VARCHAR2(60) NOT NULL,
	
	CONSTRAINT registraire_local_pk PRIMARY KEY ( nom_lir ),
	
	CONSTRAINT reg_local_reg_regional_fk 
		FOREIGN KEY ( reg_r�gional_nom ) 
		REFERENCES Registraire_r�gional ( nom_rir ) 
		ON DELETE CASCADE
  ) ;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- Script pour detruire la table Propri�taire_priv� si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Propri�taire_priv� CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Cr�er Propri�taire priv� Table
CREATE TABLE Propri�taire_priv�
  (
    nom_pir       VARCHAR2(100) NOT NULL,
    adresse       VARCHAR2(180),
    site_web      VARCHAR2(180),
    reg_local_nom VARCHAR2(60),
	sous_proprio_pir VARCHAR2(180) ,
	
	CONSTRAINT prop_priv�_pk PRIMARY KEY ( nom_pir ),
	
	CONSTRAINT prop_priv�_reg_local_fk 
		FOREIGN KEY ( reg_local_nom ) 
		REFERENCES Registraire_local ( nom_lir ) 
		ON DELETE CASCADE
  );
  
  
  
  -- Ajouter la relation r�flexive dans la table Propri�taire_priv�
  ALTER TABLE Propri�taire_priv� ADD CONSTRAINT sprop_priv�_id_fk 
	 FOREIGN KEY ( sous_proprio_pir ) 
	 REFERENCES Propri�taire_priv� ( nom_pir ) 
	 ON DELETE CASCADE;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
-- seq auto increment id de a tble R�seau (�tape 3 � Cl�s primaires )
CREATE SEQUENCE default_r�seau_seq
MINVALUE 100
START WITH 100
INCREMENT BY 1
CACHE 4;


-- Script pour detruire la table R�seau si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE R�seau CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- Creer Table R�seau 
CREATE TABLE R�seau
  (
    id_r�seau        NUMBER(10) NOT NULL ,
    ip		         VARCHAR2(60) GENERATED ALWAYS AS ( Trim(BOTH ' ' FROM d�but_range_ip) ) VIRTUAL ,  -- trim est l� just pour avoir une expression
    nombre_bits      NUMBER(5) ,
    d�but_range_ip 	 VARCHAR2(60) NOT NULL ,
    fin_range_ip   	 VARCHAR2(60) NOT NULL ,
	nombre_adresses  NUMBER(9) GENERATED ALWAYS AS (POWER(2, (32-nombre_bits))) VIRTUAL, 
    classe_cidr      VARCHAR2(3) NOT NULL ,
    nom_r�seau       VARCHAR2(80) NOT NULL ,
    reg_regional_nom VARCHAR2(60) ,
    reg_local_nom    VARCHAR2(60) ,
    prop_priv�_nom   VARCHAR2(160) ,
    sous_r�seau_id_r�seau INTEGER ,
	
	CONSTRAINT r�seau_pk PRIMARY KEY(id_r�seau),
	
	CONSTRAINT r�seau_reg_regional_fk 
		FOREIGN KEY ( reg_regional_nom ) 
		REFERENCES Registraire_r�gional ( nom_rir )
		ON DELETE CASCADE,
		
	CONSTRAINT r�seau_reg_local_fk 
		FOREIGN KEY ( reg_local_nom ) 
		REFERENCES Registraire_local ( nom_lir )
		ON DELETE CASCADE,
		
	CONSTRAINT r�seau_prop_priv�_fk 
		FOREIGN KEY ( prop_priv�_nom ) 
		REFERENCES Propri�taire_priv� ( nom_pir )
		ON DELETE CASCADE, 
		
	CONSTRAINT d�but_ip_cck check (REGEXP_LIKE(d�but_range_ip, '^(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')),
	
	CONSTRAINT fin_ip_cck check (REGEXP_LIKE(fin_range_ip, '^(([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1}|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$')),
	
	CONSTRAINT nombre_bits_cck check (nombre_bits >= 0)
	
  ) ;
  
  
  
-- Ajouter la relation r�flexive dans la table R�seau
ALTER TABLE R�seau ADD CONSTRAINT r�seau_sous_r�seau_fk 
	FOREIGN KEY ( sous_r�seau_id_r�seau ) 
	REFERENCES R�seau ( id_r�seau ) 
	ON DELETE CASCADE;
	
	
	
-- Trigger : insertion id automatique dans la table R�seau (�tape 3 � Cl�s primaires )
CREATE OR REPLACE TRIGGER insertion_r�seau
	BEFORE INSERT ON R�seau
	FOR EACH ROW
DECLARE
	new_no_r�seau R�seau.id_r�seau%TYPE; -- type bas� sur colonne
BEGIN
	SELECT default_r�seau_seq.NextVal INTO new_no_r�seau
	FROM dual;
	:new.id_r�seau := new_no_r�seau;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	dbms_output.put_line ('La requ�te n''a retourn� aucune valeur.');
END;
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------		
-- Script pour detruire la table �tat_IANA si existe
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE �tat_IANA CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/
-- creer IANA Table
CREATE TABLE �tat_IANA
  (
    date_etat        DATE ,
    �tat             VARCHAR2(20) ,
    utilisation      VARCHAR2(180) ,
    r�seau_id_r�seau INTEGER NOT NULL ,
	
	CONSTRAINT �tat_pk PRIMARY KEY ( r�seau_id_r�seau ),
	
	CONSTRAINT �tat_iana_�tat_cck CHECK (UPPER(�tat) IN ('ALLOCATED', 'LEGACY', 'RESERVED', 'UNALLOCATED')),
	
	CONSTRAINT �tat_r�seau_fk 
		FOREIGN KEY ( r�seau_id_r�seau ) 
		REFERENCES R�seau ( id_r�seau ) 
		ON DELETE CASCADE
  );
---------------------------------------------------------------------------------------------------

  
