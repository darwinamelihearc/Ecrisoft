
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

-- Qualifications
CREATE SEQUENCE seq_qualifications ;
 
CREATE TABLE Qualifications (
    numero NUMBER(10) DEFAULT seq_qualifications.NEXTVAL
        CONSTRAINT pk_qualifications PRIMARY KEY,
    libelle VARCHAR2(20) CONSTRAINT nn_qualifications_libelle NOT NULL
        CONSTRAINT uk_qualifications_libelle UNIQUE,
    tarifHoraire NUMBER(3) CONSTRAINT nn_qualifications_tarifHoraire NOT NULL
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
        CONSTRAINT chk_mandats_nbHeuresChefProjet CHECK (nbHeuresChefProjet >= 0),
    nbHeuresMandCom INT DEFAULT 0 
        CONSTRAINT chk_mandats_nbHeuresMandCom CHECK (nbHeuresMandCom >= 0),
    pm_client_numero NUMBER(10) NOT NULL,
    col_mandCom_numero NUMBER(10) NOT NULL,
    col_chefProjet_numero NUMBER(10) NOT NULL
);

ALTER TABLE Mandats
ADD CONSTRAINT fk_mandats_pm_client_numero FOREIGN KEY (pm_client_numero) 
REFERENCES PersonnesMorales(numero),
ADD CONSTRAINT fk_mandats_col_mandCom_numero FOREIGN KEY (col_mandCom_numero) 
REFERENCES Collaborateurs(numero),
ADD CONSTRAINT fk_mandats_col_chefProjet_numero FOREIGN KEY (col_chefProjet_numero) 
REFERENCES Collaborateurs(numero)
;


CREATE TABLE Realisations (
	mand_numero Number(10) 
		CONSTRAINT nn_real_mand_num NOT NULL, 
	col_numero Number(10) 
		CONSTRAINT nn_real_col_num NOT NULL,
	nbHeures Number(10)
		CONSTRAINT nn_real_nbheures NOT NULL,
		CONSTRAINT pk_realisations PRIMARY KEY (mand_numero,col_numero), 
		CONSTRAINT fk_realisations_mandats
	     FOREIGN KEY (mand_numero)
		   REFERENCES medicaments,
	   CONSTRAINT fk_realisations_collaborateurs
	     FOREIGN KEY (col_numero)
		   REFERENCES consultations );	