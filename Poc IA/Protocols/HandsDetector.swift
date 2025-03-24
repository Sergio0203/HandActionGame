//
//  HandsDetector.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import Vision
protocol HandsDetector {
    func detectHands(in image: CVPixelBuffer, numberOfHands: Int) -> [HandModel]
}
