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
 
 
CREATE SEQUENCE seq_qualifications ;
 
CREATE TABLE QUALIFICATIONS (Number NUMBER(10) DEFAULT seq_qualifications.Nextval PRIMARY KEY,
							libelle VARCHAR(20),
							tarifHoraire NUMBER(3));
							
ALTER TABLE qualifications ADD (
	CONSTRAINT nn_qualifications_libelle NOT NULL (libelle),
	CONSTRAINT uk_qualifications_libelle UNIQUE (libelle)
	);							
ALTER TABLE qualifications ADD 
	CONSTRAINT nn_qualifications_tarifHoraire NOT NULL (tarifHoraire);
 
 
CREATE SEQUENCE seq_collaborateurs;

CREATE TABLE Collaborateurs (
    numero NUMBER(10) DEFAULT seq_collaborateurs.NEXTVAL
        CONSTRAINT pk_collaborateurs PRIMARY KEY,
    mnemo VARCHAR2(4)
		CONSTRAINT uk_collaborateurs_mnemo UNIQUE,
	nom VARCHAR2(40) 
        CONSTRAINT nn_collaborateurs_nom NOT NULL,
    prenom VARCHAR2(20)
        CONSTRAINT nn_collaborateurs_prenom NOT NULL
);

ALTER TABLE Collaborateurs
ADD CONSTRAINT fk_qualifications_collaborateurs
FOREIGN KEY (qual_concerner_numero)
REFERENCES Qualifications(numero);
 
 
CREATE SEQUENCE seq_mandats;
CREATE TABLE Mandats (
    numero NUMBER(10) DEFAULT seq_mandats.NEXTVAL
        CONSTRAINT pk_mandats PRIMARY KEY,
    reference CHAR(10) NOT NULL
        CONSTRAINT unq_mandats_reference UNIQUE,
    description VARCHAR2(30) NOT NULL
        CONSTRAINT nn_mandats_description,
    dateSignature DATE NOT NULL
        CONSTRAINT nn_mandats_dateSignature,
    dateDebut DATE NOT NULL
        CONSTRAINT nn_mandats_dateDebut,
    dateFinPrevue DATE NOT NULL
        CONSTRAINT nn_mandats_dateFinPrevue,
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
ADD CONSTRAINT fk_mandats_pm_client_numero FOREIGN KEY (pm_client_numero) REFERENCES PersonnesMorales(numero),
ADD CONSTRAINT fk_mandats_col_mandCom_numero FOREIGN KEY (col_mandCom_numero) REFERENCES Collaborateurs(numero),
ADD CONSTRAINT fk_mandats_col_chefProjet_numero FOREIGN KEY (col_chefProjet_numero) REFERENCES Collaborateurs(numero);
 
 
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