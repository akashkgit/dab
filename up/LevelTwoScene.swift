//
//  LevelTwoScene.swift
//  up
//
//  Created by Srinidhi Sasidharan on 5/5/24.
//

import os
import SpriteKit
import GameplayKit


class LevelTwoScene: SKScene, SKPhysicsContactDelegate {
    
    private var spriteStat:SKSpriteNode?
    private var runAnim : SKAction = SKAction()
    private var idleAnim : SKAction = SKAction()
    private var obstacles:[String] = ["falls"]//["waterNode","waterfall"]
    private var logLst:[SKSpriteNode] = Array()
    private var rockLst:[SKSpriteNode] = Array()

    private var back:SKTileMapNode?
    private var curState: spriteState = spriteState.idle
    private var prevState: spriteState? = nil
    

    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        for i in obstacles {
            if let back = childNode(withName: i) as? SKTileMapNode {
                self.back=back
                physics(nodeName:i)
                //tileMapPhysicsBody(map: back)
            }
        }
        let cameraNode = SKCameraNode()
            
        cameraNode.position = CGPoint(x: 0, y: 0)
//        cameraNode.addChild(SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20)))
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        for i in ["Log1","Log3","Log4","Log5"] {
            print("Moving logs")
            addMovingLogs(i)
        }
        for i in ["rock4","rock5"]{
            addMovingRocks(i,imageName: "rocky1")
        }
        for i in ["rock1","rock3"]{
            addMovingRocks(i,imageName: "rocky2")
        }
        
        addMovingRocks("rock2",imageName: "rocky3")
        addSprite()
        print("levelTwoMoved")
    }
    
    func addMovingRocks(_ name:String?, imageName:String) -> Void{
        
//        var texts:[SKTexture]? = Array()
        
        //print(self.children)
        
            let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName)
        log?.physicsBody = SKPhysicsBody(texture: log!.texture!, size: log!.texture!.size())
            print("phy body ",log!.physicsBody)
            log?.physicsBody?.categoryBitMask = 4
        
            log?.anchorPoint = CGPoint(x:0.5,y:0.5)
            log?.physicsBody?.isDynamic = true
            //log?.physicsBody?.contactTestBitMask = id.bricks.rawValue
        
        log?.physicsBody?.contactTestBitMask = id.bricks.rawValue | id.sprite.rawValue | id.movers.rawValue
        log?.physicsBody?.categoryBitMask = id.rocks.rawValue
        log?.physicsBody?.collisionBitMask = id.bricks.rawValue | id.movers.rawValue
        log?.physicsBody?.affectedByGravity = false
            log?.physicsBody?.velocity = CGVector(dx: -300, dy: 0)
        
        log?.physicsBody?.allowsRotation = false
        log?.physicsBody?.linearDamping = 0
        
        log?.zPosition = 10
        rockLst.append(log!)
        
        
//        sprite!.run(SKAction.repeatForever(anim))
//
        
    }
    func addMovingLogs(_ name:String?) -> Void{
        
//        var texts:[SKTexture]? = Array()
        
        //print(self.children)
        
            let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: "log")
        log?.physicsBody = SKPhysicsBody(texture: log!.texture!, size: log!.texture!.size())
            //print("phy body ",log!.physicsBody)
        log?.physicsBody?.categoryBitMask = id.movers.rawValue
        
            log?.anchorPoint = CGPoint(x:0.5,y:0.5)
            log?.physicsBody?.isDynamic = true
            log?.physicsBody?.contactTestBitMask = id.bricks.rawValue | id.rocks.rawValue
        log?.physicsBody?.collisionBitMask = id.bricks.rawValue | id.rocks.rawValue
        log?.physicsBody?.affectedByGravity = false
            log?.physicsBody?.velocity = CGVector(dx: -300, dy: 0)
        log?.physicsBody?.allowsRotation = false
        log?.physicsBody?.linearDamping = 0
        
        log?.zPosition = 10
            logLst.append(log!)
        
        
//        sprite!.run(SKAction.repeatForever(anim))
//
        
    }
    
    func addSprite()->Void{
        var texts:[SKTexture]? = Array()
        for i in 1..<8{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "w\(i)")) == nil {
                
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        idleAnim = anim
        texts = Array()
        for i in 1...4{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "wr\(i)")) == nil {
                
            }
        }
         runAnim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        
            spriteStat = childNode(withName: "sprite") as? SKSpriteNode
            spriteStat?.physicsBody = SKPhysicsBody(rectangleOf: spriteStat!.size)
            
            spriteStat?.physicsBody?.categoryBitMask = 1
            spriteStat?.physicsBody?.mass = 20
            spriteStat?.anchorPoint = CGPoint(x:0.5,y:0.5)
            spriteStat?.physicsBody?.isDynamic = true
        spriteStat?.physicsBody?.contactTestBitMask = 2 | id.coin.rawValue | id.life.rawValue | id.blade.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 2 | 4 | id.coin.rawValue | id.blade.rawValue
            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    
    
    func tileMapPhysicsBody(map : SKTileMapNode){
        let tileMap = map
        let startLoc: CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns)/2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows)/2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns{
            for row in 0..<tileMap.numberOfRows{
                if let tileDef = tileMap.tileDefinition(atColumn: col, row: row){
                    
                    let tileArray = tileDef.textures
                    let tileTex = tileArray[0]
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width/2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height/2)
                    
                    let tileNode = SKSpriteNode(texture: tileTex)
                    tileNode.position = CGPoint(x: x, y: y)
                    //print("tilenode x,y",tileNode.position)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTex, size: CGSize(width:tileTex.size().width,height: tileTex.size().height))
                    tileNode.physicsBody?.categoryBitMask = 2
//                    tileNode.physicsBody?.contactTestBitMask = 1
                    tileNode.physicsBody?.collisionBitMask = id.life.rawValue
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 2
                    tileNode.anchorPoint = .zero
                    
                    
                    
                    tileNode.position = CGPoint(x:tileNode.position.x + startLoc.x,y:tileNode.position.y + startLoc.y)
                    self.addChild(tileNode)
                    
                }
                    
            }
        }
    }
    func physics(nodeName name:String)->Void{
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
                    let tileText = name == "drums" ?SKTexture(imageNamed: "t4") : tileArray[0]
                    let x = CGFloat(col) * tileSize.width - hW + (tileSize.width/2)
                    let y = CGFloat(row) * tileSize.height - hH + (tileSize.height/2)
                    
                    let tileNode = SKSpriteNode()
                    
//                    if (name == "drums" ){
//                        map.setTileGroup(nil, forColumn: col, row: row)
//                        tileNode.texture = tileText
//                     
//                    }
                    tileNode.name = name
                    tileNode.size = CGSizeMake(tileSize.width, tileSize.height)
                    tileNode.position = CGPoint(x:x,y:y)
                    tileNode.physicsBody = SKPhysicsBody(texture:tileText, size: CGSize(width:tileText.size().width, height:tileText.size().height))
                    tileNode.physicsBody?.categoryBitMask = id.bricks.rawValue
//                    tileNode.physicsBody?.contactTestBitMask = 1
                    tileNode.physicsBody?.collisionBitMask = id.life.rawValue | id.movers.rawValue | id.rocks.rawValue
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 29
                    
//                    if(name == "drums"){
//                        tileNode.physicsBody?.isDynamic = true
//                        tileNode.physicsBody?.mass = 10
//                        tileNode.physicsBody?.allowsRotation = false
//                        tileNode.physicsBody?.affectedByGravity = true
//                      
////                        tileNode.blendMode = SKBlendMode.replace
//                        
//                    }
//                    tileNode.anchorPoint = .zero
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
                    
                    
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//        sprite?.position = pos
        let vect = CGVectorMake(0,9550)
        let vect2 = CGVectorMake(-3550,0)
        let vect3 = CGVectorMake(3550,0)
        
        
        if( pos.x <=  spriteStat!.position.x){
           
            guard spriteStat?.physicsBody?.applyImpulse(vect2) != nil else {
                
               
                return
            }
        }
        if( pos.y >=  spriteStat!.position.y){
           
            guard spriteStat?.physicsBody?.applyImpulse(vect) != nil else {
                spriteStat?.removeAllActions()
                spriteStat!.run(SKAction.repeatForever(runAnim))
                prevState = curState
                curState = .jump
                spriteStat?.physicsBody?.allowsRotation = false
                
               
                return
            }
            spriteStat?.removeAllActions()
            spriteStat!.run(SKAction.repeatForever(runAnim))
            spriteStat?.physicsBody?.allowsRotation = false
            spriteStat?.physicsBody?.angularVelocity = 0
            
            prevState = curState
            curState = .jump
           
        }
        if( pos.x >=  spriteStat!.position.x){
            
            guard spriteStat?.physicsBody?.applyImpulse(vect3) != nil else {
                
                
                return
            }
        }
        //(sprite?.position, sprite?.physicsBody,sprite?.physicsBody?.velocity, sprite?.physicsBody?.isResting)
       
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node?.name
        let b = contact.bodyB.node?.name
        //print("Inside didbegin",a,b)
        if( ["falls"].contains(a) && ["rock1","rock2","rock3","rock4","rock5"].contains(b)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            return
        }
        
        if( ["falls"].contains(a) && ["Log1","Log3","Log4","Log5"].contains(b)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            return
        }
        
        if( ["rock1","rock2","rock3","rock4","rock5"].contains(b) && ["Log1","Log3","Log4","Log5"].contains(a)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            return
        }
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
//        if( spriteStat!.physicsBody!.velocity.dy <= 10  && curState == .jump){
//            spriteStat?.removeAllActions()
//            spriteStat!.run(SKAction.repeatForever(idleAnim))
//            spriteStat?.physicsBody?.allowsRotation = true
//            prevState =  curState
//            curState = .idle
//        }
//        if ((spriteStat!.position.y) > 50){
//            camera?.position.y = spriteStat!.position.y
//        }
//        else {
//            camera?.position.y = 0
//        }
        
        let getlBound = {
            let sW = self.scene!.size.width
            let hW = sW/2
            let lb = -1 * hW + $0/2
            return lb
        }
        let getrBound = {
            let sW = self.scene!.size.width
            let hW = sW/2
            let rb = 1 * hW - $0/2
            return rb
        }
        
        let getLBound = {
            let sH = self.scene!.size.height
            let hH = sH / 2
            let lb = 1 * hH - $0/2
            return lb
        }
        
        let getUBound = { (nodeIn:SKSpriteNode) -> Double in
            
            let node:SKSpriteNode = nodeIn
            let lb : Double = node.userData?.value(forKey: "pos") as! Double
            return lb //+ node.size.height / 2
        }
        
        let getLowBound = { (nodeIn:SKSpriteNode) -> Double in
            
            let node:SKSpriteNode = nodeIn
            let lb : Double = node.userData?.value(forKey: "pos") as! Double
            return lb + node.size.height / 2 - 400
        }
        
        for i in logLst {
            
            let node = (i as SKSpriteNode)
            
//            if (node.position.x >= getBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.x <= getlBound(node.size.width) || node.position.x >= getrBound(node.size.width)){
//                ("*** OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)
            }
            
            
            
        }
        
        for i in rockLst {
            
            let node = (i as SKSpriteNode)
            
//            if (node.position.x >= getBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.x <= getlBound(node.size.width) || node.position.x >= getrBound(node.size.width)){
//                ("*** OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                node.physicsBody!.velocity = CGVectorMake((-1 * node.physicsBody!.velocity.dx)*2,node.physicsBody!.velocity.dy)
            }
            
            
            
        }
    }
}

