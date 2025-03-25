//
//  JointNames+AllCases.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import Vision
extension VNHumanHandPoseObservation.JointName: CaseIterable {
    public static var allCases: [VNHumanHandPoseObservation.JointName] {
        return [wrist, thumbCMC, thumbMP, thumbIP, thumbTip, indexMCP, indexPIP, indexDIP, indexTip, middleMCP, middlePIP, middleDIP, middleTip, ringMCP, ringPIP, ringDIP, ringTip, littleMCP, littlePIP, littleDIP, littleTip]
    }
}

