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
    case blade = 6
    case life = 8
    case coin = 16
    
    
}
struct gameStats{
    var score:Int
    var scoreNode:SKLabelNode
    
    var life:Int = 3
    var lifeNode:SKLabelNode
    var time = 0
    
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    let logger = Logger()
    private var spriteStat:SKSpriteNode?
    private var curState: spriteState = spriteState.idle
    private var prevState: spriteState? = nil
    private var hurtEffect = SKEmitterNode(fileNamed: "hurt")
    let audioCoin = SKAudioNode(fileNamed: "bg.mp3")
    private var spriteJump:SKSpriteNode?
    private var back:SKTileMapNode?
    private var bladeTime:TimeInterval = 0
    private var runAnim : SKAction = SKAction()
    private var idleAnim : SKAction = SKAction()
    private var updateTime:TimeInterval = 0
    private var obstacles:[String] = ["rocks"]
    private var moversLst:[SKSpriteNode] = Array()
    private var bladeLst:[SKSpriteNode] = Array()
    private var bladeHLst:[SKSpriteNode] = Array()
    private var coinLst:[SKSpriteNode] = Array()
    private var rodLst:[SKSpriteNode] = Array()
    
    private var stats:gameStats = gameStats(score:0, scoreNode: SKLabelNode(fontNamed: "Chalkduster"), life:3, lifeNode: SKLabelNode(fontNamed: "Chalkduster"))
    override func didMove(to view: SKView) {
//        (" did move ")
        audioCoin.autoplayLooped = false
        addChild(audioCoin)
        physicsWorld.contactDelegate = self
        for i in obstacles {
            if let back = childNode(withName: i) as? SKTileMapNode {
                self.back=back
                physics(nodeName:i)
            }
        }
        addSprite()
        for i in ["mover1","mover2","mover3","mover4"] {
            addMovers(i)
        }
        for i in ["bb1"] {
            addblade(i)
        }
        for i in ["bb2"] {
            addHBlade(i)
        }
        for i in ["l1" ] {
            addLife(i)
        }
        for i in ["c1","c2","c3","c4","c5","c6","c7"]{
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
        print("scene : \(frame.height) - \(frame.midY) camera \(scene?.camera?.frame.height) \(scene?.camera?.frame.midY)")
        
        
        
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
        
        var texts:[SKTexture]? = Array()
        
        
        
            let movers = childNode(withName: name!) as? SKSpriteNode
        movers?.texture = SKTexture(imageNamed: "floaters1")
        movers?.physicsBody = SKPhysicsBody(texture: movers!.texture!, size: movers!.texture!.size())
            ("phy body ",movers!.physicsBody)
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
        spriteStat?.physicsBody?.contactTestBitMask = 2 | id.coin.rawValue | id.life.rawValue | id.blade.rawValue
        spriteStat?.physicsBody?.collisionBitMask = 2 | 4 | id.coin.rawValue | id.blade.rawValue
            spriteStat!.run(SKAction.repeatForever(idleAnim))
        
//
        
        
    }
    func addLife(_ name:String?) -> Void{
        
        
        var texts:[SKTexture]? = Array()
        
        for i in 1...5{
            
//            if(i == 4){continue}
            if texts?.append(SKTexture(imageNamed: "l1\(i)")) == nil {
                ("\(i) nilled ")
            }
        }
        let anim = SKAction.animate(with: texts!, timePerFrame: 0.2)
        
        
            let movers = childNode(withName: name!) as? SKSpriteNode
        
        movers?.physicsBody = SKPhysicsBody(rectangleOf: movers!.size)
            ("phy body ",movers!.physicsBody)
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
            ("phy body ",movers!.physicsBody)
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
                    
                    if (name == "drums" ){
                        map.setTileGroup(nil, forColumn: col, row: row)
                        tileNode.texture = tileText
                     
                    }
                    tileNode.name = name
                    tileNode.size = CGSizeMake(tileSize.width, tileSize.height)
                    tileNode.position = CGPoint(x:x,y:y)
                    tileNode.physicsBody = SKPhysicsBody(texture:tileText, size: CGSize(width:tileText.size().width, height:tileText.size().height))
                    tileNode.physicsBody?.categoryBitMask = 2
//                    tileNode.physicsBody?.contactTestBitMask = 1
                    tileNode.physicsBody?.collisionBitMask = id.life.rawValue
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 29
                    
                    if(name == "drums"){
                        tileNode.physicsBody?.isDynamic = true
                        tileNode.physicsBody?.mass = 10
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.affectedByGravity = true
                        ("\(tileNode.physicsBody) drummed")
//                        tileNode.blendMode = SKBlendMode.replace
                        
                    }
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
        let vect = CGVectorMake(0,9550)
        let vect2 = CGVectorMake(-3550,0)
        let vect3 = CGVectorMake(3550,0)
        (" applying vect ",vect)
        ( pos.x , spriteStat!.position.x )
        if( pos.x <=  spriteStat!.position.x){
            (" applying x-ve\n")
            guard spriteStat?.physicsBody?.applyImpulse(vect2) != nil else {
                
                (" nilled 1",spriteStat!.physicsBody)
                return
            }
        }
        if( pos.y >=  spriteStat!.position.y){
            (" applying y")
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
            ("applying x+ve")
            guard spriteStat?.physicsBody?.applyImpulse(vect3) != nil else {
                
                (" nilled 3",spriteStat!.physicsBody)
                return
            }
        }
        //(sprite?.position, sprite?.physicsBody,sprite?.physicsBody?.velocity, sprite?.physicsBody?.isResting)
        ("vel ",spriteStat?.physicsBody?.velocity)
        
        
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
        
        //        if(sprite!.position.y >  camera!.position.y){
//        let msg = "\(spriteStat?.physicsBody?.velocity.dy, priva)"
        
        updateTime = currentTime
        ("\(spriteStat?.physicsBody?.velocity.dy):dy \(curState) \(prevState)")
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
//                print("*** Y--OOB \(node.name) \(node.physicsBody?.velocity) \(node.physicsBody?.linearDamping)****")
                ("** YOOB ***")
                node.physicsBody!.velocity = CGVectorMake(1 * node.physicsBody!.velocity.dx,-1 * node.physicsBody!.velocity.dy)
            }
            
            
            
        }

//        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node?.name
        let b = contact.bodyB.node?.name
        if (a == "spikes" || b == "spikes") {
            
            let shockwave = SKShapeNode(circleOfRadius: 1)
            shockwave.strokeColor = .white
            shockwave.fillColor = .blue
            

            shockwave.position = contact.contactPoint
            scene!.addChild(shockwave)
            
            shockwave.run(shockWaveAction)
            return
        }
        
        if( ["mover1","mover2","mover3"].contains(a) && ["mover1","mover2","mover3"].contains(b)  ){
            
            var vel = contact.bodyA.node?.physicsBody?.velocity
            contact.bodyA.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
//            (" collision \(a) \(-1 * vel!.dx) - ")
            vel = contact.bodyB.node?.physicsBody?.velocity
//            ("\(b) \(-1 * vel!.dx)")
            contact.bodyB.node!.physicsBody!.velocity = CGVector(dx: -1 * vel!.dx, dy: vel!.dy)
            return
        }
        
        if( (["c1","c2","c3","c4","c5","c6","c7"].contains(a) && "sprite" == b) || (["c1","c2","c3","c4","c5","c6","c7"].contains(b) && "sprite" == a)  ){
            let coin = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            stats.score = stats.score + 1
            stats.scoreNode.text = "Score: \(stats.score)"
            coin?.removeFromParent()
            
            
//            addChild(audioCoin)
            
            
//            guard GameViewController.spritekitView?.scene?.addChild(audioCoin) != nil else {
//                print (" issue loading audio ")
//                return
//            }
            
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("coin", waitForCompletion: false)])
            run(sound)
            
//            audio.
            return
        }
//        print("\(a)-\(b)")
        if( (["l1","l2","l3","l4"].contains(a) && "sprite" == b) || (["l1","l2","l3","l4","l5","l6","l7"].contains(b) && "sprite" == a)  ){
            print("\(a)-\(b) -->caught")
            let life = a == "sprite" ? contact.bodyB.node : contact.bodyA.node
            let spriteNode = a == "sprite" ? contact.bodyA.node : contact.bodyB.node
            
            stats.life = stats.life + 1
            stats.lifeNode.text = "Life: \(stats.life)"
            life?.removeFromParent()
            var sound=SKAction.group([SKAction.changeVolume(to: 0, duration: 4), SKAction.playSoundFileNamed("life", waitForCompletion: false)])
            run(sound)
            
            return
        }
        print("\(a)-\(b) : \(bladeTime) \(updateTime)")
        if(( (["bb1","bb2"].contains(a) && "sprite" == b) || (["bb1","bb2"].contains(b) && "sprite" == a)  )  && (abs((bladeTime - updateTime)) > 2 )){
            print("\(a)-\(b) : \(bladeTime) \(updateTime) --> caught")
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
