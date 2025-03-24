//
//  GameScene.swift
//  Poc IA
//
//  Created by Sérgio César Lira Júnior on 24/03/25.
//
import SpriteKit
class GameScene: SKScene {
    static func create() -> SKScene {
        let scene = GameScene(size: .init(width: 1920, height: 1080))
        scene.scaleMode = .aspectFill
        scene.anchorPoint = .init(x: 0.5, y: 0.5)
        return scene
    }
    
}
