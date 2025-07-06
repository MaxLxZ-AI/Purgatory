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
    
    enum Characters {
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


extension Direction {
    var walkTextures: [SKTexture]? {
        switch self {
        case .up: return Constants.Characters.Enri.Walk.up
        case .down: return Constants.Characters.Enri.Walk.down
        case .left: return Constants.Characters.Enri.Walk.leftEnri
        case .right: return Constants.Characters.Enri.Walk.right
        case .none: return nil
        }
    }
    
    var calmTextures: SKTexture? {
        switch self {
        case .up: return Constants.Characters.Enri.Calm.up
        case .down: return Constants.Characters.Enri.Calm.down
        case .left: return Constants.Characters.Enri.Calm.left
        case .right: return Constants.Characters.Enri.Calm.right
        case .none: return nil
        }
    }
}
