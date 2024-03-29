-- DROP TABLES

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_personnes_morales';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_qualifications';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_collaborateurs';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_mandats';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Realisations CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Mandats CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Collaborateurs CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Qualifications CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PersonnesMorales CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- PersonnesMorales 
CREATE SEQUENCE seq_personnes_morales;

CREATE TABLE PersonnesMorales (
    numero NUMBER(10) DEFAULT seq_personnes_morales.NEXTVAL
        CONSTRAINT pk_personnes_morales PRIMARY KEY,
    raisonSociale VARCHAR2(30) 
		CONSTRAINT nn_personnes_morales_raisonSociale NOT NULL,
    rueNumero VARCHAR2(50) 
		CONSTRAINT nn_personnes_morales_rueNumero NOT NULL,
    codePostal CHAR(4) 
		CONSTRAINT nn_personnes_morales_codePostal NOT NULL,
    localite VARCHAR2(100) 
		CONSTRAINT nn_personnes_morales_localite NOT NULL
);

-- Création du check pour le type 'word' du code postal
ALTER TABLE PersonnesMorales ADD CONSTRAINT ch_personnesmorales_codepostal CHECK (REGEXP_LIKE(codePostal, '^[A-Za-z0-9]{4}$'));

-- Qualifications
CREATE SEQUENCE seq_qualifications;
 
CREATE TABLE Qualifications (
    numero NUMBER(10) DEFAULT seq_qualifications.NEXTVAL
        CONSTRAINT pk_qualifications PRIMARY KEY,
    libelle VARCHAR2(20) CONSTRAINT nn_qualifications_libelle NOT NULL
        CONSTRAINT uk_qualifications_libelle UNIQUE,
    tarifHoraire NUMBER(3) CONSTRAINT nn_qualifications_tarifHoraire NOT NULL
        CONSTRAINT ch_qualifications_tarifHoraire CHECK (tarifHoraire > 0)
);

-- Collaborateurs
CREATE SEQUENCE seq_collaborateurs;

CREATE TABLE Collaborateurs (
    numero NUMBER(10) DEFAULT seq_collaborateurs.NEXTVAL
        CONSTRAINT pk_collaborateurs PRIMARY KEY,
    mnemo VARCHAR2(4) 
		CONSTRAINT uk_collaborateurs_mnemo UNIQUE,
    nom VARCHAR2(40) 
		CONSTRAINT nn_collaborateurs_nom NOT NULL,
    prenom VARCHAR2(20) 
		CONSTRAINT nn_collaborateurs_prenom NOT NULL,
    qual_concerner_numero NUMBER(10)
        CONSTRAINT nn_collaborateurs_qualconcernernumero NOT NULL
);

ALTER TABLE Collaborateurs
ADD CONSTRAINT fk_qualifications_collaborateurs FOREIGN KEY (qual_concerner_numero)
REFERENCES Qualifications(numero)
;

-- Mandats
CREATE SEQUENCE seq_mandats;

CREATE TABLE Mandats (
    numero NUMBER(10) DEFAULT seq_mandats.NEXTVAL
        CONSTRAINT pk_mandats PRIMARY KEY,
    reference CHAR(10) 
        CONSTRAINT unq_mandats_reference UNIQUE NOT NULL,
    description VARCHAR2(30) 
        CONSTRAINT nn_mandats_description NOT NULL,
    dateSignature DATE 
        CONSTRAINT nn_mandats_dateSignature NOT NULL,
    dateDebut DATE 
        CONSTRAINT nn_mandats_dateDebut NOT NULL,
    dateFinPrevue DATE 
        CONSTRAINT nn_mandats_dateFinPrevue NOT NULL,
    dateFinReelle DATE,
    nbHeuresChefProjet INT DEFAULT 0 
        CONSTRAINT ch_mandats_nbHeuresChefProjet CHECK (nbHeuresChefProjet >= 0),
    nbHeuresMandCom INT DEFAULT 0 
        CONSTRAINT ch_mandats_nbHeuresMandCom CHECK (nbHeuresMandCom >= 0),
    pm_client_numero NUMBER(10) NOT NULL,
    col_mandCom_numero NUMBER(10) NOT NULL,
    col_chefProjet_numero NUMBER(10) NOT NULL
);

ALTER TABLE Mandats 
    ADD CONSTRAINT fk_mandats_pm_client_numero FOREIGN KEY (pm_client_numero) 
        REFERENCES PersonnesMorales(numero);
ALTER TABLE Mandats 
    ADD CONSTRAINT fk_mandats_col_mandCom_numero FOREIGN KEY (col_mandCom_numero) 
        REFERENCES Collaborateurs(numero);
ALTER TABLE Mandats 
    ADD CONSTRAINT fk_mandats_col_chefProjet_numero FOREIGN KEY (col_chefProjet_numero) 
        REFERENCES Collaborateurs(numero);


CREATE OR REPLACE TRIGGER trg_prevent_pm_update
BEFORE UPDATE OF pm_client_numero ON Mandats
FOR EACH ROW
BEGIN
    IF :OLD.pm_client_numero IS NOT NULL AND :NEW.pm_client_numero != :OLD.pm_client_numero THEN
        RAISE_APPLICATION_ERROR(-20001, 'Modification de la Personne Morale pour un Mandat existant est interdite.');
    END IF;
END;
/

-- Realisations
CREATE TABLE Realisations (
    mand_numero NUMBER(10) 
        CONSTRAINT nn_real_mand_num NOT NULL,
    col_numero NUMBER(10) 
        CONSTRAINT nn_real_col_num NOT NULL,
    nbHeures NUMBER(10) 
        CONSTRAINT nn_real_nbHeures NOT NULL,

    CONSTRAINT pk_realisations PRIMARY KEY (mand_numero, col_numero),
    CONSTRAINT fk_realisations_mandats 
        FOREIGN KEY (mand_numero) 
            REFERENCES Mandats(numero),
    CONSTRAINT fk_realisations_collaborateurs 
        FOREIGN KEY (col_numero) 
            REFERENCES Collaborateurs(numero)
);

-- Indexes
CREATE INDEX idx_personnesmorales_raisonsociale ON PersonnesMorales(raisonSociale);

-- Optimisation des jointures
CREATE INDEX idx_collaborateurs_qualconcernernumero ON Collaborateurs(qual_concerner_numero);
CREATE INDEX idx_mandats_pmclientnumero ON Mandats(pm_client_numero);
CREATE INDEX idx_mandats_colmandcomnumero ON Mandats(col_mandCom_numero);
CREATE INDEX idx_mandats_colchefprojetnumero ON Mandats(col_chefProjet_numero);
CREATE INDEX idx_realisations_mandnumero ON Realisations(mand_numero);
CREATE INDEX idx_realisations_colnumero ON Realisations(col_numero);
