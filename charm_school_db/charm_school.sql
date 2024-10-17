-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 17 Okt 2024 pada 05.51
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `charm_school`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `agenda`
--

CREATE TABLE `agenda` (
  `kd_agenda` int(11) NOT NULL,
  `judul_agenda` varchar(30) NOT NULL,
  `isi_agenda` text NOT NULL,
  `tgl_agenda` date NOT NULL,
  `tgl_post_agenda` date NOT NULL,
  `status_agenda` int(11) NOT NULL,
  `kd_petugas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data untuk tabel `agenda`
--

INSERT INTO `agenda` (`kd_agenda`, `judul_agenda`, `isi_agenda`, `tgl_agenda`, `tgl_post_agenda`, `status_agenda`, `kd_petugas`) VALUES
(3, 'SpooKToooBER', 'Hollowen Fest', '2024-10-25', '2024-10-10', 1, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `galery`
--

CREATE TABLE `galery` (
  `kd_galery` int(11) NOT NULL,
  `judul_galery` varchar(30) NOT NULL,
  `foto_galery` varchar(100) NOT NULL,
  `isi_galery` text NOT NULL,
  `tgl_post_galery` date NOT NULL,
  `status_galery` int(11) NOT NULL,
  `kd_petugas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `info`
--

CREATE TABLE `info` (
  `kd_info` int(11) NOT NULL,
  `judul_info` varchar(30) NOT NULL,
  `isi_info` text NOT NULL,
  `tgl_post_info` date NOT NULL,
  `status_info` int(11) NOT NULL,
  `kd_petugas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data untuk tabel `info`
--

INSERT INTO `info` (`kd_info`, `judul_info`, `isi_info`, `tgl_post_info`, `status_info`, `kd_petugas`) VALUES
(5, 'Day Offs again', 'Teachers & Parents Meeting', '2024-10-10', 1, 123),
(8, 'School Mid Exams', 'Starts at 07.00 AM', '2024-10-10', 0, 123),
(9, 'School Exams', 'Starts at 08.00 AM', '2024-10-17', 1, 123);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `agenda`
--
ALTER TABLE `agenda`
  ADD PRIMARY KEY (`kd_agenda`);

--
-- Indeks untuk tabel `galery`
--
ALTER TABLE `galery`
  ADD PRIMARY KEY (`kd_galery`);

--
-- Indeks untuk tabel `info`
--
ALTER TABLE `info`
  ADD PRIMARY KEY (`kd_info`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `agenda`
--
ALTER TABLE `agenda`
  MODIFY `kd_agenda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `galery`
--
ALTER TABLE `galery`
  MODIFY `kd_galery` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `info`
--
ALTER TABLE `info`
  MODIFY `kd_info` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
