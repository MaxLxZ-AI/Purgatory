import SpriteKit

struct ASCIIRoomFile: Codable {
    let rooms: [ASCIIRoom]
}

struct ASCIIRoom: Codable {
    let id: String
    let layout: [String]
}


class RoomManager {
    private(set) var rooms: [String: ASCIIRoom] = [:]
    private weak var scene: SKScene?
    private weak var dialogManager: DialogManager?
    private var characters: [GameCharacter]?
    var doorCounter: Int = 0
    var currentID: String = ""

    let tileSize: CGFloat = 32
    private let halfTileSize: CGFloat = 16 // tileSize / 2
    
    init(scene: SKScene, dialogManager: DialogManager? = nil, characters: [GameCharacter]? = nil) {
        self.characters = characters
        self.scene = scene
        self.dialogManager = dialogManager
        loadRooms()
    }
    
    func scaledSize(baseSize: CGFloat) -> CGFloat {
        return (scene?.size.width)! / 375.0 * baseSize
    }

    func loadRooms() {
        print("Starting to load rooms...")
        
        // Попробуем загрузить из JSON файла
        if loadRoomsFromJSON() {
            return
        }
        
        // Если не удалось загрузить из JSON, создаем комнату программно
        print("Creating default room programmatically...")
        createDefaultRoom()
    }
    
    private func loadRoomsFromJSON() -> Bool {
        // Выведем все доступные ресурсы в bundle для диагностики
        if let resourcePath = Bundle.main.resourcePath {
            print("Bundle resource path: \(resourcePath)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Bundle contents: \(contents)")
            } catch {
                print("Error reading bundle contents: \(error)")
            }
        }
        
        // Сначала попробуем найти файл в корне (новое расположение)
        if let url = Bundle.main.url(forResource: "rooms_ascii", withExtension: "json") {
            print("Found file in root: \(url)")
            if let data = try? Data(contentsOf: url) {
                print("Successfully loaded data, size: \(data.count) bytes")
                if let parsed = try? JSONDecoder().decode(ASCIIRoomFile.self, from: data) {
                    print("Successfully parsed JSON, found \(parsed.rooms.count) rooms")
                    for room in parsed.rooms {
                        rooms[room.id] = room
                    }
                    return true
                } else {
                    print("Failed to decode JSON")
                }
            } else {
                print("Failed to load data from URL")
            }
        } else {
            print("File not found in root")
        }
        
        // Попробуем найти файл с подпапкой (старое расположение)
        if let url = Bundle.main.url(forResource: "rooms_ascii", withExtension: "json", subdirectory: "Game/RoomManager/JSON") {
            print("Found file with subdirectory: \(url)")
            if let data = try? Data(contentsOf: url) {
                print("Successfully loaded data, size: \(data.count) bytes")
                if let parsed = try? JSONDecoder().decode(ASCIIRoomFile.self, from: data) {
                    print("Successfully parsed JSON, found \(parsed.rooms.count) rooms")
                    for room in parsed.rooms {
                        rooms[room.id] = room
                    }
                    return true
                } else {
                    print("Failed to decode JSON")
                }
            } else {
                print("Failed to load data from URL")
            }
        } else {
            print("File not found with subdirectory")
        }
        
        return false
    }
    
    private func createDefaultRoom() {
        let defaultRoom = ASCIIRoom(
            id: "room1",
            layout: [
                "##########",
                "#..C.T..D#",
                "#........#",
                "#..P.....#",
                "##########"
            ]
        )
        rooms[defaultRoom.id] = defaultRoom
        print("Created default room with ID: \(defaultRoom.id)")
    }
    
    func hasRooms() -> Bool {
        return !rooms.isEmpty
    }
    
    func getRoomIDs() -> [String] {
        return Array(rooms.keys)
    }
    
    func setCharacters(_ characters: [GameCharacter]) {
        self.characters = characters
    }
    
    // Альтернативный метод для позиционирования по левому нижнему углу
    // Используйте этот метод, если хотите позиционировать объекты по углам
    private func positionForCornerAlignment(colIndex: Int, rowIndex: Int, numRows: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(colIndex) * tileSize,
            y: CGFloat(numRows - rowIndex - 1) * tileSize
        )
    }

    func loadRoom(withID id: String) {
        
        print("Attempting to load room with ID: \(id)")
        print("Available rooms: \(getRoomIDs())")
        
        guard let room = rooms[id] else {
            print("Room with ID '\(id)' not found")
            return
        }
        
        guard let scene = scene else {
            print("Scene is nil")
            return
        }
        
        print("Loading room: \(id)")
        scene.removeAllChildren()
        currentID = id
        doorCounter = 0
        scene.backgroundColor = .black
        let numRows = room.layout.count
        for (rowIndex, row) in room.layout.enumerated() {
            for (colIndex, char) in row.enumerated() {
                // Позиционируем объекты по центру тайла
                // Добавляем halfTileSize, потому что SpriteKit позиционирует по центру объекта
                let position = CGPoint(
                    x: CGFloat(colIndex) * tileSize + halfTileSize,
                    y: CGFloat(numRows - rowIndex - 1) * tileSize + halfTileSize
                )
                if let node = createNode(for: char, rowIndex: rowIndex, colIndex: colIndex) {
                    node.position = position
                    scene.addChild(node)
                }
            }
        }
        print("Room \(id) loaded successfully")
    }

    private func createNode(for char: Character, rowIndex: Int, colIndex: Int) -> SKNode? {
        switch char {
        case "#":
            let wall = SKSpriteNode(color: .clear, size: CGSize(width: scaledSize(baseSize: tileSize), height: scaledSize(baseSize: tileSize)))
            wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
            wall.physicsBody?.isDynamic = false
            wall.physicsBody?.affectedByGravity = false
            wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask = PhysicsCategory.character
            wall.physicsBody?.contactTestBitMask = PhysicsCategory.character
            wall.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            return wall
        case ".":
            return nil
        case "C":
            let crate = SKSpriteNode(color: .orange, size: CGSize(width: scaledSize(baseSize: tileSize), height: scaledSize(baseSize: tileSize)))
            crate.name = "crate"
            crate.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Центр
            return crate
        case "D":
            doorCounter += 1
            let doorId = "door_\(doorCounter)"
            let door = Door(id: doorId, wasEntered: false, size: CGSize(width: scaledSize(baseSize: tileSize), height: scaledSize(baseSize: tileSize)))
            return door
        case "E":
            guard let enri = characters?[0], enri.character == .Enri else {
                return nil
            }
            return enri
            
        case "M":
            guard let emma = characters?[1], emma.character == .Emma else {
                return nil
            }
            return emma
            
            
        case "T":
            guard let dialogManager = dialogManager else {
                print("Warning: DialogManager not available for trigger creation")
                return nil
            }
            let trigger = BloodWallWriting(texture: SKTexture(image: .wft),
                                           size: CGSize(width: 100, height: 100),
                                           dialogManager: dialogManager, triggerRadius: TriggerRadius(radius: 100), identity: TriggerIdentity.bloodWriting)
            
            
            return trigger
        default:
            return nil
        }
    }
    
    private func createNodeWithCornerAnchor(for char: Character, rowIndex: Int, colIndex: Int) -> SKNode? {
        switch char {
        case "#":
            let wall = SKSpriteNode(color: .clear, size: CGSize(width: tileSize, height: tileSize))
            wall.anchorPoint = CGPoint(x: 0, y: 0) // Левый нижний угол
            return wall
        case ".":
            return nil
        case "C":
            let crate = SKSpriteNode(color: .orange, size: CGSize(width: tileSize, height: tileSize))
            crate.name = "crate"
            crate.anchorPoint = CGPoint(x: 0, y: 0) // Левый нижний угол
            return crate
        case "D":
            doorCounter += 1
            let doorId = "door_\(doorCounter)"
            let door = Door(id: doorId, wasEntered: false, size: CGSize(width: tileSize, height: tileSize))
            return door
        case "P":
            let player = SKSpriteNode(color: .green, size: CGSize(width: tileSize, height: tileSize))
            player.name = "player"
            player.anchorPoint = CGPoint(x: 0, y: 0) // Левый нижний угол
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.categoryBitMask = 0x1 << 0
            player.physicsBody?.contactTestBitMask = 0x1 << 1
            return player
        default:
            return nil
        }
    }
}
