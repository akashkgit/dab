//
//  LevelOneViewController.swift
//  levels
//
//  Created by Srinidhi Sasidharan on 5/5/24.
//

import UIKit
import SpriteKit
import GameplayKit

class LevelOneViewController: UIViewController {
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .fullScreen
    }
    func levelOneScreen(){
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .fill
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
