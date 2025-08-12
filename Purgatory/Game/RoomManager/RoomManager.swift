import SpriteKit

final class RoomManager {
    weak var scene: SKScene?
    
    
    private var gridOrigin: CGPoint = .zero
    private var sceneSize: CGSize = .zero
    
    
    private var counter: Int = 0
    private var columnsInside: Int = 0
    private var rowsInside: Int = 0
    private var totalColumns: Int = 0
    private var totalRows: Int = 0
    var doorCounter: Int = 0
    
    
    private var totalWidth: CGFloat = 0
    private var totalHeight: CGFloat = 0
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var margin: CGFloat = 0
    private var gridCellSize: CGFloat = 0
    private var rockSide: CGFloat = 0
    
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
        margin = 0
        columnsInside = 19
        rowsInside = 8
        totalColumns = columnsInside + 2
        totalRows = rowsInside + 2
        rockSide = min((sceneSize.width - 2 * margin) / CGFloat(totalColumns), (sceneSize.height - 2 * margin) / CGFloat(totalRows))
        totalWidth = rockSide * CGFloat(totalColumns)
        totalHeight = rockSide * CGFloat(totalRows)
        offsetX = (sceneSize.width - totalWidth) / 2
        offsetY = (sceneSize.height - totalHeight) / 2
        self.gridOrigin = CGPoint(x: offsetX + rockSide * 1.5, y: offsetY + rockSide * 1.5)
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
                      dialogManager: manager, triggerRadius: TriggerRadius(radius: 100), identity: TriggerIdentity.bloodWriting)
            rock.size = CGSize(width: rockSide * 2, height: rockSide * 2)
            rock.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            scene.addChild(rock)
        }
        
        let doors: [(Int, Int)] = [
            (15, 3)
        ]
        
        
        
        for (col, row) in doors {
            let door = Door(id: "Door\(doorCounter)", wasEntered: false, size: CGSize(width: rockSide * 2, height: rockSide * 2))
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
    
    private func loadSecondRoom() {
        guard let scene = scene, let manager = dialogManager else { return }
        guard scene.size.width > 0 && scene.size.height > 0 else { return }
        scene.removeAllChildren()
        sceneSize = scene.size
        doorCounter = 0
        margin = 0
        columnsInside = 19
        rowsInside = 8
        totalColumns = columnsInside + 2
        totalRows = rowsInside + 2
        rockSide = min((sceneSize.width - 2 * margin) / CGFloat(totalColumns), (sceneSize.height - 2 * margin) / CGFloat(totalRows))
        totalWidth = rockSide * CGFloat(totalColumns)
        totalHeight = rockSide * CGFloat(totalRows)
        offsetX = (sceneSize.width - totalWidth) / 2
        offsetY = (sceneSize.height - totalHeight) / 2
        self.gridOrigin = CGPoint(x: offsetX + rockSide * 1.5, y: offsetY + rockSide * 1.5)
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
            (3,4), (9,4)
        ]
        for (col, row) in obstacles {
            let door = Door(id: "Door\(doorCounter)", wasEntered: false, size: CGSize(width: rockSide * 2, height: rockSide * 2))
            door.position = CGPoint(x: gridOrigin.x + CGFloat(col) * rockSide, y: gridOrigin.y + CGFloat(row) * rockSide)
            doorArray.append(door)
            scene.addChild(door)
            doorCounter += 1
        }
    }
}
