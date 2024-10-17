<?php
require_once 'models/GalleryModel.php';

define('IMAGE_DIR', 'uploads/');
define('PLACEHOLDER_IMAGE', 'placeholder_image.png');
define('MAX_FILE_SIZE', 2 * 1024 * 1024);
define('ALLOWED_TYPES', ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']);

class GalleryController {
    private $model;

    public function __construct($connection) {
        $this->model = new GalleryModel($connection);
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
        error_log("Received POST data: " . print_r($_POST, true));
        error_log("Received FILES data: " . print_r($_FILES, true));
        
        $input = $_POST;
        $requiredFields = ['judul_galery', 'isi_galery', 'tgl_post_galery', 'status_galery', 'kd_petugas'];
        
        foreach ($requiredFields as $field) {
            if (!isset($input[$field]) || $input[$field] === '') {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Missing required field: $field"]);
                return;
            }
        }

        $fileName = PLACEHOLDER_IMAGE;

        if (isset($_FILES['foto_galery']) && $_FILES['foto_galery']['error'] !== UPLOAD_ERR_NO_FILE) {
            $file = $_FILES['foto_galery'];
            if (!$this->validateUploadedFile($file)) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Invalid file upload: " . $this->getFileErrorMessage($file)]);
                return;
            }

            $uploadResult = $this->handleFileUpload($file);
            if (!$uploadResult['success']) {
                error_log("Failed to upload file: " . $uploadResult['message']);
                http_response_code(500);
                echo json_encode(["status" => "error", "message" => "Failed to upload image: " . $uploadResult['message']]);
                return;
            }
            $fileName = $uploadResult['fileName'];
        } else {
            error_log("No file uploaded or upload error occurred, using placeholder image");
            $fileName = PLACEHOLDER_IMAGE;
        }

        $input['foto_galery'] = $fileName;

        error_log("Attempting to create gallery with data: " . json_encode($input));

        if ($this->model->create($input)) {
            echo json_encode(["status" => "success", "message" => "Gallery added successfully"]);
        } else {
            // If the database insert fails, delete the uploaded image
            if ($fileName !== PLACEHOLDER_IMAGE && file_exists(IMAGE_DIR . $fileName)) {
                unlink(IMAGE_DIR . $fileName);
            }
            error_log("Failed to add gallery to database. Model returned false.");
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Failed to add gallery to database"]);
        }
    }

    public function update($id) {
        error_log("Update method called for gallery ID: $id");
        
        // Get the raw input
        $rawInput = file_get_contents('php://input');
        $input = json_decode($rawInput, true);
        
        error_log("Processed input data: " . print_r($input, true));
        
        $existingGallery = $this->model->getById($id);
        if (!$existingGallery) {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Gallery not found"]);
            return;
        }

        $imageUpdated = false;

        // Handle image update
        if (isset($input['foto_galery']) && strpos($input['foto_galery'], 'data:image/') === 0) {
            $uploadResult = $this->handleBase64ImageUpload($input['foto_galery']);
            if ($uploadResult['success']) {
                $input['foto_galery'] = $uploadResult['fileName'];
                $this->deleteOldImage($existingGallery['foto_galery']);
                $imageUpdated = true;
                error_log("New image uploaded from base64: " . $input['foto_galery']);
            } else {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => $uploadResult['message']]);
                error_log("Base64 file upload failed: " . $uploadResult['message']);
                return;
            }
        } elseif (!isset($input['foto_galery'])) {
            // If no new image is provided, keep the existing one
            $input['foto_galery'] = $existingGallery['foto_galery'];
            error_log("No new image provided, keeping existing image: " . $input['foto_galery']);
        }

        // Remove empty fields from input, but keep fields with '0' value
        $input = array_filter($input, function($value) {
            return $value !== null && $value !== '' || $value === '0';
        });

        error_log("Filtered input data: " . print_r($input, true));

        // Force update with all input data
        $updateResult = $this->model->update($id, $input);

        if ($updateResult) {
            $message = $imageUpdated ? 
                "Gallery and image updated successfully" : 
                "Gallery updated successfully (image unchanged)";
            echo json_encode(["status" => "success", "message" => $message]);
            error_log($message);
        } else {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Failed to update gallery"]);
        }
    }

    public function destroy($id) {
        $gallery = $this->model->getById($id);
        if (!$gallery) {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Gallery not found"]);
            return;
        }

        $imageDeleted = true;
        // Delete the image file if it exists and is not the placeholder
        if ($gallery['foto_galery'] !== PLACEHOLDER_IMAGE) {
            $imagePath = IMAGE_DIR . $gallery['foto_galery'];
            if (file_exists($imagePath)) {
                if (!unlink($imagePath)) {
                    error_log("Failed to delete image file: $imagePath");
                    $imageDeleted = false;
                }
            } else {
                error_log("Image file not found: $imagePath");
            }
        }

        if ($this->model->delete($id)) {
            $message = $imageDeleted ? 
                "Gallery and associated image deleted successfully" : 
                "Gallery deleted successfully, but failed to delete the image file";
            echo json_encode(["status" => "success", "message" => $message]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "Failed to delete gallery"]);
        }
    }

    private function validateUploadedFile($file) {
        if (!isset($file) || $file['error'] === UPLOAD_ERR_NO_FILE) {
            return true; // No file uploaded, which is allowed
        }
        if ($file['error'] !== UPLOAD_ERR_OK) {
            error_log("File upload error: " . $file['error']);
            return false;
        }
        if ($file['size'] > MAX_FILE_SIZE) {
            error_log("File too large: " . $file['size'] . " bytes");
            return false;
        }
        if (!in_array($file['type'], ALLOWED_TYPES)) {
            error_log("Invalid file type: " . $file['type']);
            return false;
        }
        return true;
    }

    private function handleFileUpload($file) {
        if ($this->validateUploadedFile($file)) {
            $fileName = $file['name'];
            $filePath = IMAGE_DIR . $fileName;
            
            // Jika file dengan nama yang sama sudah ada, tambahkan timestamp
            if (file_exists($filePath)) {
                $fileInfo = pathinfo($fileName);
                $fileName = $fileInfo['filename'] . '_' . time() . '.' . $fileInfo['extension'];
                $filePath = IMAGE_DIR . $fileName;
            }
            
            if (move_uploaded_file($file['tmp_name'], $filePath)) {
                return ['success' => true, 'fileName' => $fileName];
            } else {
                return ['success' => false, 'message' => 'Failed to move uploaded file'];
            }
        } else {
            return ['success' => false, 'message' => $this->getFileErrorMessage($file)];
        }
    }

    private function deleteOldImage($oldFileName) {
        if ($oldFileName && $oldFileName !== PLACEHOLDER_IMAGE) {
            $oldFilePath = IMAGE_DIR . $oldFileName;
            if (file_exists($oldFilePath)) {
                unlink($oldFilePath);
            }
        }
    }

    private function getFileErrorMessage($file) {
        switch ($file['error']) {
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                return "The uploaded file exceeds the allowed size.";
            case UPLOAD_ERR_PARTIAL:
                return "The uploaded file was only partially uploaded.";
            case UPLOAD_ERR_NO_FILE:
                return "No file was uploaded.";
            case UPLOAD_ERR_NO_TMP_DIR:
                return "Missing a temporary folder.";
            case UPLOAD_ERR_CANT_WRITE:
                return "Failed to write file to disk.";
            case UPLOAD_ERR_EXTENSION:
                return "A PHP extension stopped the file upload.";
        }
        if ($file['size'] > MAX_FILE_SIZE) {
            return "The file is too large (max " . (MAX_FILE_SIZE / 1024 / 1024) . "MB).";
        }
        if (!in_array($file['type'], ALLOWED_TYPES)) {
            return "The file type is not allowed.";
        }
        return "Unknown error occurred during file upload.";
    }

    private function handleBase64ImageUpload($base64Image) {
        // Extract the base64 encoded binary data
        preg_match('/^data:image\/(\w+);base64,/', $base64Image, $type);
        $imageType = $type[1];
        $base64Image = preg_replace('#^data:image/\w+;base64,#i', '', $base64Image);
        $imageData = base64_decode($base64Image);

        if ($imageData === false) {
            return ['success' => false, 'message' => 'Invalid base64 image data'];
        }

        $mimeType = 'image/' . $imageType;
        if (!in_array($mimeType, ALLOWED_TYPES)) {
            return ['success' => false, 'message' => 'Invalid image type'];
        }

        // Generate a filename
        $fileName = 'image_' . time() . '.' . $imageType;
        $filePath = IMAGE_DIR . $fileName;

        // Save the image file
        if (file_put_contents($filePath, $imageData) === false) {
            return ['success' => false, 'message' => 'Failed to save image file'];
        }

        return ['success' => true, 'fileName' => $fileName];
    }
}