import ARKit
import RealityKit

extension ContentViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCount += 1
        guard frameCount % 2 == 0 else {
            return
        }
        self.resetLabels()
        
        didGetFrames(frame: frame.capturedImage)
    }
    
}
