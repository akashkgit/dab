//
//  GameScene.swift
//  up
//
//  Created by akash kumar on 5/1/24.
//
import os
import SpriteKit
import GameplayKit
//struct Logger {
//    
//}
    

enum spriteState {
    case idle
    case jump
    
}

enum id: UInt32{
    case sprite = 1
    case bricks  = 2
    case movers = 4
    case blade = 8192
    case life = 8
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
struct gameStats{
    var score:Int
    var scoreNode:SKLabelNode
    
    var life:Int = 20
    var lifeNode:SKLabelNode
    var time = 0
    
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    let logger = Logger()
    private var spriteStat:SKSpriteNode?
    private var curState: spriteState = spriteState.idle
    private var prevState: spriteState? = nil
    private var hurtEffect = SKEmitterNode(fileNamed: "hurt")
    private var deadEffect = SKEmitterNode(fileNamed: "dead")
    private var spikeEffect = SKEmitterNode(fileNamed: "hurt")
    let audioCoin = SKAudioNode(fileNamed: "bg.mp3")
    private var spriteJump:SKSpriteNode?
    private var back:SKTileMapNode?
    private var win:SKSpriteNode?
    private var bladeTime:TimeInterval = 0
    private var runAnim : SKAction = SKAction()
    private var idleAnim : SKAction = SKAction()
    private var updateTime:TimeInterval = 0
    private var dead = false
    private var spikesTime:TimeInterval = 0
    private var obstacles:[String] = ["rocks","newRocks"]
    private var moversLst:[SKSpriteNode] = Array()
    private var bladeLst:[SKSpriteNode] = Array()
    private var bladeHLst:[SKSpriteNode] = Array()
    private var coinLst:[SKSpriteNode] = Array()
    private var rodLst:[SKSpriteNode] = Array()
    private var moversStrLst = ["mover2","mover3","mover4"]// "mover5", "mover6","mover7"]
    private var bladeStrLst = ["bb1","bb3"]
    private var coinStrLst = ["c1","c2","c3","c4","c5","c6","c7","c8","c9"]//,"c14","c15","c16","c17","c18","c19","c20"]
    private var hbladeStrLst = ["bb2", "bb4"]
    private var lStrLst = ["l1" , "l2"]
    private var stats:gameStats = gameStats(score:0, scoreNode: SKLabelNode(fontNamed: "Chalkduster"), life:8, lifeNode: SKLabelNode(fontNamed: "Chalkduster"))
    override func didMove(to view: SKView) {
//        (" did move ")
        
        let end = childNode(withName: "END") as! SKLabelNode
        end.text = " END OF LEVEL 1"
        audioCoin.autoplayLooped = false
        addChild(audioCoin)
        physicsWorld.contactDelegate = self
        for i in obstacles {
            if let back = childNode(withName: i) as? SKTileMapNode {
                self.back=back
                physics(nodeName:i)
            }
        }
        spikes(nodeName: "s1")
        addSprite()
        addWin()
        for i in moversStrLst{
            addMovers(i)
        }
        for i in bladeStrLst {
            addblade(i)
        }
        for i in hbladeStrLst{
            addHBlade(i)
        }
        for i in lStrLst {
            addLife(i)
        }
        for i in coinStrLst{
            addCoin(i)
        }
        let cameraNode = SKCameraNode()
            
        cameraNode.position = CGPoint(x: 0, y: 0)
//        cameraNode.addChild(SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20)))
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        
        
        stats.scoreNode.text = String("Score: \(stats.score)")
        stats.scoreNode.fontColor = SKColor.white
        
        
        stats.lifeNode.text = String("life: \(stats.life)")
        stats.lifeNode.fontColor = SKColor.white
        let totalWidth = stats.scoreNode.frame.width + stats.lifeNode.frame.width + 15
        
        
        stats.lifeNode.position = CGPoint(x: stats.lifeNode.frame.width + 5 - (frame.width/2), y:frame.height/2 - 50)
        stats.scoreNode.position = CGPoint(x: frame.width/2 - 5 - stats.scoreNode.frame.width , y:frame.height/2 - 50)
        scene!.camera!.addChild(stats.scoreNode)
        scene!.camera!.addChild(stats.lifeNode)
        // // print("scene : \(frame.height) - \(frame.midY) camera \(scene?.camera?.frame.height) \(scene?.camera?.frame.midY)")
        
        print(" did move done ")
        
    }
    
    func addblade(_  name:String?) -> Void{
        let blade = childNode(withName: name!) as? SKSpriteNode
    blade?.texture = SKTexture(imageNamed: "bladeb1")
    blade?.physicsBody = SKPhysicsBody(texture: blade!.texture!, size: blade!.texture!.size())
//        ("phy body ",blade!.physicsBody)
        blade?.physicsBody?.categoryBitMask = id.blade.rawValue
    
        blade?.anchorPoint = CGPoint(x:0.5,y:0.5)
        blade?.physicsBody?.isDynamic = true
        blade?.physicsBody?.contactTestBitMask = 4 | 1
        blade?.physicsBody?.collisionBitMask = 16
    blade?.physicsBody?.affectedByGravity = false
        blade?.physicsBody?.velocity = CGVector(dx: -75, dy: 0)
    blade?.physicsBody?.allowsRotation = false
    blade?.physicsBody?.linearDamping = 0
        blade?.run(SKAction.repeatForever(SKAction.rotate(byAngle: 45, duration: 0.2)))
    
    blade?.zPosition = 10
        bladeLst.append(blade!)
//    ("\(blade?.name) \(blade!.physicsBody?.velocity)")
    }
    func addHBlade(_  name:String?) -> Void{
        let blade = childNode(withName: name!) as? SKSpriteNode
    blade?.texture = SKTexture(imageNamed: "bladeb1")
    blade?.physicsBody = SKPhysicsBody(texture: blade!.texture!, size: blade!.texture!.size())
        ("phy body ",blade!.physicsBody)
        blade?.physicsBody?.categoryBitMask = id.blade.rawValue
    
        blade?.anchorPoint = CGPoint(x:0.5,y:0.5)
        blade?.physicsBody?.isDynamic = true
        blade?.physicsBody?.contactTestBitMask = 4 | 1
        blade?.physicsBody?.collisionBitMask = 16
    blade?.physicsBody?.affectedByGravity = false
        blade?.physicsBody?.velocity = CGVector(dx: 0, dy: -90)
    blade?.physicsBody?.allowsRotation = false
    blade?.physicsBody?.linearDamping = 0
        blade?.run(SKAction.repeatForever(SKAction.rotate(byAngle: 45, duration: 0.2)))
        blade?.userData = ["pos":blade?.physicsBody?.node?.position.y]
    blade?.zPosition = 10
        bladeHLst.append(blade!)
    ("\(blade?.name) \(blade!.physicsBody?.velocity)")
    }
    func addMovers(_ name:String?) -> Void{
        
//        var texts:[SKTexture]? = Array()
        
        
        let startIdx = name?.startIndex
        let numberIdx = name?.index(after:(name?.index(startIdx!, offsetBy: 4))!)
            let movers = childNode(withName: name!) as? SKSpriteNode
        // print(name)
        // print(numberIdx)
        
        let num = Int(name![numberIdx!...])
        movers?.texture = (num!) > 5 ?  SKTexture(imageNamed: "floaters1") : SKTexture(imageNamed: "floaters1")
        movers?.physicsBody = SKPhysicsBody(texture: movers!.texture!, size: movers!.texture!.size())
//            ("phy body ",movers!.physicsBody)
            movers?.physicsBody?.categoryBitMask = 4
        
            movers?.anchorPoint = CGPoint(x:0.5,y:0.5)
            movers?.physicsBody?.isDynamic = true
            movers?.physicsBody?.contactTestBitMask = 4 | 1
        movers?.physicsBody?.collisionBitMask = id.life.rawValue
        movers?.physicsBody?.affectedByGravity = false
            movers?.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        movers?.physicsBody?.allowsRotation = false
        movers?.physicsBody?.linearDamping = 0
        
        movers?.zPosition = 10
            moversLst.append(movers!)
        ("\(movers?.name) \(movers!.physicsBody?.velocity)")
        
//        sprite!.run(SKAction.repeatForever(anim))
//
        
    }
    func addSprite()->Void{
        var texts:[SKTexture]? = Array()
        for i in 1..<8{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "w\(i)")) == nil {
                ("\(i) nilled ")
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        idleAnim = anim
        texts = Array()
        for i in 1...4{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "wr\(i)")) == nil {
                ("\(i) nilled ")
            }
        }
         runAnim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        
            spriteStat = childNode(withName: "sprite") as? SKSpriteNode
            spriteStat?.physicsBody = SKPhysicsBody(rectangleOf: spriteStat!.size)
            ("phy body ",spriteStat!.physicsBody)
            spriteStat?.physicsBody?.categoryBitMask = 1
            spriteStat?.physicsBody?.mass = 20
            spriteStat?.anchorPoint = CGPoint(x:0.5,y:0.5)
            spriteStat?.physicsBody?.isDynamic = true
        spriteStat?.physicsBody?.node?.zPosition = 100
        spriteStat?.physicsBody?.contactTestBitMask = id.coin.rawValue | id.life.rawValue | id.blade.rawValue | id.spikes.rawValue | id.win.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 2 | 4 | id.coin.rawValue | id.blade.rawValue | id.spikes.rawValue
            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    func addWin()->Void{
        
        
        let spriteStat = childNode(withName: "win") as? SKSpriteNode
        self.win = spriteStat
            spriteStat?.physicsBody = SKPhysicsBody(rectangleOf: spriteStat!.size)
            ("phy body ",spriteStat!.physicsBody)
        spriteStat?.texture = SKTexture(imageNamed: "win")
        spriteStat?.physicsBody?.categoryBitMask = id.win.rawValue
            
        spriteStat?.physicsBody?.affectedByGravity = true
            spriteStat?.anchorPoint = CGPoint(x:0.5,y:0.5)
            spriteStat?.physicsBody?.isDynamic = true
//        spriteStat?.physicsBody?.contactTestBitMask = id.coin.rawValue | id.life.rawValue | id.blade.rawValue | id.spikes.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 2 | 4 | id.coin.rawValue | id.bricks.rawValue
//            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    func addLife(_ name:String?) -> Void{
        
        
        var texts:[SKTexture]? = Array()
        
        for i in 1...5{
            
//            if(i == 4){continue}
            let text = SKTexture(imageNamed: "l\(i)")
            
            if texts?.append(text) == nil {
                ("\(i) nilled ")
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.2)
        
        
            let movers = childNode(withName: name!) as? SKSpriteNode
        
        movers?.physicsBody = SKPhysicsBody(rectangleOf: movers!.size)
            ("phy body ",movers?.physicsBody)
        movers?.physicsBody?.categoryBitMask = id.life.rawValue
        
            movers?.anchorPoint = CGPoint(x:0.5,y:0.5)
            movers?.physicsBody?.isDynamic = true
//            movers?.physicsBody?.contactTestBitMask = 4 | 1
//            movers?.physicsBody?.collisionBitMask = 16
        movers?.physicsBody?.affectedByGravity = true
//            movers?.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        movers?.physicsBody?.allowsRotation = false
        
        movers?.physicsBody?.linearDamping = 0
        
        movers?.zPosition = 10
            rodLst.append(movers!)
        ("\(movers?.name) \(movers!.physicsBody?.velocity)")
        
        movers!.run(SKAction.repeatForever(anim))
//
        
    }
    func addCoin(_ name:String?) -> Void{
        
        
        var texts:[SKTexture]? = Array()
        
        for i in 1...9{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "c\(i) 1")) == nil {
                ("\(i) nilled ")
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.1)
        
        
            let movers = childNode(withName: name!) as? SKSpriteNode
        
        movers?.physicsBody = SKPhysicsBody(rectangleOf: movers!.size)
//            ("phy body ",movers!.physicsBody)
        movers?.scale(to: CGSize(width: 32, height: 32))
        movers?.physicsBody?.categoryBitMask = id.coin.rawValue
        
            movers?.anchorPoint = CGPoint(x:0.5,y:0.5)
            movers?.physicsBody?.isDynamic = true
//            movers?.physicsBody?.contactTestBitMask = 4 | 1
//            movers?.physicsBody?.collisionBitMask = 16
//        movers?.physicsBody?.affectedByGravity = true
//            movers?.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        movers?.physicsBody?.allowsRotation = false
        
        movers?.physicsBody?.linearDamping = 0
        
        movers?.zPosition = 10
            coinLst.append(movers!)
        ("\(movers?.name) \(movers!.physicsBody?.velocity)")
        
        movers!.run(SKAction.repeatForever(anim))
//
        
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
                    
                    tileNode.name = name
                    tileNode.size = CGSizeMake(tileSize.width, tileSize.height)
                    tileNode.position = CGPoint(x:x,y:y)
                    tileNode.physicsBody = SKPhysicsBody(texture:tileText, size: CGSize(width:tileText.size().width, height:tileText.size().height))
                    tileNode.physicsBody?.categoryBitMask = id.bricks.rawValue
                    tileNode.physicsBody?.contactTestBitMask = id.movers.rawValue | id.blade.rawValue
                    tileNode.physicsBody?.collisionBitMask = id.life.rawValue | id.win.rawValue
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
    
    
    func spikes(nodeName name:String)->Void{
        let map = childNode(withName: name) as! SKTileMapNode
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
                    tileNode.name = name
                    tileNode.size = CGSizeMake(tileSize.width, tileSize.height)
                    tileNode.position = CGPoint(x:x,y:y)
                    tileNode.physicsBody = SKPhysicsBody(texture:tileText, size: CGSize(width:tileText.size().width, height:tileText.size().height))
                    tileNode.physicsBody?.categoryBitMask = id.spikes.rawValue
//                    tileNode.physicsBody?.contactTestBitMask = 1
//                    tileNode.physicsBody?.collisionBitMask = id.life.rawValue
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
    
    private var touchCount = 5
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//        sprite?.position = pos
        touchCount -= 1
        let vect = CGVectorMake(0,9550)
        let vect2 = CGVectorMake(-3550,0)
        let vect3 = CGVectorMake(3550,0)
    
        if( pos.x <=  spriteStat!.position.x){
            
            guard spriteStat?.physicsBody?.applyImpulse(vect2) != nil else {
                
                (" nilled 1",spriteStat!.physicsBody)
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
                
                (" nilled 2",spriteStat!.physicsBody)
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
                
                print(" nilled 3",spriteStat!.physicsBody)
                return
            }
        }
        //(sprite?.position, sprite?.physicsBody,sprite?.physicsBody?.velocity, sprite?.physicsBody?.isResting)
        
        
        
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

        // Called before each frame is rendered
        
        //        if(sprite!.position.y >  camera!.position.y){
//        let msg = "\(spriteStat?.physicsBody?.velocity.dy, priva)"
//        
        updateTime = currentTime
    
        print(spriteStat!.position.y,"-", camera!.position.y,"-",scene!.size.height," half width ",scene!.size.height/2)
        if( !dead && touchCount <= 0 && spriteStat!.position.y <  camera!.position.y - scene!.size.height/2){
            dead = true
            var pos = spriteStat!.position
            pos.y +=  5
            deadEffect?.position = pos
            addChild(deadEffect!)
            
            
            
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("wrong", waitForCompletion: false)])
            run(sound)
//            life?.removeFromParent()
            deadEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 1),SKAction.removeFromParent(),SKAction.run(extractedFunc) ]))
            
            
            print(spriteStat!.position.y,"-", camera!.position.y,"-",scene!.size.height," half width ",scene!.size.height/2," --> caught")
        }
        ("\(spriteStat?.physicsBody?.velocity.dy):dy \(curState) \(prevState)")
        if( spriteStat!.physicsBody!.velocity.dy <= 10  && curState == .jump){
            spriteStat?.removeAllActions()
            spriteStat!.run(SKAction.repeatForever(idleAnim))
            spriteStat?.physicsBody?.allowsRotation = true
            prevState =  curState
            curState = .idle
        }
//        // print("\(win!.position.y) - \(spriteStat!.position.y) = \(win!.position.y -  spriteStat!.position.y)  ")
        if(win!.position.y -  spriteStat!.position.y > 200) {
            // print("\(win!.position.y) - \(spriteStat!.position.y) = \(win!.position.y -  spriteStat!.position.y)  ")
            if ((spriteStat!.position.y) > 50 && touchCount <= 0 ){
                camera?.position.y += 2
            }
            else {
                if (touchCount <= 0 ){
                    camera?.position.y += 2
                }
            }
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
        for i in moversLst {
            
            let node = (i as SKSpriteNode)
            
//            if (node.position.x >= getBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.x <= getlBound(node.size.width) || node.position.x >= getrBound(node.size.width)){
//                ("*** OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)
            }
            
            
            
        }
        for i in bladeLst {
            let node = (i as SKSpriteNode)
//            if (node.position.x >= getlBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.x <= getlBound(node.size.width) || node.position.x >= getrBound(node.size.width)){
//                ("*** OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)
            }
            
            
            
        }
        for i in bladeHLst {
            let node = (i as SKSpriteNode)
            (" pos \(node.position.y ),\(node.position.y): \(node.userData) to \(node.userData?.value(forKey: "pos") as! Double + 10) but \(getLowBound(node))")
//            if (node.position.x >= getlBound(node.size.width)){ node.physicsBody!.velocity = CGVectorMake(-1 * node.physicsBody!.velocity.dx,node.physicsBody!.velocity.dy)}
//            ("\(node.physicsBody?.velocity) \(node.name!) \(node.position.x) \(getlBound(node.size.width)) \(node.size.width)")
//            else if (i.position.x <= node.size.width / 2){ node.physicsBody.velocity = CGVectorMake(-1 * node.physicsBody.velocity.dx,node.physicsBody.velocity.y)}
            if (node.position.y <= getLowBound(node) || node.position.y > getUBound(node)){
//                // print("*** Y--OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                ("** YOOB ***")
                node.physicsBody!.velocity = CGVectorMake(1 * node.physicsBody!.velocity.dx,-1 * node.physicsBody!.velocity.dy)
            }
            
            
            
        }

//        }
        
    }
    
    fileprivate func extractedFunc() {
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        var a = contact.bodyA.node?.name
        var b = contact.bodyB.node?.name
        if( (a == "win" || b == "win") && (a == "sprite" || b == "sprite")){
            
            extractedFunc()

        }
//        if (a == "spikes" || b == "spikes") {
//
//            let shockwave = SKShapeNode(circleOfRadius: 1)
//            shockwave.strokeColor = .white
//            shockwave.fillColor = .blue
//
//
//            shockwave.position = contact.contactPoint
//            scene!.addChild(shockwave)
//
//            shockwave.run(shockWaveAction)
//            return
//        }
        
        if( ["mover1","mover2","mover3"].contains(a) && ["mover1","mover2","mover3"].contains(b)  ){
            
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
//            (" collision \(a) \(-1 * vel!.dx) - ")
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            contact.bodyB.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            return
        }
        
        if( (coinStrLst.contains(a!) && "sprite" == b) || (coinStrLst.contains(b!) && "sprite" == a)  ){
            let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            stats.score = stats.score + 1
            stats.scoreNode.text = "Score: \(stats.score)"
            coin?.removeFromParent()
            
            
//            addChild(audioCoin)
            
            
//            guard GameViewController.spritekitView?.scene?.addChild(audioCoin) != nil else {
//                // print (" issue loading audio ")
//                return
//            }
            
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("coin", waitForCompletion: false)])
            run(sound)
            
//            audio.
            return
        }
//        // print("\(a)-\(b)")
        if( (lStrLst.contains(a!) && "sprite" == b) || (lStrLst.contains(b!) && "sprite" == a)  ){
            // print("\(a)-\(b) -->caught")
            let life = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            stats.life = stats.life + 1
            stats.lifeNode.text = "Life: \(stats.life)"
            life?.removeFromParent()
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("life", waitForCompletion: false)])
            run(sound)
            
            return
        }
        
        if(( (["bb1","bb2"].contains(a) && "sprite" == b) || (["bb1","bb2"].contains(b) && "sprite" == a)  )  && (abs((bladeTime - updateTime)) > 2 )){
            //// print("\(a)-\(b) : \(bladeTime) \(updateTime) --> caught")
            let blade = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            hurtEffect?.position = contact.contactPoint
            addChild(hurtEffect!)
            stats.life = stats.life - 1
            stats.lifeNode.text = "Life: \(stats.life)"
            bladeTime = updateTime
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("wrong", waitForCompletion: false)])
            run(sound)
//            life?.removeFromParent()
            hurtEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),SKAction.removeFromParent()]))
            return
        }
        
        if(( (["s1"].contains(a) && "sprite" == b) || (["s1"].contains(b) && "sprite" == a)  )  && (abs((spikesTime - updateTime)) > 2 )){
            
            let blade = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            spikeEffect?.position = contact.contactPoint
            addChild(spikeEffect!)
            stats.life = stats.life - 1
            stats.lifeNode.text = "Life: \(stats.life)"
            spikesTime = updateTime
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("wrong", waitForCompletion: false)])
            run(sound)
//            life?.removeFromParent()
            spikeEffect?.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),SKAction.removeFromParent()]))
            return
        }
//        // print("\(a)-\(b) : \(bladeTime) \(updateTime)")
    a=a!
        b=b!
        if( (a == "rocks" || b == "rocks") && (bladeStrLst.contains(a!) ||  bladeStrLst.contains(b!) ||  moversStrLst.contains(a!) || moversStrLst.contains(b!) || hbladeStrLst.contains(a!) || hbladeStrLst.contains(b!))){
            // print("\(a)-\(b) --> caught")
            let bladeRmovers: SKNode = (a == "rocks" ? contact.bodyB.node : contact.bodyA.node)!
            let rockNode: SKNode = (a == "rocks" ? contact.bodyA.node : contact.bodyB.node)!
            
            switch(bladeRmovers.name){
            case _ where moversStrLst.contains(bladeRmovers.name!) || bladeStrLst.contains(bladeRmovers.name!):
                bladeRmovers.physicsBody?.velocity.dx = bladeRmovers.physicsBody!.velocity.dx  * -1
            case _ where hbladeStrLst.contains(bladeRmovers.name!) :
                bladeRmovers.physicsBody?.velocity.dy = bladeRmovers.physicsBody!.velocity.dy  * -1
            default:
                // print("case exhausted")
                break
                
            }
            
        }
    }
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()

    
}

