//
//  LevelOneViewController.swift
//  levels
//
//  Created by Srinidhi Sasidharan on 5/5/24.
//

import UIKit
import SpriteKit
import GameplayKit

class LevelTwoViewController: UIViewController {
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .fullScreen
    }
    func levelTwoScreen(){
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "LevelTwoScene") {
                scene.scaleMode = .fill
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func EndScreen(){
        self.performSegue(withIdentifier: "end", sender: self)
    }
}
