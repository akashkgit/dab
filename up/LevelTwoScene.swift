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
    enum id: UInt32{
        case sprite = 1
        case bricks  = 2
        case movers = 4
        case blade = 8192
        case deduce = 8
        case coin = 16
        case spikes = 32
        case win = 64
        case rocks = 128
        case stationary = 256
        case bridges = 512
        case gems = 1024
        case firewoods = 2048
        case waterGems = 4096
    }
    var won: Bool = false
    private var win:SKSpriteNode?
    private var spriteStat:SKSpriteNode?
    private var runAnim : SKAction = SKAction()
    private var idleAnim : SKAction = SKAction()
    private var obstacles:[String] = ["falls","wallsBk"]//["waterNode","waterfall"]
    private var logLst:[SKSpriteNode] = Array()
    private var rockLst:[SKSpriteNode] = Array()
    private var bridgeLst:[SKSpriteNode] = Array()
    private var back:SKTileMapNode?
    private var curState: spriteState = spriteState.idle
    private var prevState: spriteState? = nil
    private var fireWoodLst:[String] = Array()
    private var waterBallLst:[String] = Array()
    private var gemLst:[String] = Array()
    var timer:Int = 13
    let gems = ["gem1":10,"gem2":18,"gem3":10,"gem4":12,"gem5":10,"gem6":11,"gem7":12,"gem8":10,"gem9":7,"gem10":12,"gem11":13,"gem12":4,"gem13":10,"gem14":12,"gem15":11,"gem16":10]
    private var stats:gameStats = gameStats(score:0, scoreNode: SKLabelNode(fontNamed: "Chalkduster"), life:20, lifeNode: SKLabelNode(fontNamed: "Chalkduster"))
    let gameEnd = SKLabelNode(fontNamed: "Chalkduster")
    func countDown(){
        timer -= 1
        for (key,value) in gems{
            if(value == timer){
                print("gems disappears")
                if let gemNode = self.childNode(withName: key) as? SKSpriteNode {
                    gemNode.removeFromParent()
                }
            }
        }
    }
    
    
  
    override func didMove(to view: SKView) {
        print(self.view?.window?.rootViewController)
        physicsWorld.contactDelegate = self
        for i in obstacles {
            if let back = childNode(withName: i) as? SKTileMapNode {
                self.back=back
                physics(nodeName:i)
                //tileMapPhysicsBody(map: back)
            }
        }
        Nophysics(nodeName: "waterNode")
        Nophysics(nodeName: "fieryWater")
        
        let cameraNode = SKCameraNode()
            
        cameraNode.position = CGPoint(x: 0, y: 0)
//        cameraNode.addChild(SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20)))
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        for i in ["Log1","Log3","Log4","Log5","Log6"] {
            print("Moving logs")
            addMovingLogs(i)
        }
        for i in ["rock4"]{
            addMovingRocks(i,imageName: "rocky1")
        }
   
        for i in ["t1","t2","t3","t4"]{
            addStationaries(i, imageName: "t1")
        }
        for i in ["t5","t6","t7"]{
            addStationaries(i, imageName: "t2")
        }
        
        addStationaries("t8", imageName: "t3")
        
        for i in ["bridge1","bridge3","bridge4"]{
            addMovingBridges(i, imageName: "bridge2")
        }
        
        for i in ["bridge2","bridge5"]{
            addMovingBridges(i, imageName: "bridge1")
        }
        for i in ["gem1","gem11","gem12","gem13"]{
            addGems(i, imageName: "gem1")
        }
        for i in ["gem14","gem15","gem16","gem2"]{
            addGems(i, imageName: "gem2")
        }
        for i in ["gem3","gem5","gem6","gem7"]{
            addGems(i, imageName: "gems3")
        }
        for i in ["gem4","gem8","gem9","gem10"]{
            addGems(i, imageName: "gems5")
        }
        for i in ["w1","w2","w3","w4","w5","w6"]{
            addFireWoods(i, imageName: "firePoints")
        }
        
        for i in ["wa1","wa2","wa3","wa4","wa5"]{
            addWaterGems(i, imageName: "balls")
        }
        
        addFireWoods("f2", imageName: "fu2")
        addFireWoods("f1", imageName: "fuel")
        addFireWoods("f3", imageName: "fu3")
        
        let log = childNode(withName: "rock2") as? SKSpriteNode
    log?.texture = SKTexture(imageNamed: "rocky3")
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
        print("phy body ",log!.physicsBody)
    
        log?.anchorPoint = CGPoint(x:0.5,y:0.5)
        log?.physicsBody?.isDynamic = false
        //log?.physicsBody?.contactTestBitMask = id.bricks.rawValue
    log?.physicsBody?.categoryBitMask = id.stationary.rawValue
    
    log?.physicsBody?.affectedByGravity = false
 
    
    log?.physicsBody?.allowsRotation = false
    log?.physicsBody?.linearDamping = 0
    
    log?.zPosition = 10
        stats.scoreNode.text = String("Score: \(stats.score)")
        stats.scoreNode.fontColor = SKColor.white
        
        
        stats.lifeNode.text = String("life: \(stats.life)")
        stats.lifeNode.fontColor = SKColor.white
        let totalWidth = stats.scoreNode.frame.width + stats.lifeNode.frame.width + 15
        
        
        stats.lifeNode.position = CGPoint(x: stats.lifeNode.frame.width + 5 - (frame.width/2), y:frame.height/2 - 80)
        stats.scoreNode.position = CGPoint(x: frame.width/2 - 5 - stats.scoreNode.frame.width , y:frame.height/2 - 80)
        stats.lifeNode.zPosition = 1000
        stats.scoreNode.zPosition = 1000
        scene!.camera!.addChild(stats.scoreNode)
        scene!.camera!.addChild(stats.lifeNode)
        
        addSprite()
        
        print("levelTwoMoved")
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(countDown),SKAction.wait(forDuration: 1)])))
        addWin()
    }
    
    func addMovingBridges(_ name:String?, imageName:String) -> Void{
        
//        var texts:[SKTexture]? = Array()
        
        //print(self.children)
        
            let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
           //print("phy body ",log!.physicsBody)
        
            log?.anchorPoint = CGPoint(x:0.5,y:0.5)
            log?.physicsBody?.isDynamic = true
            log?.physicsBody?.collisionBitMask = 0
        log?.physicsBody?.categoryBitMask = id.bridges.rawValue | id.sprite.rawValue
        log?.physicsBody?.contactTestBitMask =  id.sprite.rawValue
   
        log?.physicsBody?.affectedByGravity = false
            log?.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        //log?.physicsBody?.friction = 1
        log?.physicsBody?.allowsRotation = false
        //log?.physicsBody?.linearDamping = 0
        //log?.physicsBody?.restitution = 0
        log?.zPosition = 40
        bridgeLst.append(log!)
        
        
//        sprite!.run(SKAction.repeatForever(anim))
//
        
    }
    
    func addMovingRocks(_ name:String?, imageName:String) -> Void{
        
//        var texts:[SKTexture]? = Array()
        
        //print(self.children)
        
            let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
           //print("phy body ",log!.physicsBody)
        
            log?.anchorPoint = CGPoint(x:0.5,y:0.5)
            log?.physicsBody?.isDynamic = true
            //log?.physicsBody?.contactTestBitMask = id.bricks.rawValue
        log?.physicsBody?.categoryBitMask = id.rocks.rawValue
        log?.physicsBody?.contactTestBitMask = id.bricks.rawValue | id.sprite.rawValue | id.movers.rawValue
        
        log?.physicsBody?.collisionBitMask = id.bricks.rawValue
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
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
            //print("phy body ",log!.physicsBody)
        log?.physicsBody?.categoryBitMask = id.movers.rawValue
        
            log?.anchorPoint = CGPoint(x:0.5,y:0.5)
            log?.physicsBody?.isDynamic = true
            log?.physicsBody?.contactTestBitMask = id.bricks.rawValue | id.rocks.rawValue
        log?.physicsBody?.collisionBitMask = id.bricks.rawValue
        log?.physicsBody?.affectedByGravity = false
            log?.physicsBody?.velocity = CGVector(dx: -300, dy: 0)
        log?.physicsBody?.allowsRotation = false
        log?.physicsBody?.linearDamping = 0
        
        log?.zPosition = 10
            logLst.append(log!)
        
        
//        sprite!.run(SKAction.repeatForever(anim))
//
        
    }
    
    func addGems(_ name:String?, imageName:String?){
        let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName!)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
        //print("phy body ",log!.physicsBody)
    
        log?.anchorPoint = CGPoint(x:0.5,y:0.5)
        log?.physicsBody?.isDynamic = false
        //log?.physicsBody?.contactTestBitMask = id.bricks.rawValue
    log?.physicsBody?.categoryBitMask = id.gems.rawValue
    
    log?.physicsBody?.affectedByGravity = false
 
    
    log?.physicsBody?.allowsRotation = false
    log?.physicsBody?.linearDamping = 0
    
    log?.zPosition = 10
        gemLst.append(name!)
        
    }
    func addStationaries(_ name:String?, imageName:String?){
        let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName!)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
        //print("phy body ",log!.physicsBody)
    
        log?.anchorPoint = CGPoint(x:0.5,y:0.5)
        log?.physicsBody?.isDynamic = false
        //log?.physicsBody?.contactTestBitMask = id.bricks.rawValue
    log?.physicsBody?.categoryBitMask = id.stationary.rawValue
    
    log?.physicsBody?.affectedByGravity = false
 
    
    log?.physicsBody?.allowsRotation = false
    log?.physicsBody?.linearDamping = 0
    
    log?.zPosition = 10
    }
    
    func addFireWoods(_ name:String?, imageName:String?){
        let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName!)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
        //print("phy body ",log!.physicsBody)
    
        log?.anchorPoint = CGPoint(x:0.5,y:0.5)
        log?.physicsBody?.isDynamic = false
        log?.physicsBody?.contactTestBitMask = id.sprite.rawValue
        log?.physicsBody?.collisionBitMask = id.sprite.rawValue
    log?.physicsBody?.categoryBitMask = id.firewoods.rawValue
    
    log?.physicsBody?.affectedByGravity = false

    
    log?.physicsBody?.allowsRotation = false
    log?.physicsBody?.linearDamping = 0
    
    log?.zPosition = 10
        fireWoodLst.append(name!)
    }
    
    func addWaterGems(_ name:String?, imageName:String?){
        let log = childNode(withName: name!) as? SKSpriteNode
        log?.texture = SKTexture(imageNamed: imageName!)
        log!.physicsBody = SKPhysicsBody(rectangleOf: log!.size)
        //print("phy body ",log!.physicsBody)
    
        log?.anchorPoint = CGPoint(x:0.5,y:0.5)
        log?.physicsBody?.isDynamic = false
        log?.physicsBody?.contactTestBitMask = id.sprite.rawValue
        log?.physicsBody?.collisionBitMask = id.sprite.rawValue
    log?.physicsBody?.categoryBitMask = id.waterGems.rawValue
    
    log?.physicsBody?.affectedByGravity = false

    
    log?.physicsBody?.allowsRotation = false
    log?.physicsBody?.linearDamping = 0
    
    log?.zPosition = 10
        waterBallLst.append(name!)
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
            
            spriteStat?.physicsBody?.categoryBitMask = 1 | id.bridges.rawValue
            spriteStat?.physicsBody?.mass = 20
            spriteStat?.anchorPoint = CGPoint(x:0.5,y:0.5)
            spriteStat?.physicsBody?.isDynamic = true
        spriteStat?.zPosition = 500
        spriteStat?.physicsBody?.contactTestBitMask = 2 | id.coin.rawValue |  id.blade.rawValue | id.rocks.rawValue | id.bridges.rawValue | id.firewoods.rawValue
        | id.waterGems.rawValue | id.gems.rawValue | id.deduce.rawValue | id.win.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 2 | 4 | id.coin.rawValue | id.blade.rawValue | id.movers.rawValue | id.stationary.rawValue | id.rocks.rawValue | 0
        | id.firewoods.rawValue | id.waterGems.rawValue | id.gems.rawValue | id.deduce.rawValue
            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    
    func addWin()->Void{
        
        print("Called")
        let spriteStat = childNode(withName: "win") as? SKSpriteNode
        self.win = spriteStat
            spriteStat?.physicsBody = SKPhysicsBody(rectangleOf: spriteStat!.size)
            //("phy body ",spriteStat!.physicsBody)
        spriteStat?.texture = SKTexture(imageNamed: "win")
        spriteStat?.physicsBody?.categoryBitMask = id.win.rawValue
            
        spriteStat?.physicsBody?.affectedByGravity = false
            spriteStat?.anchorPoint = CGPoint(x:0.5,y:0.5)
            spriteStat?.physicsBody?.isDynamic = true
        spriteStat?.physicsBody?.contactTestBitMask = id.sprite.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 0
//            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    func Nophysics(nodeName name:String)->Void{
        let map = childNode(withName: name) as! SKTileMapNode//self.back!
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
                    tileNode.physicsBody?.categoryBitMask = id.deduce.rawValue
//                    tileNode.physicsBody?.contactTestBitMask = 1
                    tileNode.physicsBody?.collisionBitMask = id.sprite.rawValue | id.win.rawValue
                    tileNode.physicsBody?.contactTestBitMask = id.sprite.rawValue
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = true
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 50
                    
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
                    tileNode.physicsBody?.collisionBitMask = id.movers.rawValue | id.rocks.rawValue
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
        print("Inside didbegin",a,b)
        if(a != nil && b != nil){
        if( ["falls"].contains(a) && ["rock2","rock4"].contains(b)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            //print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            //print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            
        }
        
        if( ["falls"].contains(a) && ["Log1","Log3","Log4","Log5","Log6"].contains(b)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            //print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            //print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            
        }
        
        if( ["rock2","rock4"].contains(b) && ["Log1","Log3","Log4","Log5","Log6"].contains(a)  ){
            //print("Inside didbegin if")
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            //print("before",vel?.dx, vel?.dy)
            contact.bodyB.node!.physicsBody!.velocity = (CGVector(dx: (vel?.dx)! < 0 ? -200 : 200 , dy:vel!.dy))
            //print(" collision",contact.bodyB.node!.physicsBody!.velocity)
            
        }
       
            if( (fireWoodLst.contains(a!) && "sprite" == b) || (fireWoodLst.contains(b!) && "sprite" == a)  ){
                let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
                let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
                
                stats.score = stats.score + 10
                stats.scoreNode.text = "Score: \(stats.score)"
                coin?.removeFromParent()
                
                var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("coin", waitForCompletion: false)])
                run(sound)
                
                
            }
            
            
            if( (waterBallLst.contains(a!) && "sprite" == b) || (waterBallLst.contains(b!) && "sprite" == a)  ){
                let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
                let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
                stats.life = stats.life - 1
                stats.lifeNode.text = "Life: \(stats.life)"
                stats.score = stats.score - 10
                stats.scoreNode.text = "Score: \(stats.score)"
                coin?.removeFromParent()
                
                var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("coin", waitForCompletion: false)])
                run(sound)
                
                
            }
            if( (gemLst.contains(a!) && "sprite" == b) || (gemLst.contains(b!) && "sprite" == a)  ){
                let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
                let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
                
                stats.score = stats.score + 100
                stats.scoreNode.text = "Score: \(stats.score)"
                coin?.removeFromParent()
                
                var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("coin", waitForCompletion: false)])
                run(sound)
                
                
            }
            if( ("fieryWater" == a && "sprite" == b) || ("fieryWater" == b && "sprite" == a)  ){
                let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
                let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
                stats.life = stats.life - 1
                stats.lifeNode.text = "Life: \(stats.life)"
                stats.score = stats.score - 20
                stats.scoreNode.text = "Score: \(stats.score)"
                coin?.removeFromParent()
                
                var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("wrong", waitForCompletion: false)])
                run(sound)
                
                
            }
            
            if( ("waterNode" == a && "sprite" == b) || ("waterNode" == b && "sprite" == a)  ){
                let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
                let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
                stats.life = stats.life - 1
                stats.lifeNode.text = "Life: \(stats.life)"
                stats.score = stats.score - 20
                stats.scoreNode.text = "Score: \(stats.score)"
                coin?.removeFromParent()
                
                var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("wrong", waitForCompletion: false)])
                run(sound)
                
                
            }
            
            if( ("win" == a && "sprite" == b) || ("win" == b && "sprite" == a)  && won == false ){
                print("I won")
                won = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let vc : EndGameViewController = storyboard.instantiateViewController(withIdentifier: "EndGameViewController") as! EndGameViewController
                vc.score = String(stats.score)
                vc.view.frame = (self.view?.frame)!

                vc.view.layoutIfNeeded()

                UIView.transition(with: self.view!, duration: 0.3, options: .transitionFlipFromRight, animations:

                {
                self.view?.window?.rootViewController = vc

                }, completion: { completed in
                    
                })

                
//                let leveltwo = LevelTwoViewController()
//                leveltwo.EndScreen()
            }
        }
        
       
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if(stats.life <= 0){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let vc : EndGameViewController = storyboard.instantiateViewController(withIdentifier: "EndGameViewController") as! EndGameViewController
            vc.score = String(stats.score)
            vc.view.frame = (self.view?.frame)!

            vc.view.layoutIfNeeded()

            UIView.transition(with: self.view!, duration: 0.3, options: .transitionFlipFromRight, animations:

            {
            self.view?.window?.rootViewController = vc

            }, completion: { completed in
                
            })


        }
        if( spriteStat!.physicsBody!.velocity.dy <= 10  && curState == .jump){
            spriteStat?.removeAllActions()
            spriteStat!.run(SKAction.repeatForever(idleAnim))
            spriteStat?.physicsBody?.allowsRotation = true
            prevState =  curState
            curState = .idle
        }
       
        
        if ((spriteStat!.position.y) > 50){
            camera?.position.y = spriteStat!.position.y
        }
        else {
            camera?.position.y = 0
        }
        
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
                node.physicsBody!.velocity = CGVectorMake((-1 * node.physicsBody!.velocity.dx),node.physicsBody!.velocity.dy)
            }
            
            
            
        }
        
        for i in bridgeLst {
            
            let node = (i as SKSpriteNode)
            
//            if (node.position.x >= getBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.x <= getlBound(node.size.width) || node.position.x >= getrBound(node.size.width)){
//                ("*** OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                node.physicsBody!.velocity = CGVectorMake((-1 * node.physicsBody!.velocity.dx),node.physicsBody!.velocity.dy)
            }
            
            
            
        }
    }
}

