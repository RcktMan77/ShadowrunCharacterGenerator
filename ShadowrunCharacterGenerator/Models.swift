//
//  Models.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

// Core character struct
struct Character: Codable {
    var name: String
    var metatype: String
    var attributes: [String: Int]
    var skills: [String: Int]
    var karma: Int
    var nuyen: Int
    var gear: [String: Int] // e.g., ["Commlink": 1] for quantity
    var qualities: [String: Int] // e.g., ["Ambidextrous": 4] for karma cost
    var contacts: [String: Contact] // e.g., ["Fixer": Contact]
    var spells: [String] // List of spell names
    var complexForms: [String] // List of complex form names
    var powers: [String: Double] // e.g., ["Improved Reflexes": 1.5] for power points
    var mentor: String? // Mentor spirit name
    var tradition: String? // Magical tradition
    var metamagic: [String] // List of metamagic names
    var echoes: [String] // List of echo names
    var licenses: [String: Int] // e.g., ["Firearms License": 1] for quantity
    var lifestyle: String? // Lifestyle name
    var martialArts: [String] // List of martial arts techniques
    var sourcebooks: [String]
}

// Priority data (from priorities.json)
struct PriorityData: Codable {
    var metatype: [String: [MetatypeOption]]
    var attributes: [String: Int]
    var skills: [String: SkillPriority]
    var magic: [String: MagicPriority]
    var resources: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case metatype = "Metatype"
        case attributes = "Attributes"
        case skills = "Skills"
        case magic = "Magic"
        case resources = "Resources"
    }
}

struct MetatypeOption: Codable {
    var name: String
    var specialAttributePoints: Int
}

struct SkillPriority: Codable {
    var skillPoints: Int
    var skillGroupPoints: Int
}

struct MagicPriority: Codable {
    var type: String
    var points: Int
}

// Skills (from skills.json)
struct Skill: Codable {
    var name: String
    var category: String
    var attribute: String
}

// Qualities (from qualities.json)
struct Quality: Codable {
    var name: String
    var karmaCost: Int
    var type: String // "Positive" or "Negative"
}

// Gear (from gear.json)
struct Gear: Codable {
    var name: String
    var cost: Int
    var availability: String
    var category: String
}

// Armor (from armor.json)
struct Armor: Codable {
    var name: String
    var cost: Int
    var armorRating: Int
    var availability: String
}

// Weapons (from weapons.json)
struct Weapon: Codable {
    var name: String
    var cost: Int
    var damage: String
    var accuracy: Int
    var ap: Int
    var mode: String
    var rc: Int
    var ammo: String
    var availability: String
}

// Cyberware (from cyberware.json)
struct Cyberware: Codable {
    var name: String
    var cost: Int
    var essence: Double
    var availability: String
    var grade: String?
}

// Bioware (from bioware.json)
struct Bioware: Codable {
    var name: String
    var cost: Int
    var essence: Double
    var availability: String
}

// Vehicles (from vehicles.json)
struct Vehicle: Codable {
    var name: String
    var cost: Int
    var handling: Int
    var speed: Int
    var accel: Int
    var body: Int
    var armor: Int
    var pilot: Int
    var sensor: Int
    var availability: String
}

// Programs (from programs.json)
struct Program: Codable {
    var name: String
    var cost: Int
    var availability: String
}

// Licenses (from licenses.json)
struct License: Codable {
    var name: String
    var cost: Int
    var availability: String
}

// Lifestyles (from lifestyles.json)
struct Lifestyle: Codable {
    var name: String
    var cost: Int
    var months: Int?
}

// Contacts (from contacts.json)
struct Contact: Codable {
    var name: String
    var connection: Int
    var loyalty: Int
}

// Spells (from spells.json)
struct Spell: Codable {
    var name: String
    var category: String
    var type: String
    var range: String
    var duration: String
    var drain: String
}

// Complex Forms (from complexforms.json)
struct ComplexForm: Codable {
    var name: String
    var target: String
    var duration: String
    var fadingValue: String
}

// Powers (from powers.json)
struct Power: Codable {
    var name: String
    var cost: Double // Power point cost
    var levels: Bool // Whether it has variable levels
}

// Traditions (from traditions.json)
struct Tradition: Codable {
    var name: String
    var drainAttributes: [String]
    var spiritTypes: [String]
}

// Mentors (from mentors.json)
struct Mentor: Codable {
    var name: String
    var advantage: String
    var disadvantage: String
}

// Metamagic (from metamagic.json)
struct Metamagic: Codable {
    var name: String
    var cost: Int // Karma cost
}

// Echoes (from echoes.json)
struct Echo: Codable {
    var name: String
    var cost: Int // Karma cost
}

// Spirits (from spirits.json)
struct Spirit: Codable {
    var name: String
    var attributes: [String: Int]
    var powers: [String]
}

// Improvements (from improvements.json)
struct Improvement: Codable {
    var name: String
    var type: String // e.g., "Attribute", "Skill"
    var value: Int
    var target: String // e.g., "Logic", "Pistols"
}

// Books (from books.json)
struct Book: Codable {
    var name: String
    var code: String
}

// Martial Arts (from martialarts.json)
struct MartialArt: Codable {
    var name: String
    var cost: Int // Karma cost
    var techniques: [String]
}

// Ranges (from ranges.json)
struct Range: Codable {
    var name: String
    var short: Int
    var medium: Int
    var long: Int
    var extreme: Int
}

// Actions (from actions.json)
struct Action: Codable {
    var name: String
    var type: String // e.g., "Simple", "Complex"
    var requirements: String?
}

// Drug Components (from drugcomponents.json)
struct DrugComponent: Codable {
    var name: String
    var cost: Int
    var effect: String
    var availability: String
}
