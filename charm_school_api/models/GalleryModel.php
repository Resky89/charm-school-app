<?php
class GalleryModel {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;
    }

    public function getAll() {
        $sql = "SELECT * FROM galery";
        $result = $this->connection->query($sql);
        return $result->fetch_all(MYSQLI_ASSOC);
    }

    public function getById($id) {
        $sql = "SELECT * FROM galery WHERE kd_galery = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $gallery = $result->fetch_assoc();
        error_log("getById result: " . print_r($gallery, true));
        return $gallery;
    }

    public function create($data) {
        try {
            $query = "INSERT INTO galery (judul_galery, isi_galery, foto_galery, tgl_post_galery, status_galery, kd_petugas) 
                      VALUES (?, ?, ?, ?, ?, ?)";
            
            $stmt = $this->connection->prepare($query);
            
            $result = $stmt->execute([
                $data['judul_galery'],
                $data['isi_galery'],
                $data['foto_galery'],
                $data['tgl_post_galery'],
                $data['status_galery'],
                $data['kd_petugas']
            ]);
            
            if (!$result) {
                error_log("Database error: " . implode(", ", $stmt->errorInfo()));
            }
            
            return $result;
        } catch (PDOException $e) {
            error_log("PDO Exception: " . $e->getMessage());
            return false;
        }
    }

    public function update($id, $data) {
        if (empty($data)) {
            error_log("No data to update in model");
            return false;
        }

        $setClause = [];
        $types = "";
        $values = [];

        foreach ($data as $key => $value) {
            $setClause[] = "$key = ?";
            $types .= "s"; // All fields are treated as strings
            $values[] = $value;
        }

        $types .= "i"; // for the id
        $values[] = $id;

        $query = "UPDATE galery SET " . implode(', ', $setClause) . " WHERE kd_galery = ?";
        error_log("Update query: " . $query);
        error_log("Update data: " . print_r($values, true));
        
        $stmt = $this->connection->prepare($query);
        
        // Use call_user_func_array to bind parameters dynamically
        $bindParams = array_merge([$types], $values);
        foreach ($bindParams as $key => $value) {
            $bindParams[$key] = &$bindParams[$key];
        }
        call_user_func_array([$stmt, 'bind_param'], $bindParams);

        $result = $stmt->execute();

        if (!$result) {
            error_log("Database error in update: " . $stmt->error);
            return false;
        } else {
            error_log("Update executed. Rows affected: " . $stmt->affected_rows);
            return true; // Return true even if no rows were affected
        }
    }

    public function delete($kd_galery) {
        $sql = "DELETE FROM galery WHERE kd_galery = ?";
        $stmt = $this->connection->prepare($sql);
        $stmt->bind_param("i", $kd_galery);
        return $stmt->execute();
    }
}
