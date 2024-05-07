//
//  EndGameViewController.swift
//  up
//
//  Created by Srinidhi Sasidharan on 5/6/24.
//
import UIKit
import SpriteKit
import GameplayKit

import WebKit
class EndGameViewController: UIViewController {
    var  score = "0"
    @IBOutlet weak var retry: UIImageView!
    @IBOutlet weak var scorelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scorelLabel.text = score
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        retry.isUserInteractionEnabled = true
        retry.addGestureRecognizer(tapGestureRecognizer)
    }
    
     
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        print(" tappeeedddddddd d d  dd d d  d d d ")
        
//        self.present(GameViewController(), animated: true, completion: nil)
//        
//
//        self.dismiss(animated: true, completion: {
//            let vc =  GameViewController()
//            self.present(vc, animated: true, completion: {
//                print(" comleted ")
//            })
//        })
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc : GameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        
        vc.view.frame = (self.view?.frame)!

        vc.view.layoutIfNeeded()

        UIView.transition(with: self.view!, duration: 0.3, options: .transitionFlipFromRight, animations:

        {
        self.view?.window?.rootViewController = vc

        }, completion: { completed in
            print(" completed ")
        })

        // Your action
    }
    }
    

