import SpriteKit

class Character: SKSpriteNode {
    var calmState: SKTexture
    let character: Characters
    var walkingTextures: [SKTexture] = Constants.CharactersTextures.Enri.Walk.down
    var isWalking = false {
        didSet {
            updateMovement()
            updateAnimation()
        }
    }
    
    private var walkingAction: SKAction?
    var moveSpeed: CGFloat = 150.0
    
    var currentDirection: Direction = .none
    private var lastDirection: Direction = .none
    
    private var lastState = SKTexture()
    
    init(character: Characters, calmState: SKTexture, size: CGSize) {
        self.character = character
        self.calmState = calmState
        super.init(texture: calmState, color: .clear, size: size)
        setupCharacter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCharacter() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.character
        physicsBody?.collisionBitMask = PhysicsCategory.dialogTrigger
        physicsBody?.contactTestBitMask = PhysicsCategory.dialogTrigger | PhysicsCategory.firstDialogTrigger

        
        createWalkingAction()
    }
    private func createWalkingAction() {
        walkingAction = SKAction.repeatForever(
            SKAction.animate(with: walkingTextures, timePerFrame: 0.15)
        )
    }
    
    
   private func updateAnimation() {
        removeAllActions()
        
        if isWalking {
            createWalkingAction()
            run(walkingAction!)
            
        } else {
            texture = calmState
        }
    }
    
    func updateDirection() {
    }
    

    

    
    private func updateVelocity() {
        if currentDirection == .none && isWalking {
            stopMoving()
            return
        }
        
        let velocity = CGVector(
            dx: currentDirection.vector.dx * moveSpeed,
            dy: currentDirection.vector.dy * moveSpeed
        )
        
        physicsBody?.velocity = velocity
    }
    
    func updateMovement() {
        updateDirection()
        updateVelocity()
    }
    
    func startMoving(in direction: Direction) {
        currentDirection = direction
        isWalking = true
    }
    
    func stopMoving() {
        lastDirection = currentDirection
        isWalking = false
        physicsBody?.velocity = .zero
        currentDirection = .none
    }
    
    func moveToPosition(_ position: CGPoint, duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Определяем направление для анимации
        let dx = position.x - self.position.x
        let dy = position.y - self.position.y
        if abs(dx) > abs(dy) {
            currentDirection = dx > 0 ? .right : .left
        } else {
            currentDirection = dy > 0 ? .up : .down
        }
        updateDirection()
        isWalking = true

        let moveAction = SKAction.move(to: position, duration: duration)
        let stopAction = SKAction.run { [weak self] in
            self?.isWalking = false
            self?.stopMoving()
            completion?()
        }
        let sequence = SKAction.sequence([moveAction, stopAction])
        run(sequence)
    }
}


final class Enri: Character {
    override func updateDirection() {
        enriTextures()
    }
    
    private func enriTextures() {
        if let walk = currentDirection.enriWalkTextures {
            walkingTextures = walk
        }
        
        if let calm = currentDirection.enriCalmTextures {
            calmState = calm
        }
    }
}

final class Emma: Character {
    
    weak var leader: Character?  // The character to follow (Enri)
    var followDistance: CGFloat = 100.0  // Distance to maintain from leader
    var followDelay: TimeInterval = 0.3  // Delay before starting to follow
    private var lastLeaderPosition: CGPoint?
    private var leaderPositions: [CGPoint] = []  // Trail of leader positions
    private let maxTrailLength = 10
    
    override func updateDirection() {
        emmaTextures()
    }
    
    private func emmaTextures() {
        if let walk = currentDirection.emmaWalkTextures {
            walkingTextures = walk
        }
        
        if let calm = currentDirection.emmaCalmTextures {
            calmState = calm
        }
    }
    
    func setupFollowing(leader: Character) {
        self.leader = leader
        self.lastLeaderPosition = leader.position
    }
    
    func updateFollowing() {
        guard let leader = leader else { return }
        
        // Record leader's position
        leaderPositions.append(leader.position)
        if leaderPositions.count > maxTrailLength {
            leaderPositions.removeFirst()
        }
        
        // Only move if leader has moved sufficiently
        let distanceToLeader = hypot(position.x - leader.position.x,
                                   position.y - leader.position.y)
        
        if distanceToLeader > followDistance {
            let targetIndex = min(Int(followDelay * 10), leaderPositions.count - 1)
            let targetPosition = leaderPositions[max(0, targetIndex)]
            
            // Calculate direction to target
            let dx = targetPosition.x - position.x
            let dy = targetPosition.y - position.y
            let distance = hypot(dx, dy)
            
            // Normalize direction and apply speed
            if distance >=   5 {
                let directionX = dx / distance
                let directionY = dy / distance
                
               
                
                if !isWalking {
                    updateFollowingDirection(dx: directionX, dy: directionY)
                    isWalking = true
                }
               
                physicsBody?.velocity = CGVector(
                                   dx: (dx / distance) * moveSpeed ,
                                   dy: (dy / distance) * moveSpeed
                               )
            } else {
                stopMoving()
            }
        } else {
            stopMoving()
        }
    }
    
    private func updateFollowingDirection(dx: CGFloat, dy: CGFloat) {
        if abs(dx) > abs(dy) {
            currentDirection = dx > 0 ? .right : .left
        } else {
            currentDirection = dy > 0 ? .up : .down
        }
        updateDirection()
    }
}

// MARK: - Room System

// Система символов для комнат
enum RoomSymbol /*: Character*/ {
    case wall
    case empty
    case player
    case enemy
    case trigger
    case door
    case item
    case npc
    
    init?(char: String.Element) {
        switch char {
        case "W": self = .wall
        case " ": self = .empty
        case "P": self = .player
        case "E": self = .enemy
        case "T": self = .trigger
        case "D": self = .door
        case "I": self = .item
        case "N": self = .npc
        default: return nil
        }
    }
    
    var rawValue: String.Element {
        switch self {
        case .wall: return "W"
        case .empty: return " "
        case .player: return "P"
        case .enemy: return "E"
        case .trigger: return "T"
        case .door: return "D"
        case .item: return "I"
        case .npc: return "N"
        }
    }
    
    var isWalkable: Bool {
        switch self {
        case .wall: return false
        case .empty, .player, .enemy, .trigger, .door, .item, .npc: return true
        }
    }
}

struct RoomTile {
    let symbol: RoomSymbol
    let position: CGPoint
    let size: CGFloat = 64
}

// Протокол для комнат
protocol Room {
    var layout: [String] { get }
    var background: SKTexture { get }
    var doorTarget: Room? { get }
    var transitionType: TransitionType { get }
    var walkableArea: [CGPoint] { get } // Убираем set, делаем только get
    var onTransitionComplete: (() -> Void)? { get set }
    
    func setup()
    func cleanup()
}

// Генератор комнат
class RoomGenerator {
    private let tileSize: CGFloat = 64
    
    func generateRoom(from layout: [String], roomSize: CGSize, dialogManager: DialogManager) -> (background: SKSpriteNode, objects: [SKNode], walkableArea: [CGPoint]) {
        var objects: [SKNode] = []
        var walkableArea: [CGPoint] = []
        
        // Создаем фон
        let background = SKSpriteNode(texture: SKTexture(image: .firstRoom), size: roomSize)
        background.zPosition = 0
        
        // Обрабатываем каждый символ
        for (rowIndex, row) in layout.enumerated() {
            for (columnIndex, char) in row.enumerated() {
                guard let symbol = RoomSymbol(char: char) else { continue }
                
                let position = CGPoint(
                    x: CGFloat(columnIndex) * tileSize - roomSize.width/2 + tileSize/2,
                    y: CGFloat(rowIndex) * tileSize - roomSize.height/2 + tileSize/2
                )
                
                switch symbol {
                case .wall:
                    let wall = createWall(at: position)
                    objects.append(wall)
                case .door:
                    let door = createDoor(at: position)
                    objects.append(door)
                case .trigger:
                    let trigger = createTrigger(at: position, dialogManager: dialogManager)
                    objects.append(trigger)
                case .empty, .player, .enemy, .item, .npc:
                    if symbol.isWalkable {
                        walkableArea.append(position)
                    }
                }
            }
        }
        
        return (background, objects, walkableArea)
    }
    
    private func createWall(at position: CGPoint) -> SKSpriteNode {
        let wall = SKSpriteNode(color: .gray, size: CGSize(width: tileSize, height: tileSize))
        wall.position = position
        wall.zPosition = 1
        return wall
    }
    
    private func createDoor(at position: CGPoint) -> RoomDoor {
        let door = RoomDoor(
            texture: SKTexture(image: .dilogWindow), // Временно используем существующую текстуру
            size: CGSize(width: tileSize, height: tileSize * 1.5)
        )
        door.position = position
        door.zPosition = 2
        return door
    }
    
    private func createTrigger(at position: CGPoint, dialogManager: DialogManager) -> DialogTriggerNode {
        let trigger = BloodWallWriting(
            texture: SKTexture(image: .wft),
            size: CGSize(width: tileSize, height: tileSize),
            dialogManager: dialogManager,
            triggerRadius: TriggerRadius(radius: tileSize)
        )
        trigger.position = position
        trigger.zPosition = 2
        return trigger
    }
}

// Система дверей с переходом
class RoomDoor: SKSpriteNode {
    var targetRoom: Room?
    var transitionType: TransitionType = .fade
    var onTransitionComplete: (() -> Void)?
    
    init(texture: SKTexture?, size: CGSize) {
        super.init(texture: texture, color: .clear, size: size)
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.door
        physicsBody?.contactTestBitMask = PhysicsCategory.character
    }
    
    func setupTransition(targetRoom: Room, transitionType: TransitionType, completion: @escaping () -> Void) {
        self.targetRoom = targetRoom
        self.transitionType = transitionType
        self.onTransitionComplete = completion
    }
}

// Типы переходов
enum TransitionType {
    case fade
    case slide(direction: Direction)
    case zoom
    case custom(animation: SKAction)
}

// Менеджер переходов
class TransitionManager {
    private weak var scene: SKScene?
    private var transitionNode: SKSpriteNode?
    
    init(scene: SKScene?) {
        self.scene = scene
    }
    
    func playTransition(_ type: TransitionType, reverse: Bool = false, completion: @escaping () -> Void) {
        let transitionNode = SKSpriteNode(color: .black, size: scene?.size ?? .zero)
        transitionNode.position = CGPoint(x: scene?.frame.midX ?? 0, y: scene?.frame.midY ?? 0)
        transitionNode.zPosition = 1000
        scene?.addChild(transitionNode)
        
        let action: SKAction
        switch type {
        case .fade:
            action = reverse ? .fadeOut(withDuration: 0.5) : .fadeIn(withDuration: 0.5)
        case .slide(let direction):
            let moveDistance: CGFloat = 500
            let startPosition = reverse ? .zero : CGPoint(x: direction.vector.dx * moveDistance, y: direction.vector.dy * moveDistance)
            let endPosition = reverse ? CGPoint(x: direction.vector.dx * moveDistance, y: direction.vector.dy * moveDistance) : .zero
            transitionNode.position = startPosition
            action = .move(to: endPosition, duration: 0.5)
        case .zoom:
            let scale: CGFloat = reverse ? 0.1 : 10.0
            action = .scale(to: scale, duration: 0.5)
        case .custom(let customAction):
            action = customAction
        }
        
        transitionNode.run(action) {
            transitionNode.removeFromParent()
            completion()
        }
    }
}

// Менеджер комнат
class RoomManager {
    private var currentRoom: Room?
    private var scene: SKScene?
    private var transitionManager: TransitionManager?
    private var roomGenerator: RoomGenerator?
    private var dialogManager: DialogManager?
    
    init(scene: SKScene?, dialogManager: DialogManager?) {
        self.scene = scene
        self.dialogManager = dialogManager
        self.transitionManager = TransitionManager(scene: scene)
        self.roomGenerator = RoomGenerator()
    }
    
    func loadRoom(_ room: Room, transition: TransitionType = .fade, completion: @escaping () -> Void) {
        // Очистка текущей комнаты
        currentRoom?.cleanup()
        
        // Анимация перехода
        transitionManager?.playTransition(transition) { [weak self] in
            // Загрузка новой комнаты
            self?.setupRoom(room)
            self?.transitionManager?.playTransition(transition, reverse: true) {
                completion()
            }
        }
    }
    
    private func setupRoom(_ room: Room) {
        guard let dialogManager = dialogManager else { return }
        
        // Генерируем комнату из layout
        let (background, objects, walkableArea) = roomGenerator?.generateRoom(
            from: room.layout,
            roomSize: scene?.size ?? CGSize(width: 800, height: 600),
            dialogManager: dialogManager
        ) ?? (SKSpriteNode(), [], [])
        
        // Добавляем в сцену
        scene?.addChild(background)
        objects.forEach { scene?.addChild($0) }
        
        // Настраиваем двери
        setupDoors(objects: objects, room: room)
        
        currentRoom = room
        // Убираем эту строку, так как room является let константой
        // room.walkableArea = walkableArea
    }
    
    private func setupDoors(objects: [SKNode], room: Room) {
        for object in objects {
            if let door = object as? RoomDoor {
                // Проверяем, что у комнаты есть целевая комната
                guard let targetRoom = room.doorTarget else { continue }
                
                door.setupTransition(
                    targetRoom: targetRoom,
                    transitionType: room.transitionType
                ) { [weak self] in
                    // Выполняем действия после перехода
                    self?.onRoomTransitionComplete(room: room)
                }
            }
        }
    }
    
    private func onRoomTransitionComplete(room: Room) {
        // Вызываем completion комнаты
        room.onTransitionComplete?()
    }
}

// Конкретные комнаты
class FirstRoom: Room {
    let layout = [
        "WWWWWWWWWWWWWW",
        "W            W",
        "W            W",
        "W            W",
        "W            W",
        "W            W",
        "W          T W",
        "W  WWW       W",
        "W    W W   W W",
        "W   EW       W",
        "W  WWW   W   W",
        "W     W      W",
        "W       WWW  W",
        "W            W",
        "WWWWWWWWWWWWWW",
        "WWWWWWWWWWWWWW",
        "WWWWWWWWWWWWWW"
    ]
    let background = SKTexture(image: .firstRoom)
    var doorTarget: Room? = nil // Установите ссылку на следующую комнату
    var transitionType: TransitionType = .fade
    var onTransitionComplete: (() -> Void)?
    
    // Вычисляемое свойство для walkableArea
    var walkableArea: [CGPoint] {
        var area: [CGPoint] = []
        let tileSize: CGFloat = 64
        let roomSize = CGSize(width: 800, height: 600)
        
        for (rowIndex, row) in layout.enumerated() {
            for (columnIndex, char) in row.enumerated() {
                guard let symbol = RoomSymbol(char: char) else { continue }
                
                if symbol.isWalkable {
                    let position = CGPoint(
                        x: CGFloat(columnIndex) * tileSize - roomSize.width/2 + tileSize/2,
                        y: CGFloat(rowIndex) * tileSize - roomSize.height/2 + tileSize/2
                    )
                    area.append(position)
                }
            }
        }
        return area
    }
    
    func setup() {
        // Можно добавить дополнительную логику для объектов комнаты
    }
    
    func cleanup() {
        // Удалить объекты комнаты из сцены
    }
}

// Расширение PhysicsCategory для дверей
extension PhysicsCategory {
    static let door: UInt32 = 0b1000
}
