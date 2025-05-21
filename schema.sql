/* CREATION base de donné tifosi */
CREATE DATABASE tifosi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tifosi;
/* CREATION utilisateur */
CREATE USER 'tifosi'@'%' IDENTIFIED BY 'tifosi0000';
GRANT ALL PRIVILEGES ON tifosi.* TO 'tifosi'@'%';
FLUSH PRIVILEGES;


/*-------------------------------------------------------------*/

/* TABLES */

/*TABLES structure temporaire focaccia*/
CREATE TABLE extract_focaccia (
    id_focaccia INT,
    nom_focaccia VARCHAR(255),
    prix_focaccia DECIMAL(5, 2),
    nom_ingrédient TEXT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
/*TABLES structure temporaire ingrédient*/
CREATE TABLE temp_ingrédient (
    id_ingrédient INT DEFAULT NULL,
    nom_ingrédient VARCHAR(255) NOT NULL,
    quantité INT NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
/*TABLES structure temporaire boisson*/
CREATE TABLE temp_boisson (
    id_boisson INT,
    nom_boisson VARCHAR(255),
    id_marque INT,
    nom_marque VARCHAR(255)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

/*-------------------------------------------------------------*/

/*TABLES temporaire organisations données focaccia*/
CREATE TABLE temporary_focaccia (
    id_focaccia INT,
    id_ingrédient INT,
    nom_ingrédient VARCHAR(255)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

/*--------------------------------------------------------------*/

/*TABLES principal*/
CREATE TABLE ingrédient (
    id_ingrédient INT PRIMARY KEY AUTO_INCREMENT,
    nom_ingrédient VARCHAR(255) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE focaccia (
    id_focaccia INT PRIMARY KEY AUTO_INCREMENT,
    nom_focaccia VARCHAR(255),
    prix_focaccia DECIMAL(5, 2),
    nom_ingrédient TEXT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE boisson (
    id_boisson INT PRIMARY KEY AUTO_INCREMENT,
    nom_boisson VARCHAR(255) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE marque (
    id_marque INT PRIMARY KEY AUTO_INCREMENT,
    nom_marque VARCHAR(255) NOT NULL UNIQUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE menu (
    id_menu INT PRIMARY KEY AUTO_INCREMENT,
    nom_menu VARCHAR(255) NOT NULL DEFAULT 'a définir',
    prix_menu DECIMAL(5, 2) NOT NULL DEFAULT 0.00
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE client (
    id_client INT AUTO_INCREMENT,
    nom_client VARCHAR(255) NOT NULL,
    email_client VARCHAR(255) NOT NULL UNIQUE,
    code_postal_client VARCHAR(20) NOT NULL,
    PRIMARY KEY (
        id_client,
        nom_client,
        email_client,
        code_postal_client
    )
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

/*TABLES de liason*/

CREATE TABLE comprend (
    id_focaccia INT,
    id_ingrédient INT,
    quantité INT DEFAULT NULL,
    PRIMARY KEY (id_focaccia, id_ingrédient),
    FOREIGN KEY (id_focaccia) REFERENCES focaccia (id_focaccia) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrédient) REFERENCES ingrédient (id_ingrédient) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE appartient (
    id_marque INT NOT NULL,
    id_boisson INT NOT NULL,
    PRIMARY KEY (id_marque, id_boisson),
    FOREIGN KEY (id_boisson) REFERENCES boisson (id_boisson) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_marque) REFERENCES marque (id_marque) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE estconstitué (
    id_menu INT PRIMARY KEY,
    id_focaccia INT,
    FOREIGN KEY (id_menu) REFERENCES menu (id_menu) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_focaccia) REFERENCES focaccia (id_focaccia) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE contient (
    id_menu INT PRIMARY KEY,
    id_boisson INT,
    FOREIGN KEY (id_menu) REFERENCES menu (id_menu) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_boisson) REFERENCES boisson (id_boisson) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE achete (
    id_client INT,
    id_menu INT,
    date_achat DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_client, date_achat),
    FOREIGN KEY (id_client) REFERENCES client (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_menu) REFERENCES menu (id_menu) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


