import Vision
import Foundation
enum HandChirality: String {
    case left
    case right
    case unknown
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
            chirality = .unknown
        }
        
        do {
            for joint in VNHumanHandPoseObservation.JointName.allCases {
                joints.append(JointModel(jointCase: joint, jointValues: try hand.recognizedPoint(joint)))
            }
        } catch {
            assertionFailure("Impossible to identifie the joints")
        }
    }
}

extension HandModel: HandsML {
    func getMLMultiArray() -> MLMultiArray {
        var multiarray = MLMultiArray()
        do {
            multiarray = try MLMultiArray(shape: [1, 3, 21], dataType: .float32)
            
            for (index, joint) in joints.enumerated() {
                multiarray.shape[0]

            }
        } catch {
            assertionFailure("Could Not get MLMultiArray")
        }
        return multiarray
    }
}
