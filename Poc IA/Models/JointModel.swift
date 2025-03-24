import Vision

enum JointNames: String, CaseIterable {
    case wrist, thumbCMC, thumbMP, thumbIP, thumbTip, indexMCP, indexPIP, indexDIP, indexTip, middleMCP, middlePIP, middleDIP, middleTip, ringMCP, ringPIP, ringDIP, ringTip, littleMCP, littlePIP, littleDIP, littleTip
}

struct JointModel {
    var x: Double
    var y: Double
    var confidence: Double
    var name: JointNames?
}

extension JointModel {
    init(jointName: VNHumanHandPoseObservation.JointName, jointValues: VNRecognizedPoint) {
        for joint in JointNames.allCases{
//            if joint.rawValue ==  {
//                self.name = joint
//                break
//            }
            self.name = .indexDIP
        }
        x = jointValues.x
        y = jointValues.y
        
        confidence = Double(jointValues.confidence)
    }
}
