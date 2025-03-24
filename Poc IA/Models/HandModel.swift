import Vision
import Foundation
enum HandChirality: String {
    case left
    case right
    case unknow
}

struct HandModel {
    var joints: [JointModel] = []
    var chirality: HandChirality
}

extension HandModel {
    init(hand: VNHumanHandPoseObservation) {
        
        switch hand.chirality {
        case .left:
            chirality = .left
        case .right:
            chirality = .right
        case .unknown:
            chirality = .unknow
        }
        
        do {
            for joint in try hand.recognizedPoints(.all) {
                joints.append(JointModel(jointName: joint.key, jointValues: joint.value))
            }
        } catch {
            assertionFailure("Impossible to identifie the joints")
        }
    }
}
