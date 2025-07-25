import SpriteKit

enum Constants {
    enum LoadingConstants {
        static let loadingDuration: Double = 12
        static let animationDuration: Double = 5
        static let delayBeforFirstAnimation: Double = 0.5
        static let delayBeforSecondAnimation: Double = 1
        static let initialOpacity: Double = 1
        static let endOpacity: Double = 0
    }
    
    enum MainMenuConstants {
        static let initialOpacity: Double = 1
        static let endOpacity: Double = 0
        static let animationDuration: Double = 5
        static let devide: Double = 2
        static let delayAfterFirstAnimation: Double = 2
        static let darkEnriDelay: Double = 0.8
        
    }
    
    enum CharactersTextures {
        enum Enri {
            enum Walk {
                static let down: [SKTexture] = [SKTexture(image: .walkEnri1), SKTexture(image: .calmEnri), SKTexture(image: .walkEnri2)]
                static let up: [SKTexture] = [SKTexture(image: .upWalkingEnri1), SKTexture(image: .upWalkingClmEnri), SKTexture(image: .upWalkingEnri2)]
                static let right: [SKTexture] = [SKTexture(image: .rightWalkingEnri1), SKTexture(image: .rightCalmEnri), SKTexture(image: .rightWalkingEnri2)]
                static let leftEnri: [SKTexture] = [SKTexture(image: .leftWalkingEnri1), SKTexture(image: .leftCalmEnri), SKTexture(image: .leftWalkingEnri2)]
                
            }
            
            enum Calm {
                static let down: SKTexture = SKTexture(image: .calmEnri)
                static let up: SKTexture = SKTexture(image: .upWalkingClmEnri)
                static let left: SKTexture = SKTexture(image: .leftCalmEnri)
                static let right: SKTexture = SKTexture(image: .rightCalmEnri)
            }
        }
        
        enum Emma {
            enum Walk {
                static let down: [SKTexture] = [SKTexture(image: .downWalkingEmma1), SKTexture(image: .downCalmEmma), SKTexture(image: .downWalkingEmma2)]
                static let up: [SKTexture] = [SKTexture(image: .upWalkingEmma1), SKTexture(image: .calmUpWalkingEmma), SKTexture(image: .upWalkingEmma2)]
                static let right: [SKTexture] = [SKTexture(image: .rightWalkingEmma1), SKTexture(image: .rightCalmEmma), SKTexture(image: .rightWalkingEmma2)]
                static let leftEnri: [SKTexture] = [SKTexture(image: .leftWalkingEmma1), SKTexture(image: .leftCalmEmma), SKTexture(image: .leftWalkingEmma2)]
            }
            
            enum Calm {
                static let down: SKTexture = SKTexture(image: .downCalmEmma)
                static let up: SKTexture = SKTexture(image: .calmUpWalkingEmma)
                static let left: SKTexture = SKTexture(image: .leftCalmEmma)
                static let right: SKTexture = SKTexture(image: .rightCalmEmma)
            }
        }
    }
}


enum Direction {
    case up
    case down
    case left
    case right
    case none
    
    var vector: CGVector {
        switch self {
        case .up:    return CGVector(dx: 0, dy: 1)
        case .down:  return CGVector(dx: 0, dy: -1)
        case .left:  return CGVector(dx: -1, dy: 0)
        case .right: return CGVector(dx: 1, dy: 0)
        case .none: return CGVector(dx: 0, dy: 0)
        }
    }
}

enum Characters {
    case Enri
    case Emma
}


extension Direction {
    var enriWalkTextures: [SKTexture]? {
        switch self {
        case .up: return Constants.CharactersTextures.Enri.Walk.up
        case .down: return Constants.CharactersTextures.Enri.Walk.down
        case .left: return Constants.CharactersTextures.Enri.Walk.leftEnri
        case .right: return Constants.CharactersTextures.Enri.Walk.right
        case .none: return nil
        }
    }
    
    var enriCalmTextures: SKTexture? {
        switch self {
        case .up: return Constants.CharactersTextures.Enri.Calm.up
        case .down: return Constants.CharactersTextures.Enri.Calm.down
        case .left: return Constants.CharactersTextures.Enri.Calm.left
        case .right: return Constants.CharactersTextures.Enri.Calm.right
        case .none: return nil
        }
    }
    
    var emmaWalkTextures: [SKTexture]? {
        switch self {
        case .up: return Constants.CharactersTextures.Emma.Walk.up
        case .down: return Constants.CharactersTextures.Emma.Walk.down
        case .left: return Constants.CharactersTextures.Emma.Walk.leftEnri
        case .right: return Constants.CharactersTextures.Emma.Walk.right
        case .none: return nil
        }
    }
    
    var emmaCalmTextures: SKTexture? {
        switch self {
        case .up: return Constants.CharactersTextures.Emma.Calm.up
        case .down: return Constants.CharactersTextures.Emma.Calm.down
        case .left: return Constants.CharactersTextures.Emma.Calm.left
        case .right: return Constants.CharactersTextures.Emma.Calm.right
        case .none: return nil
        }
    }
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let character: UInt32 = 0b1
    static let dialogTrigger: UInt32 = 0b10
    static let firstDialogTrigger: UInt32 = 0b100
}
