<?php
class InfoModel {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;
    }

    public function getAll() {
        $sql = "SELECT * FROM info";
        $result = $this->connection->query($sql);
        return $result->fetch_all(MYSQLI_ASSOC);
    }

    public function getById($kd_info) {
        $kd_info = $this->connection->real_escape_string($kd_info);
        $sql = "SELECT * FROM info WHERE kd_info = '$kd_info'";
        $result = $this->connection->query($sql);
        return $result->fetch_assoc();
    }

    public function create($data) {
        $sql = "INSERT INTO info (judul_info, isi_info, tgl_post_info, status_info, kd_petugas) VALUES (?, ?, ?, ?, ?)";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("sssss", $data['judul_info'], $data['isi_info'], $data['tgl_post_info'], $data['status_info'], $data['kd_petugas']);
        return $stmt->execute();
    }

    public function update($kd_info, $data) {
        $sql = "UPDATE info SET judul_info = ?, isi_info = ?, tgl_post_info = ?, status_info = ?, kd_petugas = ? WHERE kd_info = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("ssssss", $data['judul_info'], $data['isi_info'], $data['tgl_post_info'], $data['status_info'], $data['kd_petugas'], $kd_info);
        return $stmt->execute();
    }

    public function delete($kd_info) {
        $sql = "DELETE FROM info WHERE kd_info = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("s", $kd_info);
        return $stmt->execute();
    }
}
