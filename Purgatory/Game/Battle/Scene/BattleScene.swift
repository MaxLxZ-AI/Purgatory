import GameplayKit
import SpriteKit

//struct BattleAction {
//    let actor: BattleCharacter
//    let skill: Skill
//    let targets: [BattleCharacter]
//}

enum BattleResult {
    case victory(expGained: Int, goldGained: Int, items: [String])
    case defeat
    case escaped
}

class BattleManager {
    
    
    
}

enum BattleMenuOption {
    case fight
    case skills
    case items
    case defend
    case run
}

