import Vision



struct JointModel {
    var x: Double
    var y: Double
    var confidence: Double
    var name: String
    var location: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

extension JointModel {
    init(jointCase: VNHumanHandPoseObservation.JointName, jointValues: VNRecognizedPoint) {
        name = String(describing: jointCase)
        x = jointValues.y
        y = jointValues.x
        
        confidence = Double(jointValues.confidence)
    }
}
