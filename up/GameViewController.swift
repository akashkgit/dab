//
//  GameViewController.swift
//  levels
//
//  Created by Srinidhi Sasidharan on 5/2/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBAction func levelOneAction(_ sender: Any) {
        let levelOneView = LevelOneViewController()
        levelOneView.levelOneScreen()
        self.present(levelOneView,animated: true,completion: nil)
    }
    

    @IBAction func levelTwoAction(_ sender: Any) {
        let levelTwoView = LevelTwoViewController()
        levelTwoView.levelTwoScreen()
        self.present(levelTwoView,animated: true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
