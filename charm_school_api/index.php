<?php
require_once 'config.php';
require_once 'controllers/InfoController.php';
require_once 'controllers/AgendaController.php';
require_once 'controllers/GalleryController.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$connection = new mysqli($host, $user, $pass, $db);

if ($connection->connect_error) {
    die("Koneksi gagal: " . $connection->connect_error);
}

// Menangani request
$request_uri = trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/');
$segments = explode('/', $request_uri);

// Mencari indeks 'index.php' dalam segments
$index_php_index = array_search('index.php', $segments);

// Jika 'index.php' ditemukan, ambil controller dari segment setelahnya
if ($index_php_index !== false && isset($segments[$index_php_index + 1])) {
    $controller = $segments[$index_php_index + 1];
    $action = $segments[$index_php_index + 2] ?? null;
    $id = $segments[$index_php_index + 3] ?? null;
} else {
    // Fallback ke logika sebelumnya jika 'index.php' tidak ditemukan
    $controller = $segments[1] ?? 'home';
    $action = $segments[2] ?? null;
    $id = $segments[3] ?? null;
}

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

switch ($controller) {
    case 'info':
        $controllerInstance = new InfoController($connection);
        break;
    case 'agenda':
        $controllerInstance = new AgendaController($connection);
        break;
    case 'gallery':
        $controllerInstance = new GalleryController($connection);
        break;
    case 'home':
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Page not found"]);
        exit();
    default:
        error_log("Invalid controller: " . $controller);
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Controller not found"]);
        exit();
}

try {
    switch ($_SERVER['REQUEST_METHOD']) {
        case 'GET':
            if ($action === 'show' && $id) {
                $controllerInstance->show($id);
            } else {
                $controllerInstance->index();
            }
            break;
        case 'POST':
            if ($controller === 'gallery') {
                $controllerInstance->store();
            } else {
                // For Info and Agenda, we don't pass any arguments to store()
                $controllerInstance->store();
            }
            break;
        case 'PUT':
            if ($action === 'update' && $id) {
                $_POST = array_merge($_POST, $_FILES);
                $controllerInstance->update($id);
            } else {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Invalid request"]);
            }
            break;
        case 'DELETE':
            if ($action === 'destroy' && $id) {
                $controllerInstance->destroy($id);
            } else {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Invalid request"]);
            }
            break;
        default:
            http_response_code(405);
            echo json_encode(["status" => "error", "message" => "Method not allowed"]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Internal Server Error: " . $e->getMessage()]);
}

$connection->close();
