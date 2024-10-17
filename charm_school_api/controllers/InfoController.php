<?php
require_once 'models/InfoModel.php';

class InfoController {
    private $model;

    public function __construct($connection) {
        $this->model = new InfoModel($connection);
    }

    public function index() {
        $data = $this->model->getAll(); 
        echo json_encode(["status" => "success", "data" => $data]);
    }

    public function show($id) {
        $data = $this->model->getById($id);
        if ($data) {
            echo json_encode(["status" => "success", "data" => $data]);
        } else {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Data not found"]);
        }
    }

    public function store() {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($this->model->create($input)) {
            echo json_encode(["status" => "success", "message" => "Info added successfully"]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Failed to add info"]);
        }
    }

    public function update($id) {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($this->model->update($id, $input)) {
            echo json_encode(["status" => "success", "message" => "Info updated successfully"]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Failed to update info"]);
        }
    }

    public function destroy($id) {
        if ($this->model->delete($id)) {
            echo json_encode(["status" => "success", "message" => "Info deleted successfully"]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Failed to delete info"]);
        }
    }
}
