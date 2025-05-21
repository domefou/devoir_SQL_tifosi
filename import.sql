/*INSERTION des données tifosi*/

LOAD DATA INFILE 'data_tifosi/csv/focaccia.csv' INTO
TABLE extract_focaccia 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES (id_focaccia,nom_focaccia,prix_focaccia,nom_ingrédient);

LOAD DATA INFILE 'data_tifosi/csv/focaccia.csv' INTO
TABLE temp_ingrédient 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ':' 
ENCLOSED BY '' 
LINES TERMINATED BY '\n' 
IGNORE 12 LINES (@nom_ingrédient, quantité)
SET nom_ingrédient = SUBSTR(@nom_ingrédient, 4);

LOAD DATA INFILE 'data_tifosi/csv/boisson.csv' INTO
TABLE temp_boisson 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES (id_boisson, nom_boisson, id_marque, nom_marque);

/*MANIPULATION des données TABLE "principal" aprés insertion*/

/*DATA ingrédient*/
INSERT INTO ingrédient (nom_ingrédient)
SELECT nom_ingrédient
FROM temp_ingrédient;

/*DATA focaccia*/
INSERT INTO focaccia (nom_focaccia, prix_focaccia, nom_ingrédient)
SELECT
    nom_focaccia,
    prix_focaccia,
    nom_ingrédient
FROM extract_focaccia
LIMIT 8;

/*DATA TABLE temporaire temp_focaccia*/
WITH RECURSIVE séquence AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM séquence
    WHERE n <= (SELECT MAX(LENGTH(nom_ingrédient) - LENGTH(REPLACE (nom_ingrédient, ',', '')) + 1) FROM focaccia)
)
    SELECT f.id_focaccia, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.nom_ingrédient, ',', séquence.n), ',', -1)) AS nom_ingrédient FROM focaccia f
    JOIN séquence ON séquence.n <= LENGTH(f.nom_ingrédient) - LENGTH(REPLACE (f.nom_ingrédient, ',', '')) + 1;

INSERT INTO temporary_focaccia (id_focaccia, nom_ingrédient)
    WITH RECURSIVE séquence AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM séquence
    WHERE n <= (SELECT MAX(LENGTH(nom_ingrédient) - LENGTH(REPLACE (nom_ingrédient, ',', '')) + 1)FROM focaccia)
)
    SELECT f.id_focaccia, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(f.nom_ingrédient, ',', séquence.n), ',', -1)) AS nom_ingrédient FROM focaccia f
    JOIN séquence ON séquence.n <= LENGTH(f.nom_ingrédient) - LENGTH(REPLACE (f.nom_ingrédient, ',', '')) + 1;


/*----------------------------------------------------------*/
/* mettre a jour et effacer les caractéres invisible des data insérés*/
UPDATE temporary_focaccia
SET nom_ingrédient = TRIM(REPLACE (REPLACE (nom_ingrédient, '\n', ''),'\r',''));

UPDATE ingrédient
SET nom_ingrédient = TRIM(REPLACE (REPLACE (nom_ingrédient, '\n', ''),'\r',''));

UPDATE temp_ingrédient
SET nom_ingrédient = TRIM(REPLACE (REPLACE (nom_ingrédient, '\n', ''),'\r',''));

ALTER TABLE ingrédient AUTO_INCREMENT = 25;

/*DATA TABLE temporaire temp_ingrédient*/
INSERT INTO temp_ingrédient (nom_ingrédient)
SELECT DISTINCT fd.nom_ingrédient
FROM temporary_focaccia fd
WHERE
NOT EXISTS (
    SELECT 1 
    FROM temp_ingrédient i 
    WHERE i.nom_ingrédient = fd.nom_ingrédient
    );


UPDATE temp_ingrédient
SET quantité = SUBSTRING_INDEX(SUBSTRING_INDEX(nom_ingrédient, '(', -1),')',1)
WHERE nom_ingrédient LIKE '%(%';




/*DATA ingrédient*/
INSERT INTO ingrédient (nom_ingrédient)
SELECT DISTINCT fd.nom_ingrédient
FROM temp_ingrédient fd
WHERE
NOT EXISTS (
    SELECT 1 
    FROM ingrédient i 
    WHERE i.nom_ingrédient = fd.nom_ingrédient
    );

/*------------------------------------------------------------*/
/*UPDATE SPECIFIQUE */

UPDATE temp_ingrédient
SET id_ingrédient = (
    SELECT DISTINCT i.id_ingrédient
    FROM ingrédient i
    WHERE i.nom_ingrédient = temp_ingrédient.nom_ingrédient
    LIMIT 1
)
WHERE nom_ingrédient IN (
    SELECT DISTINCT nom_ingrédient
    FROM ingrédient
);

UPDATE temporary_focaccia
SET id_ingrédient = (
    SELECT DISTINCT i.id_ingrédient
    FROM ingrédient i
    WHERE i.nom_ingrédient = temporary_focaccia.nom_ingrédient
    LIMIT 1
)
WHERE nom_ingrédient IN (
    SELECT DISTINCT nom_ingrédient
    FROM ingrédient
);





/*DATA boisson*/
INSERT INTO boisson (id_boisson, nom_boisson)
SELECT tb.id_boisson, tb.nom_boisson
FROM temp_boisson tb;

/*DATA marque*/
INSERT INTO marque (nom_marque)
SELECT DISTINCT nom_marque
FROM temp_boisson
WHERE nom_marque IS NOT NULL;

ALTER TABLE marque AUTO_INCREMENT = 5;

/*--------------------------------------------------------------*/
/*UPDATE SPECIFIQUE*/
UPDATE temp_boisson tb
JOIN marque m ON tb.nom_marque = m.nom_marque
SET tb.id_marque = m.id_marque;
/*-------------------------------------------------------------*/

/*MANIPULATION des données TABLE "intérmédiaire aprés insertion*/

/*DATA comprend*/


INSERT INTO comprend (id_focaccia, id_ingrédient, quantité)
SELECT tf.id_focaccia, tf.id_ingrédient, ti.quantité
FROM temporary_focaccia tf
JOIN temp_ingrédient ti ON tf.id_ingrédient = ti.id_ingrédient;




/*DATA appartient*/
INSERT INTO appartient (id_boisson, id_marque)
SELECT b.id_boisson, m.id_marque
FROM temp_boisson tb
JOIN boisson b ON tb.nom_boisson = b.nom_boisson
JOIN marque m ON tb.nom_marque = m.nom_marque;

/*DATA estconstitué*/
INSERT INTO estconstitué (id_menu, id_focaccia)
SELECT m.id_menu, f.id_focaccia
FROM menu m
CROSS JOIN focaccia f;

/*DATA contient*/
INSERT INTO contient (id_menu, id_boisson)
SELECT m.id_menu, b.id_boisson
FROM menu m
CROSS JOIN boisson b;


/*DROP colonne*/
ALTER TABLE focaccia DROP COLUMN nom_ingrédient;

UPDATE ingrédient
SET nom_ingrédient = SUBSTRING_INDEX(nom_ingrédient, '(', 1)
WHERE nom_ingrédient LIKE '%(%';

/*DROP TABLE temporaire*/
DROP TABLE `tifosi`.`extract_focaccia`;

DROP TABLE `tifosi`.`temporary_focaccia`;

DROP TABLE `tifosi`.`temp_ingrédient`;

DROP TABLE `tifosi`.`temp_boisson`;

/*--------------------------------------------------------*/
/*CREATION des TRIGGERS*/

/*mettre a jour la table "comprend" aprés suppression d'ingrédient de la table "ingrédient".*/
CREATE TRIGGER supprimer_comprend_apres_ingrédient
    AFTER DELETE ON ingrédient
    FOR EACH ROW
    DELETE FROM comprend 
    WHERE id_ingrédient = OLD.id_ingrédient;

/*mettre a jour la table "boisson" aprés suppression de marque de la table "marque".*/
CREATE TRIGGER supprimer_boisson_apres_marque
AFTER DELETE ON marque
FOR EACH ROW
DELETE FROM boisson 
WHERE id_boisson IN ( 
    SELECT id_boisson 
    FROM appartient 
    WHERE id_marque = OLD.id_marque
    );

/*calcule automatisé des prix de la table menu apres ajout d'article depuis "estconstitué" et "contient".*/
CREATE TRIGGER maj_prix_menu_apres_focaccia
AFTER INSERT ON estconstitué
FOR EACH ROW
UPDATE menu
SET prix_menu = (
    SELECT COALESCE(SUM(f.prix_focaccia), 0)
    FROM focaccia f
    JOIN estconstitué e ON f.id_focaccia = e.id_focaccia
    WHERE e.id_menu = NEW.id_menu
    )
WHERE id_menu = NEW.id_menu;

/*ajout du prix de boisson = 2.50 au total du prix de menu de la table menu*/
CREATE TRIGGER ajouter_prix_boisson
    AFTER INSERT ON contient
    FOR EACH ROW
    UPDATE menu
    SET prix_menu = prix_menu + 2.50
    WHERE id_menu = NEW.id_menu;



