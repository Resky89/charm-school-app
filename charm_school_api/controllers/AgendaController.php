<?php
require_once 'models/AgendaModel.php';

class AgendaController {
    private $model;

    public function __construct($connection) {
        $this->model = new AgendaModel($connection);
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
            echo json_encode(["status" => "error", "message" => "Data not found"]);
        }
    }

    public function store() {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($this->model->create($input)) {
            echo json_encode(["status" => "success", "message" => "Agenda added successfully"]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Failed to add agenda"]);
        }
    }

    public function update($id) {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($this->model->update($id, $input)) {
            echo json_encode(["status" => "success", "message" => "Agenda updated successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update agenda"]);
        }
    }

    public function destroy($id) {
        if ($this->model->delete($id)) {
            echo json_encode(["status" => "success", "message" => "Agenda deleted successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to delete agenda"]);
        }
    }
}
