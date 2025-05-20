/*selectionner quel article on ete commander dans le menu "5"
SELECT m.id_menu, e.id_focaccia, c.id_boisson
FROM menu m
LEFT JOIN estconstitué e ON m.id_menu = e.id_menu
LEFT JOIN contient c ON m.id_menu = c.id_menu
WHERE m.id_menu = 1 -- Remplace `1` par l'id_menu souhaité
GROUP BY m.id_menu, e.id_focaccia, c.id_boisson;

SELECT m.id_menu, f.nom_focaccia, b.nom_boisson
FROM menu m
LEFT JOIN estconstitué e ON m.id_menu = e.id_menu
LEFT JOIN focaccia f ON e.id_focaccia = f.id_focaccia
LEFT JOIN contient c ON m.id_menu = c.id_menu
LEFT JOIN boisson b ON c.id_boisson = b.id_boisson
WHERE m.id_menu = 1 -- Remplace `1` par l'id_menu souhaité
GROUP BY m.id_menu, f.nom_focaccia, b.nom_boisson;

USE tifosi;
SHOW TABLES;



--1. Afficher la liste des noms des focaccias par ordre alphabétique croissant.
SELECT nom_focaccia
FROM focaccia
ORDER BY nom_focaccia ASC;

--Le résultat attendu :
Américaine,Emmentalaccia,Gorgonzolaccia,Hawaienne,Mozaccia,Paysanne,Raclaccia,Tradizione
--Le résultat obtenu :
méricaine,Emmentalaccia,Gorgonzolaccia,Hawaienne,Mozaccia,Paysanne,Raclaccia,Tradizione

--2. Afficher le nombre total d'ingrédients.
SELECT COUNT(DISTINCT nom_ingrédient) AS total_ingrédients
FROM ingrédient;


--Le résultat attendu : 
25
--Le résultat obtenu :
25

--3. Afficher le prix moyen des focaccias.
SELECT AVG(prix_focaccia) AS prix_moyen
FROM focaccia;

--Le résultat attendu :
10.375
--Le résultat obtenu :
10.375

--4. Afficher la liste des boissons avec leur marque, triée par nom de boisson.
SELECT b.nom_boisson, m.nom_marque
FROM appartient
JOIN boisson b ON appartient.id_boisson = b.id_boisson
JOIN marque m ON appartient.id_marque = m.id_marque
ORDER BY b.nom_boisson ASC;


--Le résultat attendu :
Capri-sun : Coca-Cola
Coca-Cola original : Coca-Cola
Coca-Cola zéro : Coca-Cola
Eau de source : Cristalline
Fanta citron : Coca-Cola
Fanta orange : Coca-Cola
Lipton peach : Pepsico
Lipton zéro citron : Pepsico
Monster energy ultra blue : Monster
Monster energy ultra gold : Monster
Pepsi : Pepsico
Pepsi Max zéro : Pepsico
--Le résultat obtenu :
Capri-sun : Coca-Cola
Coca-Cola original : Coca-Cola
Coca-Cola zéro : Coca-Cola
Eau de source : Cristalline
Fanta citron : Coca-Cola
Fanta orange : Coca-Cola
Lipton peach : Pepsico
Lipton zéro citron : Pepsico
Monster energy ultra blue : Monster
Monster energy ultra gold : Monster
Pepsi : Pepsico
Pepsi Max zéro : Pepsico

--5. Afficher la liste des ingrédients pour une Raclaccia.
SELECT i.nom_ingrédient
FROM ingrédient i
JOIN comprend c ON i.id_ingrédient = c.id_ingrédient
JOIN focaccia f ON c.id_focaccia = f.id_focaccia
WHERE f.nom_focaccia = 'Raclaccia';

--Le résultat attendu :
Ail, Base tomate, Champigon, Cresson, Parmesan, Poivre, Raclette, Champignon
--Le résultat obtenu :
Ail, Base tomate, Champigon, Cresson, Parmesan, Poivre, Raclette, Champignon

--6. Afficher le nom et le nombre d'ingrédients pour chaque foccacia.
SELECT f.nom_focaccia, COUNT(c.id_ingrédient) AS nombre_ingrédients
FROM focaccia f
JOIN comprend c ON f.id_focaccia = c.id_focaccia
GROUP BY f.nom_focaccia;

--Le résultat attendu :
Américaine : 8
Emmentalaccia : 7
Gorgonzolaccia : 8
Hawaienne : 9
Mozaccia :  10
Paysanne : 12
Raclaccia : 7
Tradizione : 9
--Le résultat obtenu :
Américaine : 8
Emmentalaccia : 7
Gorgonzolaccia : 8
Hawaienne : 9
Mozaccia :  10
Paysanne : 12
Raclaccia : 7
Tradizione : 9

--7. Afficher le nom de la focaccia qui a le plus d'ingrédients.
SELECT f.nom_focaccia
FROM focaccia f
JOIN comprend c ON f.id_focaccia = c.id_focaccia
GROUP BY f.id_focaccia
ORDER BY COUNT(c.id_ingrédient) DESC
LIMIT 1;

--Le résultat attendu :
Paysanne
--Le résultat obtenu :
Paysanne

--8. Afficher la liste des focaccia qui contiennent de l'ail.
SELECT f.nom_focaccia
FROM focaccia f
JOIN comprend c ON f.id_focaccia = c.id_focaccia
JOIN ingrédient i ON c.id_ingrédient = i.id_ingrédient
WHERE i.nom_ingrédient = 'Ail';

--Le résultat attendu :
Mozaccia, Gorgonzollaccia, Raclaccia, Paysanne
--Le résultat obtenu :
Mozaccia, Gorgonzollaccia, Raclaccia, Paysanne

--9. Afficher la liste des ingrédients inutilisés.
SELECT DISTINCT i.nom_ingrédient
FROM ingrédient i
LEFT JOIN comprend c ON i.id_ingrédient = c.id_ingrédient
GROUP BY i.nom_ingrédient
HAVING COUNT(c.id_ingrédient) = 0;

--Le résultat attendu :
Salami, Tomate cerise

--Le résultat obtenu :

Salami, Tomate cerise

--10. Afficher la liste des focaccia qui n'ont pas de champignons.
SELECT DISTINCT f.nom_focaccia
FROM focaccia f
LEFT JOIN comprend c ON f.id_focaccia = c.id_focaccia
LEFT JOIN ingrédient i ON c.id_ingrédient = i.id_ingrédient
WHERE f.id_focaccia NOT IN (
    SELECT c.id_focaccia
    FROM comprend c
    JOIN ingrédient i ON c.id_ingrédient = i.id_ingrédient
    WHERE i.nom_ingrédient = 'champignon'
);

--Le résultat attendu :
Hawaienne, Américaine
--Le résultat obtenu :
Hawaienne, Américaine






SELECT user, host FROM mysql.user WHERE user = 'tifosi';

DROP USER 'tifosi'@'%';
FLUSH PRIVILEGES;


SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

mysql/data/

*/