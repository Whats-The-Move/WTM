import AVFoundation

class CameraPermissionManager {
    
    static func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Camera access has been granted
            completion(true)
            
        case .denied, .restricted:
            // Camera access has been denied or restricted
            completion(false)
            
        case .notDetermined:
            // Camera access is not determined, request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        @unknown default:
            completion(false)
        }
    }
    
}
