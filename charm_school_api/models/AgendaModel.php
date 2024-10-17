<?php
class AgendaModel {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;
    }

    public function getAll() {
        $sql = "SELECT * FROM agenda";
        $result = $this->connection->query($sql);
        return $result->fetch_all(MYSQLI_ASSOC);
    }

    public function getById($kd_agenda) {
        $kd_agenda = $this->connection->real_escape_string($kd_agenda);
        $sql = "SELECT * FROM agenda WHERE kd_agenda= '$kd_agenda'";
        $result = $this->connection->query($sql);
        return $result->fetch_assoc();
    }

    public function create($data) {
        $sql = "INSERT INTO agenda (judul_agenda, isi_agenda, tgl_agenda, tgl_post_agenda, status_agenda, kd_petugas) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("ssssss", $data['judul_agenda'], $data['isi_agenda'], $data['tgl_agenda'], $data['tgl_post_agenda'], $data['status_agenda'], $data['kd_petugas']);
        return $stmt->execute();
    }

    public function update($kd_agenda, $data) {
        $sql = "UPDATE agenda SET judul_agenda = ?, isi_agenda = ?, tgl_agenda = ?, tgl_post_agenda = ?, status_agenda = ?, kd_petugas = ? WHERE kd_agenda = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("sssssss", 
            $data['judul_agenda'], 
            $data['isi_agenda'], 
            $data['tgl_agenda'], 
            $data['tgl_post_agenda'], 
            $data['status_agenda'], 
            $data['kd_petugas'],
            $kd_agenda
        );
        return $stmt->execute();
    }

    public function delete($kd_agenda) {
        $sql = "DELETE FROM agenda WHERE kd_agenda = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("i", $kd_agenda);
        return $stmt->execute();
    }
}
