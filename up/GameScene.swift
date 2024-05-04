//
//  GameScene.swift
//  up
//
//  Created by akash kumar on 5/1/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var sprite:SKSpriteNode?
    private var back:SKTileMapNode?
    
    override func didMove(to view: SKView) {
        print(" did move ")
        if let back = childNode(withName: "rocks") as? SKTileMapNode {
            self.back=back
            physics()
        }
        addSprite()
        let cameraNode = SKCameraNode()
            
        cameraNode.position = CGPoint(x: 0, y: 0)
        cameraNode.addChild(SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20)))
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        
    }
    func addSprite()->Void{
        var texts:[SKTexture]? = Array()
        for i in 1...10{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "w\(i)")) == nil {
                print("\(i) nilled ")
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        
            sprite = childNode(withName: "sprite") as? SKSpriteNode
            sprite?.physicsBody = SKPhysicsBody(rectangleOf: sprite!.size)
            print("phy body ",sprite!.physicsBody)
        sprite?.physicsBody?.categoryBitMask = 1
        sprite?.anchorPoint = CGPoint(x:0.5,y:0.5)
            sprite?.physicsBody?.isDynamic = true
            sprite?.physicsBody?.contactTestBitMask = 2
            sprite?.physicsBody?.collisionBitMask = 2
        sprite!.run(SKAction.repeatForever(anim))
//
        
        
    }
    
    func physics()->Void{
        let map = self.back!
        let startLocation = map.position
        let tileSize = map.tileSize
        let hW = CGFloat(map.numberOfColumns) / 2.0 * tileSize.width
        let hH = CGFloat(map.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<map.numberOfColumns
        {
            for row in 0..<map.numberOfRows {
                if let tileDef = map.tileDefinition(atColumn: col, row: row){
                    let tileArray = tileDef.textures
                    let tileText = tileArray[0]
                    let x = CGFloat(col) * tileSize.width - hW + (tileSize.width/2)
                    let y = CGFloat(row) * tileSize.height - hH + (tileSize.height/2)
                    
                    let tileNode = SKSpriteNode()
                    tileNode.size = CGSizeMake(tileSize.width, tileSize.height)
                    tileNode.position = CGPoint(x:x,y:y)
                    tileNode.physicsBody = SKPhysicsBody(texture:tileText, size: CGSize(width:tileText.size().width, height:tileText.size().height))
                    tileNode.physicsBody?.categoryBitMask = 2
                    tileNode.physicsBody?.contactTestBitMask = 1
                    tileNode.physicsBody?.collisionBitMask = 1
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 29
//                    tileNode.anchorPoint = .zero
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
                    
                    
            }
        }
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//        sprite?.position = pos
        let vect = CGVectorMake(0,150)
        let vect2 = CGVectorMake(-50,0)
        let vect3 = CGVectorMake(50,0)
        print(" applying vect ",vect)
        print( pos.x , sprite!.position.x )
        if( pos.x <=  sprite!.position.x){
            print(" applying x-ve\n")
            guard sprite?.physicsBody?.applyImpulse(vect2) != nil else {
                
                print(" nilled 1",sprite!.physicsBody)
                return
            }
        }
        if( pos.y >=  sprite!.position.y){
            print(" applying y")
            guard sprite?.physicsBody?.applyImpulse(vect) != nil else {
                
                print(" nilled 2",sprite!.physicsBody)
                return
            }
        }
        if( pos.x >=  sprite!.position.x){
            print("applying x+ve")
            guard sprite?.physicsBody?.applyImpulse(vect3) != nil else {
                
                print(" nilled 3",sprite!.physicsBody)
                return
            }
        }
        //print(sprite?.position, sprite?.physicsBody,sprite?.physicsBody?.velocity, sprite?.physicsBody?.isResting)
        print("vel ",sprite?.physicsBody?.velocity)
        
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
//        camera?.position.x = sprite!.position.x
//        camera?.position.y = sprite!.position.y
    }
}
