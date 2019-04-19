-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: mysql37.mydevil.net
-- Czas generowania: 19 Kwi 2019, 21:01
-- Wersja serwera: 5.7.21-20-log
-- Wersja PHP: 7.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `m1172_pseudol`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rpg_accounts`
--

CREATE TABLE `rpg_accounts` (
  `gid` smallint(6) NOT NULL,
  `name` text NOT NULL,
  `password` text NOT NULL,
  `skin` smallint(6) NOT NULL,
  `health` smallint(6) NOT NULL,
  `money` mediumint(9) NOT NULL,
  `bankmoney` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rpg_adminlogs`
--

CREATE TABLE `rpg_adminlogs` (
  `id` int(11) NOT NULL,
  `command` text NOT NULL,
  `admin` text NOT NULL,
  `target` text NOT NULL,
  `other` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rpg_bans`
--

CREATE TABLE `rpg_bans` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `serial` text NOT NULL,
  `time` datetime NOT NULL,
  `reason` text NOT NULL,
  `admin` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rpg_settings`
--

CREATE TABLE `rpg_settings` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Zrzut danych tabeli `rpg_settings`
--

INSERT INTO `rpg_settings` (`id`, `name`, `value`) VALUES
(1, 'name', 'OpenSourceRPG'),
(2, 'devMode', 'true'),
(3, 'devPass', 'changeme');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `rpg_accounts`
--
ALTER TABLE `rpg_accounts`
  ADD PRIMARY KEY (`gid`);

--
-- Indeksy dla tabeli `rpg_adminlogs`
--
ALTER TABLE `rpg_adminlogs`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `rpg_bans`
--
ALTER TABLE `rpg_bans`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `rpg_settings`
--
ALTER TABLE `rpg_settings`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `rpg_accounts`
--
ALTER TABLE `rpg_accounts`
  MODIFY `gid` smallint(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `rpg_adminlogs`
--
ALTER TABLE `rpg_adminlogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `rpg_bans`
--
ALTER TABLE `rpg_bans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `rpg_settings`
--
ALTER TABLE `rpg_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
