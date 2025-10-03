import SpriteKit

final class RoomManager {
    weak var scene: SKScene?
    
    
    private var gridOrigin: CGPoint = .zero
    private var sceneSize: CGSize = .zero
    
    
    private var counter: Int = 0
    private var columnsInside: Int = Constants.GameConstants.columnsInside
    private var rowsInside: Int = Constants.GameConstants.rowsInside
    private var totalColumns: Int = Constants.GameConstants.columnsInside + 2
    private var totalRows: Int = Constants.GameConstants.rowsInside + 2
    var doorCounter: Int = 0
    
    
    private var totalWidth: CGFloat = 0
    private var totalHeight: CGFloat = 0
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var margin: CGFloat = Constants.GameConstants.margin
    private var gridCellSize: CGFloat = 0
    private var rockSide: CGFloat = 0
    
    private var trapWalls: [Wall] = []
    private var wasWordGuessed = false
    
    var doorArray: [Door] = []
    
    private weak var dialogManager: DialogManager?
    init(scene: SKScene? = nil, dialogManager: DialogManager? = nil) {
        self.dialogManager = dialogManager
        self.scene = scene
    }
    
    func loadRoom(room: String) {
        switch room {
        case "room1":
            loadFirstRoom()
        case "room2":
            loadSecondRoom()
        default:
            break
        }
    }
    
    private func loadFirstRoom() {
        guard let scene = scene, let manager = dialogManager else { return }
        guard scene.size.width > 0 && scene.size.height > 0 else { return }
        scene.removeAllChildren()
        doorArray.removeAll()
        sceneSize = scene.size
        doorCounter = 0
        rockSide = min((sceneSize.width - 2 * margin) / CGFloat(totalColumns), (sceneSize.height - 2 * margin) / CGFloat(totalRows))
        totalWidth = rockSide * CGFloat(totalColumns)
        totalHeight = rockSide * CGFloat(totalRows)
        offsetX = (sceneSize.width - totalWidth) / 2
        offsetY = (sceneSize.height - totalHeight) / 2
        self.gridOrigin = CGPoint(x: offsetX + rockSide * Constants.GameConstants.gridOriginMultiplierX, y: offsetY + rockSide * Constants.GameConstants.gridOriginMultiplierY)
        self.gridCellSize = rockSide
        

        let _ = SKTexture(imageNamed: "CluckRockImage")
        for col in 0..<totalColumns {
            let x = offsetX + CGFloat(col) * rockSide + rockSide/2
            let topRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            topRock.position = CGPoint(x: x, y: offsetY + totalHeight - rockSide/2)

            scene.addChild(topRock)
            let bottomRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            bottomRock.position = CGPoint(x: x, y: offsetY + rockSide/2)
   
            scene.addChild(bottomRock)
        }
        for row in 1..<(totalRows - 1) {
            let y = offsetY + CGFloat(row) * rockSide + rockSide/2
            let leftRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            leftRock.position = CGPoint(x: offsetX + rockSide/2, y: y)
            scene.addChild(leftRock)
            
            let rightRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            rightRock.position = CGPoint(x: offsetX + totalWidth - rockSide/2, y: y)

            scene.addChild(rightRock)
        }

        let obstacles: [(Int, Int)] = [
            (0,5), (9,5)
        ]
        for (col, row) in obstacles {
            let rock = BloodWallWriting(texture: SKTexture(image: .wft),
                                                size: CGSize(width: rockSide, height: rockSide),
                                        dialogManager: manager, wasPazzledSolved: Constants.UserDefaultsConstants.wasPazzleSolved, triggerRadius: TriggerRadius(radius: 100), identity: TriggerIdentity.bloodWriting)
            rock.size = CGSize(width: rockSide * Constants.GameConstants.obstacleSizeMultiplier, height: rockSide * Constants.GameConstants.obstacleSizeMultiplier)
            rock.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            scene.addChild(rock)
        }
        
        let doors: [(Int, Int)] = [
            (15, 3)
        ]
        
        
        for (col, row) in doors {
            let door = Door(id: "Door\(doorCounter)", wasEntered: false, size: CGSize(width: rockSide * Constants.GameConstants.doorSizeMultiplier, height: rockSide * Constants.GameConstants.doorSizeMultiplier))
            door.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            doorArray.append(door)
            scene.addChild(door)
            doorCounter += 1
        }


        let _ = SKTexture(imageNamed: "CluckFireImage")
        let _: [(Int, Int)] = [
            (2,0), (6,0), (8,0), (9,0), (11,0), (12,0), (14,0)
        ]
//        for (col, row) in spikes {
//            let spike = SKSpriteNode(texture: spikeTexture)
//            spike.size = CGSize(width: rockSide, height: rockSide)
//            spike.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
//            let spikeBodySize = CGSize(width: gridCellSize * 0.7, height: gridCellSize * 0.7)
//            spike.physicsBody = SKPhysicsBody(rectangleOf: spikeBodySize)
//            spike.physicsBody?.isDynamic = false
//            spike.physicsBody?.categoryBitMask = PhysicsCategory.spike
//            spike.physicsBody?.collisionBitMask = PhysicsCategory.chicken
//            spike.name = "spike"
//            addChild(spike)
//        }
    }
    
    func setCharactersPositions(enri: GameCharacter, emma: GameCharacter, enriPosition: (Int, Int), emmaPosition: (Int, Int)) {
        
        guard let scene = scene else { return }
        guard scene.size.width > 0 && scene.size.height > 0 else { return }
        sceneSize = scene.size
        rockSide = min((sceneSize.width - 2 * margin) / CGFloat(totalColumns), (sceneSize.height - 2 * margin) / CGFloat(totalRows))
        self.gridOrigin = CGPoint(x: offsetX + rockSide * Constants.GameConstants.gridOriginMultiplierX, y: offsetY + rockSide * Constants.GameConstants.gridOriginMultiplierY)

        
        enri.position = CGPoint(
            x: gridOrigin.x + CGFloat(enriPosition.0) * rockSide,
            y: gridOrigin.y + CGFloat(enriPosition.1) * rockSide
        )
        
        emma.position = CGPoint(
            x: gridOrigin.x + CGFloat(emmaPosition.0) * rockSide,
            y: gridOrigin.y + CGFloat(emmaPosition.1) * rockSide
        )
    }
    
    
    func trapInsideIllusion() {
        let initialCol = 1
        offsetY = (sceneSize.height - totalHeight) / 2
        
        for col in initialCol..<rowsInside / 2 + 1 {
            let y = offsetY + CGFloat(col) * rockSide + rockSide / 2
            let inverseY = CGFloat(rowsInside + 2) * rockSide - y
            
            let isInverse = col % 2 == 0
            
            for row in 0..<columnsInside + 1 {
                let delay = Double(col * rowsInside + row + 1) * Constants.GameConstants.wallDelayMultiplier
                
                let waitAction = SKAction.wait(forDuration: delay)
                let addRockAction = SKAction.run { [weak self] in
                    guard let self = self else { return }
                    
                    let x = self.offsetX + CGFloat(row) * self.rockSide + self.rockSide / 2
                    let inverseX = CGFloat(self.columnsInside + 2) * self.rockSide - x
                    
                    let rock = Wall(wallTexture: nil, size: CGSize(width: self.rockSide, height: self.rockSide))
                    let inverseRock = Wall(wallTexture: nil, size: CGSize(width: self.rockSide, height: self.rockSide))
                    
                    rock.position = CGPoint(
                        x: x,
                        y: isInverse ? inverseY : y
                    )
                    
                    inverseRock.position = CGPoint(
                        x: inverseX,
                        y: isInverse ? y : inverseY
                    )
                    if !wasWordGuessed {
                        self.scene?.addChild(rock)
                        self.scene?.addChild(inverseRock)
                        trapWalls.append(rock)
                        trapWalls.append(inverseRock)
                    }

                    rock.alpha = 0
                    rock.run(SKAction.fadeIn(withDuration: Constants.GameConstants.wallFadeInDuration))
                    inverseRock.alpha = 0
                    inverseRock.run(SKAction.fadeIn(withDuration: Constants.GameConstants.wallFadeInDuration))
                }
                
                self.scene?.run(SKAction.sequence([waitAction, addRockAction]))
            }
        }
    }
    
    func releaseCharactersFromTrap() {
        wasWordGuessed = true
        for (index, wall) in trapWalls.enumerated() {
            let delay = Double(index) * Constants.GameConstants.wallFadeDelayMultiplier
                
                let waitAction = SKAction.wait(forDuration: delay)
                let fadeOutAction = SKAction.fadeOut(withDuration: Constants.GameConstants.fadeOutDuration)
                let removeAction = SKAction.run { wall.removeFromParent() }
                
                let sequence = SKAction.sequence([waitAction, fadeOutAction, removeAction])
                wall.run(sequence)
            }
        }
    
    
    private func loadSecondRoom() {
        guard let scene = scene else { return }
        guard scene.size.width > 0 && scene.size.height > 0 else { return }
        scene.removeAllChildren()
        sceneSize = scene.size
        doorCounter = 0
        rockSide = min((sceneSize.width - 2 * margin) / CGFloat(totalColumns), (sceneSize.height - 2 * margin) / CGFloat(totalRows))
        totalWidth = rockSide * CGFloat(totalColumns)
        totalHeight = rockSide * CGFloat(totalRows)
        offsetX = (sceneSize.width - totalWidth) / 2
        offsetY = (sceneSize.height - totalHeight) / 2
        self.gridOrigin = CGPoint(x: offsetX + rockSide * Constants.GameConstants.gridOriginMultiplierX, y: offsetY + rockSide * Constants.GameConstants.gridOriginMultiplierY)
        self.gridCellSize = rockSide
        
        let _ = SKTexture(imageNamed: "CluckRockImage")
        for col in 0..<totalColumns {
            let x = offsetX + CGFloat(col) * rockSide + rockSide/2
            let topRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            topRock.position = CGPoint(x: x, y: offsetY + totalHeight - rockSide/2)

            scene.addChild(topRock)
            let bottomRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            bottomRock.position = CGPoint(x: x, y: offsetY + rockSide/2)
   
            scene.addChild(bottomRock)
        }
        for row in 1..<(totalRows - 1) {
            let y = offsetY + CGFloat(row) * rockSide + rockSide/2
            let leftRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            leftRock.position = CGPoint(x: offsetX + rockSide/2, y: y)
            scene.addChild(leftRock)
            
            let rightRock = Wall(wallTexture: nil, size: CGSize(width: rockSide, height: rockSide))
            rightRock.position = CGPoint(x: offsetX + totalWidth - rockSide/2, y: y)

            scene.addChild(rightRock)
        }

        let doors: [(Int, Int)] = [
            (3,2), (18,2)
        ]
        for (col, row) in doors {
            let door = Door(id: "Door\(doorCounter)", wasEntered: false, size: CGSize(width: rockSide * Constants.GameConstants.doorSizeMultiplier, height: rockSide * Constants.GameConstants.doorSizeMultiplier))
            door.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            doorArray.append(door)
            scene.addChild(door)
            doorCounter += 1
        }
        
        let pillars: [(Int, Int)] = [
            (5,6), (9,6), (13, 6)
        ]
        let pillarTexture = SKTexture(image: .pillar)
        
        let knifeTextrue = SKTexture(image: .bloodCoveredKnife)
        let candleTexture = SKTexture(image: .candle)
        let crossTextrure = SKTexture(image: .cross)
        
        let array: [PlaceableObject] = [PlaceableObject(texture: knifeTextrue, size: Constants.objectSizes.knifeSize, type: PlaceableObjects.BloodySurgicalKnife), PlaceableObject(texture: candleTexture, size: Constants.objectSizes.candleSize, type: PlaceableObjects.MeltedCandle), PlaceableObject(texture: crossTextrure, size: Constants.objectSizes.crossSize, type: PlaceableObjects.CrackedHolySymbol)]
        for (index, (col, row)) in pillars.enumerated() {
            let pillar = Pillar(object: array[index], texture: pillarTexture, size: Constants.objectSizes.pillarSize, dialogManager: dialogManager!, wasPazzledSolved: false, triggerRadius: TriggerRadius(radius: 100), identity: .pillar)
            pillar.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            scene.addChild(pillar)
        }
//        let courpse: [(Int, Int)] = [
//            (12,9)
//        ]
//        
//        for (col, row) in courpse {
//            let courpse = Courpse(texture: SKTexture(image: .boundedCourpse), size: CGSize(width: rockSide * Constants.GameConstants.doorSizeMultiplier, height: rockSide * Constants.GameConstants.doorSizeMultiplier), dialogManager: dialogManager!, wasPazzledSolved: false, triggerRadius: TriggerRadius(radius: 100), identity: TriggerIdentity.corpseStrappedToATable)
//            courpse.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
//            scene.addChild(courpse)
//        }
    }
}
