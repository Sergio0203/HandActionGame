//
//  HandsDetector.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import Vision
import CoreImage
protocol HandsDetector {
    func detectHands(in image: CIImage, numberOfHands: Int) -> [HandModel]
}

protocol HandsML {
    func getMLMultiArray() -> MLMultiArray?
}
