-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 26, 2022 alle 14:04
-- Versione del server: 10.3.16-MariaDB
-- Versione PHP: 7.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `progettobdd`
--
CREATE DATABASE IF NOT EXISTS `progettobdd` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `progettobdd`;

DELIMITER $$
--
-- Procedure
--
DROP PROCEDURE IF EXISTS `fermate_treno`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `fermate_treno` (IN `denom` VARCHAR(30))  BEGIN
    SELECT CONCAT(nome_stazione, ' (', SUBSTRING(ora_a, 1, 5), ')') as Stazione_Arrivo_Ora
    FROM corsa c INNER JOIN stazione s on c.id_stazione_a = s.id_stazione
    WHERE  id_treno = (SELECT id_treno FROM treno WHERE denominazione = denom)
    ORDER BY ora_a;
END$$

DROP PROCEDURE IF EXISTS `lista_stazioni_trafficate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lista_stazioni_trafficate` ()  BEGIN
SELECT nome_stazione, COUNT(*) as traffico_persone FROM acquisto_biglietto
    INNER JOIN biglietto USING (id_biglietto)
    INNER JOIN associazione_biglietto_corsa USING (id_biglietto)
    INNER JOIN corsa USING (id_corsa)
    INNER JOIN stazione s on corsa.id_stazione_a = s.id_stazione
GROUP BY id_stazione_a ORDER BY traffico_persone DESC;
END$$

DROP PROCEDURE IF EXISTS `num_posti_treni`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `num_posti_treni` ()  BEGIN
    SELECT denominazione, t.id_treno, SUM(num_posti) AS posti_Totali FROM treno t
        INNER JOIN composizione_treno ct on t.id_treno = ct.id_treno
        INNER JOIN vagone v on ct.id_vagone = v.id_vagone
        INNER JOIN tipologia tp on v.tipo = tp.tipo
    GROUP BY t.id_treno ORDER BY posti_Totali;
END$$

DROP PROCEDURE IF EXISTS `stampa_riepilogo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stampa_riepilogo` (IN `codice_b` VARCHAR(5), IN `codice_c` VARCHAR(5), OUT `riepilogo` VARCHAR(5000))  BEGIN
DECLARE nominativo, denom_treno, ora_par, ora_arr, st1, st2 VARCHAR(30);
DECLARE data_v DATE;
DECLARE costo_biglietto DECIMAL(4,2);
DECLARE finished INTEGER DEFAULT 0;
DECLARE corse_cursor CURSOR FOR
(SELECT denominazione, SUBSTRING(c.ora_p,1,5), s1.nome_stazione,
SUBSTRING(c.ora_a,1,5), s2.nome_stazione FROM corsa c
INNER JOIN associazione_biglietto_corsa USING (id_corsa)
INNER JOIN treno USING (id_treno)
INNER JOIN stazione s1 on c.id_stazione_p = s1.id_stazione
INNER JOIN stazione s2 on c.id_stazione_a = s2.id_stazione
WHERE id_biglietto = codice_b ORDER BY c.ora_a);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
SELECT CONCAT(nome,' ',cognome) INTO nominativo FROM cliente
WHERE id_cliente = codice_c;
SELECT costo INTO costo_biglietto
FROM biglietto WHERE id_biglietto = codice_b;
SELECT data_viaggio INTO data_v FROM acquisto_biglietto WHERE id_cliente = codice_c AND id_biglietto =
codice_b;
SET riepilogo = CONCAT(nominativo,'. Costo biglietto : ', costo_biglietto, '
euro. Data Viaggio : ', data_v, ' ');
OPEN corse_cursor;
WHILE (finished = 0) DO
FETCH corse_cursor INTO denom_treno, ora_par, st1, ora_arr, st2;
IF finished = 0 THEN
SET riepilogo = CONCAT(riepilogo, ' | ', denom_treno,', ', st1,' ->
',ora_par,', ', st2,' -> ', ora_arr);
END IF;
END WHILE;
CLOSE corse_cursor;
END$$

DROP PROCEDURE IF EXISTS `trova_treno`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `trova_treno` (IN `id_staz_a` VARCHAR(5), IN `id_staz_p` VARCHAR(5), IN `tempo` TIME)  BEGIN
    SELECT denominazione AS treno, SUBSTRING(c.ora_p, 1, 5) AS ora_partenza,
       SUBSTRING(c.ora_a, 1, 5) AS ora_arrivo FROM corsa c
    INNER JOIN treno t on c.id_treno = t.id_treno
    WHERE id_staz_a = id_stazione_a AND id_stazione_p = id_staz_p AND ora_p > tempo
    ORDER BY c.ora_p;
END$$

DROP PROCEDURE IF EXISTS `vendita_biglietti_mensile`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `vendita_biglietti_mensile` (IN `mese` INT(2))  BEGIN
    SELECT
        data_acquisto AS giorno,
        COUNT(*) AS num_Biglietti
    FROM
        acquisto_biglietto
    WHERE
        MONTH(data_acquisto) = mese
    GROUP BY
        data_acquisto
    ORDER BY
        data_acquisto;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `acquisto_biglietto`
--

DROP TABLE IF EXISTS `acquisto_biglietto`;
CREATE TABLE `acquisto_biglietto` (
  `id_cliente` varchar(5) NOT NULL,
  `id_biglietto` varchar(5) NOT NULL,
  `data_acquisto` date NOT NULL,
  `data_viaggio` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `acquisto_biglietto`
--

INSERT INTO `acquisto_biglietto` (`id_cliente`, `id_biglietto`, `data_acquisto`, `data_viaggio`) VALUES
('15nci', '1n7b3', '2022-05-03', '2022-05-22'),
('18261', '497h2', '2022-05-11', '2022-05-11'),
('1m36n', 'sbq32', '2022-05-05', '2022-05-18'),
('41ov8', 'inq9q', '2022-05-13', '2022-05-13'),
('6x8uo', 'v05s5', '2022-05-06', '2022-05-08'),
('ezcx4', 'v05s5', '2022-05-06', '2022-05-09'),
('f3307', 'v05s5', '2022-05-06', '2022-05-07'),
('gx3k7', 'a520j', '2022-05-04', '2022-05-17'),
('i95ij', 'v05s5', '2022-05-14', '2022-05-18'),
('m3n4j', '497h2', '2022-05-10', '2022-05-10'),
('m42cj', 'fnb7p', '2022-05-05', '2022-05-06'),
('n8941', 'k29p5', '2022-05-12', '2022-05-12'),
('p5wun', 'k29p5', '2022-05-10', '2022-05-10'),
('sx2do', 'k29p5', '2022-05-14', '2022-05-14');

-- --------------------------------------------------------

--
-- Struttura della tabella `associazione_biglietto_corsa`
--

DROP TABLE IF EXISTS `associazione_biglietto_corsa`;
CREATE TABLE `associazione_biglietto_corsa` (
  `id_biglietto` varchar(5) NOT NULL,
  `id_corsa` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `associazione_biglietto_corsa`
--

INSERT INTO `associazione_biglietto_corsa` (`id_biglietto`, `id_corsa`) VALUES
('020x7', 'h5d6c'),
('1n7b3', '6p98y'),
('1n7b3', 'j557g'),
('38ltz', 'rlc3i'),
('497h2', '52b60'),
('4j564', '4btjv'),
('4j564', 'j557g'),
('8j9f7', '24vo1'),
('9doc5', '83q30'),
('9doc5', 'j557g'),
('9v3w3', '458p8'),
('a520j', '0sq2w'),
('a520j', 'j557g'),
('cwqkr', 'k397u'),
('fnb7p', '5r706'),
('h6so8', 'j557g'),
('h6so8', 'js82w'),
('inq9q', 'yu168'),
('iroys', '1w460'),
('k29p5', '7748s'),
('nyso6', '17z28'),
('nyso6', 'j557g'),
('sbq32', '7s2l3'),
('sbq32', 'j557g'),
('v05s5', 'j557g');

-- --------------------------------------------------------

--
-- Struttura della tabella `biglietto`
--

DROP TABLE IF EXISTS `biglietto`;
CREATE TABLE `biglietto` (
  `id_biglietto` varchar(5) NOT NULL,
  `costo` decimal(4,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `biglietto`
--

INSERT INTO `biglietto` (`id_biglietto`, `costo`) VALUES
('020x7', '15.00'),
('1n7b3', '23.45'),
('38ltz', '11.35'),
('497h2', '7.95'),
('4j564', '21.90'),
('8j9f7', '4.25'),
('9doc5', '19.65'),
('9v3w3', '6.05'),
('a520j', '16.45'),
('cwqkr', '5.00'),
('fnb7p', '13.30'),
('h6so8', '24.25'),
('inq9q', '9.25'),
('iroys', '11.35'),
('k29p5', '3.50'),
('nyso6', '16.75'),
('sbq32', '17.05'),
('v05s5', '13.60');

-- --------------------------------------------------------

--
-- Struttura della tabella `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `id_cliente` varchar(5) NOT NULL,
  `nome` varchar(30) NOT NULL,
  `cognome` varchar(30) NOT NULL,
  `email` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `nome`, `cognome`, `email`) VALUES
('15nci', 'Emma', 'Ferri', NULL),
('18261', 'Marta', 'Zenta', 'zen125@gmail.com'),
('1m36n', 'Pietro', 'Beltano', 'pbelt912@gmail.com'),
('41ov8', 'Carlo', 'Carta', NULL),
('6x8uo', 'Edoardo', 'Costa', 'costola904@gmail.com'),
('a2954', 'Mario', 'Rossi', 'mario.mario@gmail.com'),
('ezcx4', 'Enrico', 'Foglia', 'enriFo@gmail.com'),
('f3307', 'Tommaso', 'Gallo', NULL),
('gx3k7', 'Giorgia', 'Testa', NULL),
('i95ij', 'Federico', 'Ghisa', 'fede124g@alice.it'),
('m3n4j', 'Maria', 'Abruzzi', 'marizzi@alice.it'),
('m42cj', 'Riccardo', 'Romano', NULL),
('n8941', 'Anna', 'Pietra', NULL),
('nvpka', 'Andrea', 'Tumiz', NULL),
('p5wun', 'Ginevra', 'Fontana', 'ninfea123@gmail.com'),
('rp3p3', 'Gabriele', 'Bianchi', 'gabi@gmail.com'),
('sx2do', 'Giulio', 'Ferluzzi', 'gl15213@gmail.com'),
('zs82w', 'Alice', 'Vergo', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `composizione_treno`
--

DROP TABLE IF EXISTS `composizione_treno`;
CREATE TABLE `composizione_treno` (
  `id_treno` varchar(5) NOT NULL,
  `id_vagone` varchar(5) NOT NULL,
  `posizione` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `composizione_treno`
--

INSERT INTO `composizione_treno` (`id_treno`, `id_vagone`, `posizione`) VALUES
('923v1', '403u4', 3),
('923v1', '438nt', 6),
('923v1', '4r0r0', 2),
('923v1', '5f5am', 7),
('923v1', '9wo36', 4),
('923v1', 'hpl6v', 5),
('923v1', 'q2d16', 1),
('lv6gk', '2rjvq', 5),
('lv6gk', '5r4c4', 6),
('lv6gk', '625at', 2),
('lv6gk', '97r48', 1),
('lv6gk', 'ly7g2', 4),
('lv6gk', 'v47c7', 3);

-- --------------------------------------------------------

--
-- Struttura della tabella `corsa`
--

DROP TABLE IF EXISTS `corsa`;
CREATE TABLE `corsa` (
  `id_corsa` varchar(5) NOT NULL,
  `id_treno` varchar(5) NOT NULL,
  `id_stazione_p` varchar(5) NOT NULL,
  `id_stazione_a` varchar(5) NOT NULL,
  `ora_a` time NOT NULL,
  `ora_p` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `corsa`
--

INSERT INTO `corsa` (`id_corsa`, `id_treno`, `id_stazione_p`, `id_stazione_a`, `ora_a`, `ora_p`) VALUES
('0mz26', '8kz2j', '9o55i', '9k34t', '17:25:00', '16:16:00'),
('0oo62', '8kz2j', '9o55i', 'owq89', '17:00:00', '16:16:00'),
('0sq2w', 'lv6gk', '73086', '75094', '18:09:00', '17:53:00'),
('17z28', 'lv6gk', '73086', 'pd2u1', '18:18:00', '17:53:00'),
('1w460', '923v1', '9o55i', 'zepld', '16:34:00', '15:16:00'),
('24vo1', '923v1', '9o55i', '4h29h', '15:45:00', '15:16:00'),
('268ux', '8kz2j', '9o55i', '4h29h', '16:45:00', '16:16:00'),
('3m1ds', 'ukzs4', '9o55i', '1f7b5', '17:50:00', '17:26:00'),
('458p8', '923v1', '9o55i', 'owq89', '16:00:00', '15:16:00'),
('4btjv', 'lv6gk', '73086', 'e349o', '19:18:00', '17:53:00'),
('52b60', '923v1', '9o55i', 'wgct3', '16:14:00', '15:16:00'),
('5r706', '923v1', '9o55i', 't66at', '16:55:00', '15:16:00'),
('6p98y', 'lv6gk', '73086', '1ckek', '19:30:00', '17:53:00'),
('7748s', '923v1', '9o55i', '1f7b5', '15:40:00', '15:16:00'),
('7m1xu', 'ukzs4', '9o55i', '73086', '19:14:00', '17:26:00'),
('7s2l3', 'lv6gk', '73086', 'l3kuz', '18:29:00', '17:53:00'),
('83q30', 'lv6gk', '73086', '0796g', '18:58:00', '17:53:00'),
('98q5p', '8kz2j', '9o55i', 'stvzr', '18:21:00', '16:16:00'),
('9zz15', 'ukzs4', '9o55i', 'owq89', '18:10:00', '17:26:00'),
('a355x', '8kz2j', '9o55i', '1f7b5', '16:40:00', '16:16:00'),
('btm0p', 'ukzs4', '9o55i', 'llxa2', '18:03:00', '17:26:00'),
('c7a8i', 'ukzs4', '9o55i', '4h29h', '17:55:00', '17:26:00'),
('d78ym', 'ukzs4', '9o55i', 'wgct3', '18:24:00', '17:26:00'),
('h5d6c', '923v1', '9o55i', 'stvzr', '17:21:00', '15:16:00'),
('h913z', '8kz2j', '9o55i', 'llxa2', '16:53:00', '16:16:00'),
('j557g', '923v1', '9o55i', '73086', '17:11:00', '15:16:00'),
('js82w', 'lv6gk', '73086', '0bf3h', '19:48:00', '17:53:00'),
('k397u', '923v1', '9o55i', 'llxa2', '15:53:00', '15:16:00'),
('o63pe', '8kz2j', '9o55i', 'u4gt4', '17:43:00', '16:16:00'),
('rlc3i', '923v1', '9o55i', 'u4gt4', '16:43:00', '15:16:00'),
('t58b7', 'ukzs4', '9o55i', 'stvzr', '19:24:00', '17:26:00'),
('tgaw7', '8kz2j', '9o55i', 't66at', '17:55:00', '16:16:00'),
('uj7pi', '8kz2j', '9o55i', 'wgct3', '17:14:00', '16:16:00'),
('yk11y', '8kz2j', '9o55i', 'zepld', '17:34:00', '16:16:00'),
('yu168', '923v1', '9o55i', '9k34t', '16:25:00', '15:16:00'),
('zr1s4', '8kz2j', '9o55i', '73086', '18:11:00', '16:16:00');

--
-- Trigger `corsa`
--
DROP TRIGGER IF EXISTS `controllo_corsa`;
DELIMITER $$
CREATE TRIGGER `controllo_corsa` BEFORE INSERT ON `corsa` FOR EACH ROW BEGIN
        IF NEW.ora_a < NEW.ora_p THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Orario di arrivo e partenza invalidi';
        END IF;
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `stazione`
--

DROP TABLE IF EXISTS `stazione`;
CREATE TABLE `stazione` (
  `id_stazione` varchar(5) NOT NULL,
  `nome_stazione` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `stazione`
--

INSERT INTO `stazione` (`id_stazione`, `nome_stazione`) VALUES
('0796g', 'Rovigo'),
('0bf3h', 'Bologna Centrale'),
('1ckek', 'S. Pietro In Casale'),
('1f7b5', 'Stazione di Monfalcone'),
('4h29h', 'Trieste Airport'),
('73086', 'Venezia Mestre'),
('75094', 'Padova'),
('9k34t', 'Portogruaro-Caorle'),
('9o55i', 'Trieste Centrale'),
('e349o', 'Ferrara'),
('l3kuz', 'Monselice'),
('llxa2', 'Cervignano-Aquileia-Grado'),
('owq89', 'San Giorgio di Nogaro'),
('pd2u1', 'T. Euganee-Abano-Montegrotto'),
('stvzr', 'Venezia Santa Lucia'),
('t66at', 'Quarto D\'Altino'),
('u4gt4', 'San Dona\' di Piave'),
('wgct3', 'Latisana-Lignano-Bibione'),
('zepld', 'San Stino di Livenza');

-- --------------------------------------------------------

--
-- Struttura della tabella `tipologia`
--

DROP TABLE IF EXISTS `tipologia`;
CREATE TABLE `tipologia` (
  `tipo` varchar(5) NOT NULL,
  `gruppo` varchar(5) DEFAULT NULL,
  `num_posti` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `tipologia`
--

INSERT INTO `tipologia` (`tipo`, `gruppo`, `num_posti`) VALUES
('0', NULL, 20),
('1', NULL, 30),
('2', NULL, 40),
('A', 'E.656', NULL),
('B', 'E.444', NULL),
('C', 'E.624', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `tratta`
--

DROP TABLE IF EXISTS `tratta`;
CREATE TABLE `tratta` (
  `id_tratta` varchar(5) NOT NULL,
  `id_stazione_1` varchar(5) NOT NULL,
  `id_stazione_2` varchar(5) NOT NULL,
  `lunghezza` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `tratta`
--

INSERT INTO `tratta` (`id_tratta`, `id_stazione_1`, `id_stazione_2`, `lunghezza`) VALUES
('ispnn', 'stvzr', '0bf3h', 163),
('nc324', '9o55i', 'stvzr', 159);

-- --------------------------------------------------------

--
-- Struttura della tabella `treno`
--

DROP TABLE IF EXISTS `treno`;
CREATE TABLE `treno` (
  `id_treno` varchar(5) NOT NULL,
  `id_tratta` varchar(5) NOT NULL,
  `denominazione` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `treno`
--

INSERT INTO `treno` (`id_treno`, `id_tratta`, `denominazione`) VALUES
('8kz2j', 'nc324', 'Regionale_3444'),
('923v1', 'nc324', 'Regionale_3562'),
('lv6gk', 'ispnn', 'Regionale_3985'),
('ukzs4', 'nc324', 'Regionale_3564');

-- --------------------------------------------------------

--
-- Struttura della tabella `vagone`
--

DROP TABLE IF EXISTS `vagone`;
CREATE TABLE `vagone` (
  `id_vagone` varchar(5) NOT NULL,
  `peso` int(11) NOT NULL,
  `tipo` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `vagone`
--

INSERT INTO `vagone` (`id_vagone`, `peso`, `tipo`) VALUES
('2rjvq', 46, '0'),
('403u4', 45, '1'),
('438nt', 43, '2'),
('4r0r0', 40, '1'),
('5f5am', 102, 'A'),
('5r4c4', 103, 'C'),
('60h17', 104, 'A'),
('625at', 40, '2'),
('7ah6n', 105, 'B'),
('7xflp', 41, '0'),
('97r48', 105, 'B'),
('9wo36', 40, '1'),
('gjlz0', 41, '0'),
('hpl6v', 44, '2'),
('ly7g2', 42, '2'),
('q2d16', 101, 'A'),
('v47c7', 39, '2'),
('w500v', 100, 'C');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `acquisto_biglietto`
--
ALTER TABLE `acquisto_biglietto`
  ADD PRIMARY KEY (`id_cliente`,`id_biglietto`),
  ADD KEY `id_cliente` (`id_biglietto`);

--
-- Indici per le tabelle `associazione_biglietto_corsa`
--
ALTER TABLE `associazione_biglietto_corsa`
  ADD PRIMARY KEY (`id_biglietto`,`id_corsa`),
  ADD KEY `id_corsa` (`id_corsa`);

--
-- Indici per le tabelle `biglietto`
--
ALTER TABLE `biglietto`
  ADD PRIMARY KEY (`id_biglietto`);

--
-- Indici per le tabelle `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`);

--
-- Indici per le tabelle `composizione_treno`
--
ALTER TABLE `composizione_treno`
  ADD PRIMARY KEY (`id_treno`,`id_vagone`),
  ADD KEY `id_vagone` (`id_vagone`);

--
-- Indici per le tabelle `corsa`
--
ALTER TABLE `corsa`
  ADD PRIMARY KEY (`id_corsa`),
  ADD KEY `id_treno` (`id_treno`),
  ADD KEY `id_stazione_a` (`id_stazione_a`),
  ADD KEY `id_stazione_p` (`id_stazione_p`);

--
-- Indici per le tabelle `stazione`
--
ALTER TABLE `stazione`
  ADD PRIMARY KEY (`id_stazione`);

--
-- Indici per le tabelle `tipologia`
--
ALTER TABLE `tipologia`
  ADD PRIMARY KEY (`tipo`);

--
-- Indici per le tabelle `tratta`
--
ALTER TABLE `tratta`
  ADD PRIMARY KEY (`id_tratta`),
  ADD KEY `id_stazione_a` (`id_stazione_2`),
  ADD KEY `id_stazione_p` (`id_stazione_1`);

--
-- Indici per le tabelle `treno`
--
ALTER TABLE `treno`
  ADD PRIMARY KEY (`id_treno`),
  ADD KEY `id_tratta` (`id_tratta`);

--
-- Indici per le tabelle `vagone`
--
ALTER TABLE `vagone`
  ADD PRIMARY KEY (`id_vagone`),
  ADD KEY `tipo` (`tipo`);

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `acquisto_biglietto`
--
ALTER TABLE `acquisto_biglietto`
  ADD CONSTRAINT `acquisto_biglietto_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `biglietto` (`id_biglietto`),
  ADD CONSTRAINT `acquisto_biglietto_ibfk_2` FOREIGN KEY (`id_biglietto`) REFERENCES `cliente` (`id_cliente`);

--
-- Limiti per la tabella `associazione_biglietto_corsa`
--
ALTER TABLE `associazione_biglietto_corsa`
  ADD CONSTRAINT `associazione_biglietto_corsa_ibfk_1` FOREIGN KEY (`id_biglietto`) REFERENCES `biglietto` (`id_biglietto`),
  ADD CONSTRAINT `associazione_biglietto_corsa_ibfk_2` FOREIGN KEY (`id_corsa`) REFERENCES `corsa` (`id_corsa`);

--
-- Limiti per la tabella `composizione_treno`
--
ALTER TABLE `composizione_treno`
  ADD CONSTRAINT `composizione_treno_ibfk_1` FOREIGN KEY (`id_treno`) REFERENCES `treno` (`id_treno`),
  ADD CONSTRAINT `composizione_treno_ibfk_2` FOREIGN KEY (`id_vagone`) REFERENCES `vagone` (`id_vagone`);

--
-- Limiti per la tabella `corsa`
--
ALTER TABLE `corsa`
  ADD CONSTRAINT `corsa_ibfk_1` FOREIGN KEY (`id_treno`) REFERENCES `treno` (`id_treno`),
  ADD CONSTRAINT `corsa_ibfk_2` FOREIGN KEY (`id_stazione_a`) REFERENCES `stazione` (`id_stazione`),
  ADD CONSTRAINT `corsa_ibfk_3` FOREIGN KEY (`id_stazione_p`) REFERENCES `stazione` (`id_stazione`);

--
-- Limiti per la tabella `tratta`
--
ALTER TABLE `tratta`
  ADD CONSTRAINT `tratta_ibfk_1` FOREIGN KEY (`id_stazione_2`) REFERENCES `stazione` (`id_stazione`),
  ADD CONSTRAINT `tratta_ibfk_2` FOREIGN KEY (`id_stazione_1`) REFERENCES `stazione` (`id_stazione`);

--
-- Limiti per la tabella `treno`
--
ALTER TABLE `treno`
  ADD CONSTRAINT `treno_ibfk_1` FOREIGN KEY (`id_tratta`) REFERENCES `tratta` (`id_tratta`);

--
-- Limiti per la tabella `vagone`
--
ALTER TABLE `vagone`
  ADD CONSTRAINT `vagone_ibfk_1` FOREIGN KEY (`tipo`) REFERENCES `tipologia` (`tipo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
