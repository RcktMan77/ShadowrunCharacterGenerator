//
//  Models.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import Foundation

// Core character struct
struct Character: Codable {
    var name: String
    var metatype: String
    var priority: PrioritySelection? // New property to store priority selections
    var attributes: [String: Int]
    var skills: [String: Int]
    var specializations: [String: String] // New property for skill specializations
    var karma: Int = 25 // Default to 25 per SR5 (p. 98)
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

    struct PrioritySelection: Codable {
        var metatype: String
        var attributes: String
        var skills: String
        var magic: String
        var resources: String
    }
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
    var karma: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case specialAttributePoints = "value"
        case karma
    }
}

struct SkillPriority: Codable {
    var skillPoints: Int
    var skillGroupPoints: Int
    
    enum CodingKeys: String, CodingKey {
        case skillPoints
        case skillGroupPoints
    }
}

struct MagicPriority: Codable {
    var type: String
    var points: Int
    var spells: Int?
    var complexForms: Int?
    var skillQty: Int?
    var skillVal: Int?
    var skillType: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "value"
        case points
        case spells
        case complexForms = "cfp"
        case skillQty
        case skillVal
        case skillType
    }
}

// Skills (from skills.json)
struct Skill: Codable {
    let id: String
    let name: String
    let attribute: String
    let category: String
    let `default`: String
    let skillgroup: String?
    let specs: [String]?
    let source: String?
    let page: String?
    let exotic: String?
    let requiresflymovement: String?
    let requiresgroundmovement: String?
    let requiresswimmovement: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, attribute, category, `default`, skillgroup, specs, source, page
        case exotic, requiresflymovement, requiresgroundmovement, requiresswimmovement
    }
    
    enum SpecsKeys: String, CodingKey {
        case spec
    }
    
    // Explicit initializer for direct creation
    init(
        id: String,
        name: String,
        attribute: String,
        category: String,
        `default`: String,
        skillgroup: String?,
        specs: [String]?,
        source: String?,
        page: String?,
        exotic: String? = nil,
        requiresflymovement: String? = nil,
        requiresgroundmovement: String? = nil,
        requiresswimmovement: String? = nil
    ) {
        self.id = id
        self.name = name
        self.attribute = attribute
        self.category = category
        self.`default` = `default`
        self.skillgroup = skillgroup
        self.specs = specs
        self.source = source
        self.page = page
        self.exotic = exotic
        self.requiresflymovement = requiresflymovement
        self.requiresgroundmovement = requiresgroundmovement
        self.requiresswimmovement = requiresswimmovement
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        attribute = try container.decode(String.self, forKey: .attribute)
        category = try container.decode(String.self, forKey: .category)
        `default` = try container.decode(String.self, forKey: .default)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        page = try container.decodeIfPresent(String.self, forKey: .page)
        exotic = try container.decodeIfPresent(String.self, forKey: .exotic)
        requiresflymovement = try container.decodeIfPresent(String.self, forKey: .requiresflymovement)
        requiresgroundmovement = try container.decodeIfPresent(String.self, forKey: .requiresgroundmovement)
        requiresswimmovement = try container.decodeIfPresent(String.self, forKey: .requiresswimmovement)
        
        // Handle skillgroup: String or empty object {}
        if let skillgroupString = try? container.decodeIfPresent(String.self, forKey: .skillgroup) {
            skillgroup = skillgroupString
        } else if (try? container.decodeIfPresent([String: String].self, forKey: .skillgroup)) != nil {
            skillgroup = nil // Empty object {} treated as nil
        } else {
            skillgroup = nil
        }
        
        // Handle specs: { spec: [String] } or { spec: String } or empty object {}
        if let specsContainer = try? container.nestedContainer(keyedBy: SpecsKeys.self, forKey: .specs) {
            if let specArray = try? specsContainer.decodeIfPresent([String].self, forKey: .spec) {
                specs = specArray
            } else if let specString = try? specsContainer.decodeIfPresent(String.self, forKey: .spec) {
                specs = [specString] // Single string wrapped in array
            } else {
                specs = nil
            }
        } else if (try? container.decodeIfPresent([String: String].self, forKey: .specs)) != nil {
            specs = nil // Empty object {} treated as nil
        } else {
            specs = try container.decodeIfPresent([String].self, forKey: .specs)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(attribute, forKey: .attribute)
        try container.encode(category, forKey: .category)
        try container.encode(`default`, forKey: .default)
        try container.encodeIfPresent(skillgroup, forKey: .skillgroup)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(page, forKey: .page)
        try container.encodeIfPresent(exotic, forKey: .exotic)
        try container.encodeIfPresent(requiresflymovement, forKey: .requiresflymovement)
        try container.encodeIfPresent(requiresgroundmovement, forKey: .requiresgroundmovement)
        try container.encodeIfPresent(requiresswimmovement, forKey: .requiresswimmovement)
        
        // Encode specs as { spec: [String] }
        if let specs = specs {
            var specsContainer = container.nestedContainer(keyedBy: SpecsKeys.self, forKey: .specs)
            try specsContainer.encode(specs, forKey: .spec)
        } else {
            try container.encodeNil(forKey: .specs)
        }
    }
}

// Qualities (from qualities.json)
struct Quality: Codable {
    let id: String
    let name: String
    let karma: String
    let category: String
    let limit: String?
    let bonus: [String: AnyCodable]?
    let source: String
    let page: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, karma, category, limit, bonus, source, page
    }
    
    init(
        id: String,
        name: String,
        karma: String,
        category: String,
        limit: String?,
        bonus: [String: AnyCodable]?,
        source: String,
        page: String
    ) {
        self.id = id
        self.name = name
        self.karma = karma
        self.category = category
        self.limit = limit
        self.bonus = bonus
        self.source = source
        self.page = page
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        karma = try container.decode(String.self, forKey: .karma)
        category = try container.decode(String.self, forKey: .category)
        limit = try container.decodeIfPresent(String.self, forKey: .limit)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        
        // Handle bonus as a dictionary with flexible values
        if let bonusDict = try? container.decodeIfPresent([String: [String: String]].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: String].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: [String: AnyCodable]].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus) {
            bonus = bonusDict
        } else {
            bonus = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(karma, forKey: .karma)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(limit, forKey: .limit)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        
        // Encode bonus
        if let bonus = bonus {
            try container.encode(bonus, forKey: .bonus)
        } else {
            try container.encodeNil(forKey: .bonus)
        }
    }
}

// Lifestyle Qualities (from lifestyles.json qualities section)
struct LifestyleQuality: Codable {
    let id: String
    let name: String
    let category: String
    let lp: String?
    let cost: String?
    let allowed: String?
    let source: String
    let page: String
    let bonus: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, lp, cost, allowed, source, page, bonus
    }
    
    init(
        id: String,
        name: String,
        category: String,
        lp: String?,
        cost: String?,
        allowed: String?,
        source: String,
        page: String,
        bonus: [String: AnyCodable]?
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.lp = lp
        self.cost = cost
        self.allowed = allowed
        self.source = source
        self.page = page
        self.bonus = bonus
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        lp = try container.decodeIfPresent(String.self, forKey: .lp)
        cost = try container.decodeIfPresent(String.self, forKey: .cost)
        allowed = try container.decodeIfPresent(String.self, forKey: .allowed)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        
        // Handle bonus as a dictionary with flexible values
        if let bonusDict = try? container.decodeIfPresent([String: [String: String]].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: String].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: [String: AnyCodable]].self, forKey: .bonus) {
            bonus = bonusDict.mapValues { AnyCodable($0) }
        } else if let bonusDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus) {
            bonus = bonusDict
        } else {
            bonus = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(lp, forKey: .lp)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encodeIfPresent(allowed, forKey: .allowed)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        
        // Encode bonus
        if let bonus = bonus {
            try container.encode(bonus, forKey: .bonus)
        } else {
            try container.encodeNil(forKey: .bonus)
        }
    }
}

// Gear (from gear.json)
struct Gear: Codable {
    let id: String
    let name: String
    let category: String
    let rating: String?
    let source: String
    let page: String
    let avail: String?
    let addweapon: String?
    let cost: String?
    let costfor: String?

    enum CodingKeys: String, CodingKey {
        case id, name, category, rating, source, page, avail, addweapon, cost, costfor
    }

    // Explicit initializer for direct creation
    init(
        id: String,
        name: String,
        category: String,
        rating: String? = nil,
        source: String,
        page: String,
        avail: String? = nil,
        addweapon: String? = nil,
        cost: String? = nil,
        costfor: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.rating = rating
        self.source = source
        self.page = page
        self.avail = avail
        self.addweapon = addweapon
        self.cost = cost
        self.costfor = costfor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        avail = try container.decodeIfPresent(String.self, forKey: .avail)
        cost = try container.decodeIfPresent(String.self, forKey: .cost)
        costfor = try container.decodeIfPresent(String.self, forKey: .costfor)

        if let addweaponString = try? container.decodeIfPresent(String.self, forKey: .addweapon) {
            addweapon = addweaponString
        } else if let addweaponDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .addweapon) {
            if let text = addweaponDict["_text"]?.value as? String {
                addweapon = text
            } else {
                addweapon = nil
            }
        } else {
            addweapon = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        try container.encodeIfPresent(avail, forKey: .avail)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encodeIfPresent(costfor, forKey: .costfor)
        try container.encodeIfPresent(addweapon, forKey: .addweapon)
    }
}

// Armor (from armor.json)
struct Armor: Codable {
    let id: String
    let name: String
    let category: String
    let armor: String
    let armorcapacity: String
    let avail: String
    let cost: String
    let source: String
    let page: String
}

// Weapons (from weapons.json)
struct Weapon: Codable {
    let id: String
    let name: String
    let category: String
    let type: String
    let conceal: String
    let accuracy: String
    let reach: String?
    let damage: String?
    let ap: String?
    let mode: String?
    let rc: String?
    let ammo: String?
    let avail: String
    let cost: String
    let source: String
    let page: String
    let accessories: [Accessory]?
    let accessorymounts: [String]?
    let underbarrels: [String]?
    let addweapon: [String]?
    let cyberware: String?
    let hide: [String: AnyCodable]?
    let spec: String?
    let useskill: String?
    let range: String?
    let alternaterange: String?
    let ammoslots: String?
    let ammobonus: String?
    let modifyammocapacity: String?
    let rating: String?
    let forbidden: [String: AnyCodable]?
    let required: [String: AnyCodable]?
    let mount: String?
    let extramount: String?
    let damagetype: String?
    let rcdeployable: String?
    let rcgroup: String?
    let specialmodification: String?

    struct Accessory: Codable {
        let name: String
        let gears: [Gear]?

        struct Gear: Codable {
            let name: String
            let category: String?
            let rating: String?
        }

        enum CodingKeys: String, CodingKey {
            case name
            case gears
            case usegear
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)

            // Handle gears as single object or array
            if let gearArray = try? container.decode([Gear].self, forKey: .usegear) {
                gears = gearArray
            } else if let singleGear = try? container.decode(Gear.self, forKey: .usegear) {
                gears = [singleGear]
            } else {
                gears = nil
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            if let gears = gears {
                if gears.count == 1 {
                    try container.encode(gears[0], forKey: .usegear)
                } else {
                    try container.encode(gears, forKey: .usegear)
                }
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category, type, conceal, accuracy, reach, damage, ap, mode, rc, ammo
        case avail, cost, source, page, accessories, accessorymounts, underbarrels, addweapon
        case cyberware, hide, spec, useskill, range, alternaterange, ammoslots, ammobonus
        case modifyammocapacity, rating, forbidden, required, mount, extramount, damagetype
        case rcdeployable, rcgroup, specialmodification
    }

    enum AccessoriesKey: String, CodingKey {
        case accessory
        case underbarrel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        type = try container.decode(String.self, forKey: .type)
        conceal = try container.decode(String.self, forKey: .conceal)
        accuracy = try container.decode(String.self, forKey: .accuracy)
        reach = try container.decodeIfPresent(String.self, forKey: .reach)
        damage = try container.decodeIfPresent(String.self, forKey: .damage)
        ap = try container.decodeIfPresent(String.self, forKey: .ap)
        mode = try container.decodeIfPresent(String.self, forKey: .mode)
        rc = try container.decodeIfPresent(String.self, forKey: .rc)
        ammo = try container.decodeIfPresent(String.self, forKey: .ammo)
        avail = try container.decode(String.self, forKey: .avail)
        cost = try container.decode(String.self, forKey: .cost)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)

        // Decode accessories
        if let accessoriesContainer = try? container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .accessories) {
            if let accessoryArray = try? accessoriesContainer.decode([Accessory].self, forKey: .accessory) {
                accessories = accessoryArray
            } else if let singleAccessory = try? accessoriesContainer.decode(Accessory.self, forKey: .accessory) {
                accessories = [singleAccessory]
            } else {
                accessories = nil
            }
        } else {
            accessories = nil
        }

        // Decode accessorymounts
        if let mountsContainer = try? container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .accessorymounts) {
            accessorymounts = try mountsContainer.decodeIfPresent([String].self, forKey: .accessory)
        } else {
            accessorymounts = nil
        }

        // Decode underbarrels
        if let underbarrelsContainer = try? container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .underbarrels) {
            if let underbarrelArray = try? underbarrelsContainer.decode([String].self, forKey: .underbarrel) {
                underbarrels = underbarrelArray
            } else if let singleUnderbarrel = try? underbarrelsContainer.decode(String.self, forKey: .underbarrel) {
                underbarrels = [singleUnderbarrel]
            } else {
                underbarrels = nil
            }
        } else {
            underbarrels = nil
        }

        // Decode addweapon as array or single string
        if let addweaponArray = try? container.decode([String].self, forKey: .addweapon) {
            addweapon = addweaponArray
        } else if let addweaponString = try? container.decode(String.self, forKey: .addweapon) {
            addweapon = [addweaponString]
        } else {
            addweapon = nil
        }

        cyberware = try container.decodeIfPresent(String.self, forKey: .cyberware)
        hide = try container.decodeIfPresent([String: AnyCodable].self, forKey: .hide)
        spec = try container.decodeIfPresent(String.self, forKey: .spec)
        useskill = try container.decodeIfPresent(String.self, forKey: .useskill)
        range = try container.decodeIfPresent(String.self, forKey: .range)
        alternaterange = try container.decodeIfPresent(String.self, forKey: .alternaterange)
        ammoslots = try container.decodeIfPresent(String.self, forKey: .ammoslots)
        ammobonus = try container.decodeIfPresent(String.self, forKey: .ammobonus)
        modifyammocapacity = try container.decodeIfPresent(String.self, forKey: .modifyammocapacity)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        forbidden = try container.decodeIfPresent([String: AnyCodable].self, forKey: .forbidden)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)
        mount = try container.decodeIfPresent(String.self, forKey: .mount)
        extramount = try container.decodeIfPresent(String.self, forKey: .extramount)
        damagetype = try container.decodeIfPresent(String.self, forKey: .damagetype)
        rcdeployable = try container.decodeIfPresent(String.self, forKey: .rcdeployable)
        rcgroup = try container.decodeIfPresent(String.self, forKey: .rcgroup)
        specialmodification = try container.decodeIfPresent(String.self, forKey: .specialmodification)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(type, forKey: .type)
        try container.encode(conceal, forKey: .conceal)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encodeIfPresent(reach, forKey: .reach)
        try container.encodeIfPresent(damage, forKey: .damage)
        try container.encodeIfPresent(ap, forKey: .ap)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(rc, forKey: .rc)
        try container.encodeIfPresent(ammo, forKey: .ammo)
        try container.encode(avail, forKey: .avail)
        try container.encode(cost, forKey: .cost)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)

        // Encode accessories
        if let accessories = accessories {
            var accessoriesContainer = container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .accessories)
            if accessories.count == 1 {
                try accessoriesContainer.encode(accessories[0], forKey: .accessory)
            } else {
                try accessoriesContainer.encode(accessories, forKey: .accessory)
            }
        }

        // Encode accessorymounts
        if let accessorymounts = accessorymounts {
            var mountsContainer = container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .accessorymounts)
            try mountsContainer.encode(accessorymounts, forKey: .accessory)
        }

        // Encode underbarrels
        if let underbarrels = underbarrels {
            var underbarrelsContainer = container.nestedContainer(keyedBy: AccessoriesKey.self, forKey: .underbarrels)
            if underbarrels.count == 1 {
                try underbarrelsContainer.encode(underbarrels[0], forKey: .underbarrel)
            } else {
                try underbarrelsContainer.encode(underbarrels, forKey: .underbarrel)
            }
        }

        // Encode addweapon
        if let addweapon = addweapon {
            if addweapon.count == 1 {
                try container.encode(addweapon[0], forKey: .addweapon)
            } else {
                try container.encode(addweapon, forKey: .addweapon)
            }
        } else {
            try container.encodeNil(forKey: .addweapon)
        }

        try container.encodeIfPresent(cyberware, forKey: .cyberware)
        try container.encodeIfPresent(hide, forKey: .hide)
        try container.encodeIfPresent(spec, forKey: .spec)
        try container.encodeIfPresent(useskill, forKey: .useskill)
        try container.encodeIfPresent(range, forKey: .range)
        try container.encodeIfPresent(alternaterange, forKey: .alternaterange)
        try container.encodeIfPresent(ammoslots, forKey: .ammoslots)
        try container.encodeIfPresent(ammobonus, forKey: .ammobonus)
        try container.encodeIfPresent(modifyammocapacity, forKey: .modifyammocapacity)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(forbidden, forKey: .forbidden)
        try container.encodeIfPresent(required, forKey: .required)
        try container.encodeIfPresent(mount, forKey: .mount)
        try container.encodeIfPresent(extramount, forKey: .extramount)
        try container.encodeIfPresent(damagetype, forKey: .damagetype)
        try container.encodeIfPresent(rcdeployable, forKey: .rcdeployable)
        try container.encodeIfPresent(rcgroup, forKey: .rcgroup)
        try container.encodeIfPresent(specialmodification, forKey: .specialmodification)
    }
}

// Cyberware (from cyberware.json)
struct Cyberware: Codable {
    let id: String
    let name: String
    let limit: String?
    let category: String
    let ess: String
    let capacity: String?
    let avail: String
    let cost: String? // Changed to optional
    let source: String
    let page: String
    let rating: String?
    let forcegrade: String?
    let required: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id, name, limit, category, ess, capacity, avail, cost, source, page, rating, forcegrade, required
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        limit = try container.decodeIfPresent(String.self, forKey: .limit)
        category = try container.decode(String.self, forKey: .category)
        ess = try container.decode(String.self, forKey: .ess)
        capacity = try container.decodeIfPresent(String.self, forKey: .capacity)
        avail = try container.decode(String.self, forKey: .avail)
        cost = try container.decodeIfPresent(String.self, forKey: .cost) // Use decodeIfPresent
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        forcegrade = try container.decodeIfPresent(String.self, forKey: .forcegrade)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(limit, forKey: .limit)
        try container.encode(category, forKey: .category)
        try container.encode(ess, forKey: .ess)
        try container.encodeIfPresent(capacity, forKey: .capacity)
        try container.encode(avail, forKey: .avail)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(forcegrade, forKey: .forcegrade)
        try container.encodeIfPresent(required, forKey: .required)
    }
}

// Bioware (from bioware.json)
struct Bioware: Codable {
    let id: String
    let name: String
    let category: String
    let ess: String
    let capacity: String
    let avail: String
    let cost: String
    let rating: String?
    let source: String
    let page: String
}

// Vehicles (from vehicles.json)
struct Vehicle: Codable {
    let id: String
    let name: String
    let page: String
    let source: String
    let accel: String
    let armor: String
    let avail: String
    let body: String
    let category: String
    let cost: String
    let handling: String
    let pilot: String
    let sensor: String
    let speed: String
    let gears: [Gear]?
    let mods: [String]?
    let seats: String
}

// Programs (from programs.json)
struct Program: Codable {
    let id: String
    let name: String
    let category: String
    let avail: String
    let cost: String
    let source: String
    let page: String
}

// Licenses (from licenses.json)
struct License: Codable {
    let name: String

    // Explicit initializer for clarity
    init(name: String) {
        self.name = name
    }

    // Custom decoding to handle string directly
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }

    // Custom encoding to output string
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

// Lifestyles (from lifestyles.json)
struct Lifestyle: Codable {
    let id: String
    let name: String
    let cost: String
    let dice: String?
    let lp: String?
    let multiplier: String?
    let source: String
    let page: String
}

// Contacts (from contacts.json)
struct Contact: Codable {
    let name: String
    let connection: Int
    let loyalty: Int
}

// Spells (from spells.json)
struct Spell: Codable {
    let id: String
    let name: String
    let page: String
    let source: String
    let category: String
    let damage: String
    let descriptor: String?
    let duration: String
    let dv: String
    let range: String
    let type: String
    let bonus: [String: AnyCodable]?
    let required: [String: AnyCodable]?

    init(
        id: String,
        name: String,
        page: String,
        source: String,
        category: String,
        damage: String,
        descriptor: String? = nil,
        duration: String,
        dv: String,
        range: String,
        type: String,
        bonus: [String: AnyCodable]? = nil,
        required: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.name = name
        self.page = page
        self.source = source
        self.category = category
        self.damage = damage
        self.descriptor = descriptor
        self.duration = duration
        self.dv = dv
        self.range = range
        self.type = type
        self.bonus = bonus
        self.required = required
    }

    enum CodingKeys: String, CodingKey {
        case id, name, page, source, category, damage, descriptor, duration, dv, range, type, bonus, required
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        page = try container.decode(String.self, forKey: .page)
        source = try container.decode(String.self, forKey: .source)
        category = try container.decode(String.self, forKey: .category)
        damage = try container.decode(String.self, forKey: .damage)
        
        // Decode descriptor as String or dictionary
        if let descriptorString = try? container.decode(String.self, forKey: .descriptor) {
            descriptor = descriptorString
        } else if let _ = try? container.decode([String: AnyCodable].self, forKey: .descriptor) {
            descriptor = nil // Treat empty dictionary as nil
        } else {
            descriptor = nil
        }
        
        duration = try container.decode(String.self, forKey: .duration)
        dv = try container.decode(String.self, forKey: .dv)
        range = try container.decode(String.self, forKey: .range)
        type = try container.decode(String.self, forKey: .type)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(page, forKey: .page)
        try container.encode(source, forKey: .source)
        try container.encode(category, forKey: .category)
        try container.encode(damage, forKey: .damage)
        
        // Encode descriptor: nil or String
        if let descriptor = descriptor {
            try container.encode(descriptor, forKey: .descriptor)
        } else {
            try container.encode([String: AnyCodable](), forKey: .descriptor) // Encode as empty dictionary
        }
        
        try container.encode(duration, forKey: .duration)
        try container.encode(dv, forKey: .dv)
        try container.encode(range, forKey: .range)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encodeIfPresent(required, forKey: .required)
    }
}

// Complex Forms (from complexforms.json)
struct ComplexForm: Codable {
    let id: String
    let name: String
    let target: String
    let duration: String
    let fv: String
    let source: String
    let page: String
}

// Powers (from powers.json)
struct Power: Codable {
    let id: String
    let name: String
    let points: String
    let levels: String
    let limit: String?
    let source: String
    let page: String
    let action: String?
}

// Traditions (from traditions.json)
struct Tradition: Codable {
    let id: String
    let name: String
    let drain: [String: String]?
    let source: String
    let page: String
    let spirits: [String: String]?
    let spiritform: String?
    let bonus: [String: AnyCodable]?
    let required: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id, name, drain, source, page, spirits, spiritform, bonus, required
    }

    init(
        id: String,
        name: String,
        drain: [String: String]?,
        source: String,
        page: String,
        spirits: [String: String]? = nil,
        spiritform: String? = nil,
        bonus: [String: AnyCodable]? = nil,
        required: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.name = name
        self.drain = drain
        self.source = source
        self.page = page
        self.spirits = spirits
        self.spiritform = spiritform
        self.bonus = bonus
        self.required = required
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        spirits = try container.decodeIfPresent([String: String].self, forKey: .spirits)
        spiritform = try container.decodeIfPresent(String.self, forKey: .spiritform)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)

        // Decode drain as String or Dictionary
        if let drainString = try? container.decode(String.self, forKey: .drain) {
            // Convert strings like "{WIL} + {CHA}" to dictionary
            let components = drainString
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .components(separatedBy: " + ")
            if components.count == 2 {
                let firstAttr = components[0].trimmingCharacters(in: .whitespaces)
                let secondAttr = components[1].trimmingCharacters(in: .whitespaces)
                let attrMap: [String: String] = [
                    "WIL": "Willpower",
                    "CHA": "Charisma",
                    "INT": "Intuition",
                    "LOG": "Logic",
                    "MAG": "Magic"
                ]
                if let firstMapped = attrMap[firstAttr], let secondMapped = attrMap[secondAttr] {
                    drain = [firstMapped: secondMapped]
                } else {
                    drain = nil
                }
            } else {
                drain = nil
            }
        } else if let drainDict = try? container.decode([String: String].self, forKey: .drain) {
            drain = drainDict.isEmpty ? nil : drainDict
        } else {
            drain = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        try container.encodeIfPresent(spirits, forKey: .spirits)
        try container.encodeIfPresent(spiritform, forKey: .spiritform)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encodeIfPresent(required, forKey: .required)

        // Encode drain: convert dictionary to string or empty dictionary
        if let drainDict = drain, !drainDict.isEmpty {
            let attrMap: [String: String] = [
                "Willpower": "WIL",
                "Charisma": "CHA",
                "Intuition": "INT",
                "Logic": "LOG",
                "Magic": "MAG"
            ]
            if let firstKey = drainDict.keys.first, let firstValue = drainDict[firstKey],
               let mappedKey = attrMap[firstKey], let mappedValue = attrMap[firstValue] {
                let drainString = "{\(mappedKey)} + {\(mappedValue)}"
                try container.encode(drainString, forKey: .drain)
            } else {
                try container.encode([String: String](), forKey: .drain)
            }
        } else {
            try container.encode([String: String](), forKey: .drain)
        }
    }
}

// Mentors (from mentors.json)
struct Choice: Codable {
    let name: String?
    let bonus: AnyCodable?

    // Explicit initializer
    init(name: String? = nil, bonus: AnyCodable? = nil) {
        self.name = name
        self.bonus = bonus
    }

    enum CodingKeys: String, CodingKey {
        case name, bonus
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        bonus = try container.decodeIfPresent(AnyCodable.self, forKey: .bonus)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(bonus, forKey: .bonus)
    }
}

struct Mentor: Codable {
    let id: String
    let name: String
    let advantage: String
    let disadvantage: String
    let choices: [Choice]?
    let bonus: [String: AnyCodable]?
    let required: [String: AnyCodable]?
    let source: String
    let page: String

    // Explicit initializer
    init(
        id: String,
        name: String,
        advantage: String,
        disadvantage: String,
        choices: [Choice]? = nil,
        bonus: [String: AnyCodable]? = nil,
        required: [String: AnyCodable]? = nil,
        source: String,
        page: String
    ) {
        self.id = id
        self.name = name
        self.advantage = advantage
        self.disadvantage = disadvantage
        self.choices = choices
        self.bonus = bonus
        self.required = required
        self.source = source
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case id, name, advantage, disadvantage, choices, bonus, required, source, page
    }

    enum ChoicesKeys: String, CodingKey {
        case choice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        advantage = try container.decode(String.self, forKey: .advantage)
        disadvantage = try container.decode(String.self, forKey: .disadvantage)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)

        // Decode choices
        if let choicesContainer = try? container.nestedContainer(keyedBy: ChoicesKeys.self, forKey: .choices) {
            choices = try choicesContainer.decodeIfPresent([Choice].self, forKey: .choice)
        } else {
            choices = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(advantage, forKey: .advantage)
        try container.encode(disadvantage, forKey: .disadvantage)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encodeIfPresent(required, forKey: .required)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)

        // Encode choices
        if let choices = choices {
            var choicesContainer = container.nestedContainer(keyedBy: ChoicesKeys.self, forKey: .choices)
            try choicesContainer.encode(choices, forKey: .choice)
        } else {
            try container.encodeNil(forKey: .choices)
        }
    }
}

// Metamagic (from metamagic.json)
struct Metamagic: Codable {
    let id: String
    let name: String
    let adept: String?
    let magician: String?
    let source: String
    let page: String
}

// Echoes (from echoes.json)
struct Echo: Codable {
    let id: String
    let name: String
    let source: String
    let page: String
    let bonus: AnyCodable?
    let limit: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, source, page, bonus, limit
    }
    
    init(id: String, name: String, source: String, page: String, bonus: AnyCodable?, limit: String?) {
        self.id = id
        self.name = name
        self.source = source
        self.page = page
        self.bonus = bonus
        self.limit = limit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        limit = try container.decodeIfPresent(String.self, forKey: .limit)
        
        // Handle bonus as a dictionary with flexible values
        if let bonusDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus) {
            bonus = AnyCodable(bonusDict)
        } else if let bonusDict = try? container.decodeIfPresent([String: [String: String]].self, forKey: .bonus) {
            bonus = AnyCodable(bonusDict)
        } else {
            bonus = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        try container.encodeIfPresent(limit, forKey: .limit)
        
        // Encode bonus
        if let bonus = bonus {
            switch bonus.value {
            case let dict as [String: Any]:
                try container.encode(dict.mapValues { AnyCodable($0) }, forKey: .bonus)
            case let dict as [String: [String: String]]:
                try container.encode(dict, forKey: .bonus)
            default:
                try container.encodeNil(forKey: .bonus)
            }
        } else {
            try container.encodeNil(forKey: .bonus)
        }
    }
}

// Spirits (from spirits.json)
struct Spirit: Codable {
    let id: String
    let name: String
    let bod: String
    let agi: String
    let rea: String
    let str: String
    let cha: String
    let int: String
    let log: String
    let wil: String
    let ini: String
    let source: String
    let page: String
    let optionalpowers: [String]?
    let powers: [String]?
    let skills: [Skill]?
}

// Improvements (from improvements.json)
struct Improvement: Codable {
    let id: String
    let name: String
    let `internal`: String?
    let fields: [String: AnyCodable]?
    let xml: AnyCodable?
    let page: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, `internal`, fields, xml, page
    }
    
    enum FieldsKeys: String, CodingKey {
        case field
    }
    
    init(id: String, name: String, `internal`: String?, fields: [String: AnyCodable]?, xml: AnyCodable?, page: String?) {
        self.id = id
        self.name = name
        self.`internal` = `internal`
        self.fields = fields
        self.xml = xml
        self.page = page
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        `internal` = try container.decodeIfPresent(String.self, forKey: .`internal`)
        page = try container.decodeIfPresent(String.self, forKey: .page)
        
        // Handle fields as a dictionary
        if let fieldsContainer = try? container.nestedContainer(keyedBy: FieldsKeys.self, forKey: .fields) {
            // Try decoding field as a string or array
            if let fieldValue = try? fieldsContainer.decodeIfPresent(String.self, forKey: .field) {
                fields = ["field": AnyCodable(fieldValue)]
            } else if let fieldArray = try? fieldsContainer.decodeIfPresent([String].self, forKey: .field) {
                fields = ["field": AnyCodable(fieldArray)]
            } else {
                fields = nil
            }
        } else {
            fields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .fields)
        }
        
        // Handle xml as string or dictionary
        if let xmlString = try? container.decodeIfPresent(String.self, forKey: .xml) {
            xml = AnyCodable(xmlString)
        } else if let xmlDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .xml) {
            xml = AnyCodable(xmlDict)
        } else {
            xml = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(`internal`, forKey: .`internal`)
        try container.encodeIfPresent(page, forKey: .page)
        
        // Encode fields
        if let fields = fields {
            try container.encode(fields, forKey: .fields)
        } else {
            try container.encodeNil(forKey: .fields)
        }
        
        // Encode xml
        if let xml = xml {
            switch xml.value {
            case let string as String:
                try container.encode(string, forKey: .xml)
            case let dict as [String: Any]:
                try container.encode(dict.mapValues { AnyCodable($0) }, forKey: .xml)
            default:
                try container.encodeNil(forKey: .xml)
            }
        } else {
            try container.encodeNil(forKey: .xml)
        }
    }
}

// Books (from books.json)
struct Book: Codable {
    let id: String
    let name: String
    let code: String
    let matches: [Match]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, code, matches
    }
    
    enum MatchesKeys: String, CodingKey {
        case match
    }
    
    init(id: String, name: String, code: String, matches: [Match]?) {
        self.id = id
        self.name = name
        self.code = code
        self.matches = matches
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)
        
        // Handle matches as an object containing match
        if let matchesContainer = try? container.nestedContainer(keyedBy: MatchesKeys.self, forKey: .matches) {
            // Try decoding match as an array of Match
            if let matchArray = try? matchesContainer.decodeIfPresent([Match].self, forKey: .match) {
                matches = matchArray
            } else if let singleMatch = try? matchesContainer.decodeIfPresent(Match.self, forKey: .match) {
                matches = [singleMatch]
            } else {
                matches = nil
            }
        } else {
            matches = try container.decodeIfPresent([Match].self, forKey: .matches)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(code, forKey: .code)
        try container.encodeIfPresent(matches, forKey: .matches)
    }
}

struct Match: Codable {
    let language: String
    let text: String
    let page: String
}

// Generic type to handle varied JSON structures
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else {
            value = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String:
            try container.encode(string)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        default:
            try container.encode([String: AnyCodable]())
        }
    }
}

// Martial Arts (from martialarts.json)
struct Technique: Codable {
    let name: String
}

struct MartialArt: Codable {
    let id: String
    let name: String
    let bonus: [String: AnyCodable]?
    let techniques: [Technique]?
    let source: String
    let page: String
    let cost: String?
    let isquality: String?
    let alltechniques: [String: AnyCodable]?
    let required: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id, name, bonus, techniques, source, page, cost, isquality, alltechniques, required
    }

    enum TechniquesKeys: String, CodingKey {
        case technique
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
        cost = try container.decodeIfPresent(String.self, forKey: .cost)
        isquality = try container.decodeIfPresent(String.self, forKey: .isquality)
        alltechniques = try container.decodeIfPresent([String: AnyCodable].self, forKey: .alltechniques)
        required = try container.decodeIfPresent([String: AnyCodable].self, forKey: .required)

        // Decode techniques
        if let techniquesContainer = try? container.nestedContainer(keyedBy: TechniquesKeys.self, forKey: .techniques) {
            techniques = try techniquesContainer.decodeIfPresent([Technique].self, forKey: .technique)
        } else {
            techniques = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
        try container.encodeIfPresent(cost, forKey: .cost)
        try container.encodeIfPresent(isquality, forKey: .isquality)
        try container.encodeIfPresent(alltechniques, forKey: .alltechniques)
        try container.encodeIfPresent(required, forKey: .required)

        // Encode techniques
        if let techniques = techniques {
            var techniquesContainer = container.nestedContainer(keyedBy: TechniquesKeys.self, forKey: .techniques)
            try techniquesContainer.encode(techniques, forKey: .technique)
        } else {
            try container.encodeNil(forKey: .techniques)
        }
    }
}

// Ranges (from ranges.json)
struct Range: Codable {
    let name: String
    let min: String
    let short: String
    let medium: String
    let long: String
    let extreme: String
    
    // Computed property for category based on name prefix
    var category: String {
        let components = name.split(separator: " ")
        if components.contains("Pistol") {
            return "Pistols"
        } else if components.contains("Rifle") || components.contains("Sniper") {
            return "Rifles"
        } else if components.contains("Shotgun") {
            return "Shotguns"
        } else if components.contains("Machine") {
            return "Machine Guns"
        } else if components.contains("Cannon") {
            return "Cannons"
        } else {
            return "Other"
        }
    }
    
    // Computed property for maximum range (extreme) as Int for sorting
    var maxRange: Int {
        let cleaned = extreme.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return Int(cleaned) ?? 0
    }
}

// Actions (from actions.json)
struct Action: Codable {
    let name: String
    let type: String
    let requirements: String?
}

// Drug Components (from drugcomponents.json)
struct Attribute: Codable {
    let name: String
    let value: String
}

struct EffectQuality: Codable { // Renamed to avoid conflict with existing Quality
    let name: String
    let attributes: [String: String]?

    enum CodingKeys: String, CodingKey {
        case name = "_text"
        case attributes
    }
}

struct Effect: Codable {
    let level: String
    let attribute: [Attribute]?
    let quality: EffectQuality?
    let crashdamage: String?
    let info: String?
    let limit: [Limit]?

    enum CodingKeys: String, CodingKey {
        case level, attribute, quality, crashdamage, info, limit
    }

    struct Limit: Codable {
        let name: String
        let value: String
    }
}

struct DrugComponent: Codable {
    let id: String
    let name: String
    let category: String
    let effects: [Effect]?
    let availability: String
    let cost: String
    let rating: String?
    let threshold: String?
    let source: String
    let page: String

    // Explicit initializer
    init(
        id: String,
        name: String,
        category: String,
        effects: [Effect]? = nil,
        availability: String,
        cost: String,
        rating: String? = nil,
        threshold: String? = nil,
        source: String,
        page: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.effects = effects
        self.availability = availability
        self.cost = cost
        self.rating = rating
        self.threshold = threshold
        self.source = source
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category, effects, availability, cost, rating, threshold, source, page
    }

    enum EffectsKeys: String, CodingKey {
        case effect
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        availability = try container.decode(String.self, forKey: .availability)
        cost = try container.decode(String.self, forKey: .cost)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        threshold = try container.decodeIfPresent(String.self, forKey: .threshold)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)

        if let effectsContainer = try? container.nestedContainer(keyedBy: EffectsKeys.self, forKey: .effects) {
            if let effectArray = try? effectsContainer.decode([Effect].self, forKey: .effect) {
                effects = effectArray
            } else if let singleEffect = try? effectsContainer.decode(Effect.self, forKey: .effect) {
                effects = [singleEffect]
            } else {
                effects = nil
            }
        } else {
            effects = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(availability, forKey: .availability)
        try container.encode(cost, forKey: .cost)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(threshold, forKey: .threshold)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)

        if let effects = effects {
            var effectsContainer = container.nestedContainer(keyedBy: EffectsKeys.self, forKey: .effects)
            if effects.count == 1 {
                try effectsContainer.encode(effects[0], forKey: .effect)
            } else {
                try effectsContainer.encode(effects, forKey: .effect)
            }
        } else {
            try container.encodeNil(forKey: .effects)
        }
    }
}

// Metatypes (from metatypes.json)
struct Metavariant: Codable {
    let id: String
    let name: String
    let category: String
    let karma: String
    let bodmin: String
    let bodmax: String
    let bodaug: String
    let agimin: String
    let agimax: String
    let agiaug: String
    let reamin: String
    let reamax: String
    let reaaug: String
    let strmin: String
    let strmax: String
    let straug: String
    let chamin: String
    let chamax: String
    let chaaug: String
    let intmin: String
    let intmax: String
    let intaug: String
    let logmin: String
    let logmax: String
    let logaug: String
    let wilmin: String
    let wilmax: String
    let wilaug: String
    let inimin: String
    let inimax: String
    let iniaug: String
    let edgmin: String
    let edgmax: String
    let edgaug: String
    let magmin: String
    let magmax: String
    let magaug: String
    let resmin: String
    let resmax: String
    let resaug: String
    let essmin: String
    let essmax: String
    let essaug: String
    let depmin: String
    let depmax: String
    let depaug: String
    let qualities: Qualities?
    let bonus: [String: AnyCodable]?
    let source: String
    let page: String

    struct Qualities: Codable {
        let positive: Positive?
        let negative: Negative?

        struct Positive: Codable {
            let quality: [String]?
        }

        struct Negative: Codable {
            let quality: [String]?
        }

        init(positive: Positive? = nil, negative: Negative? = nil) {
            self.positive = positive
            self.negative = negative
        }
    }

    init(
        id: String,
        name: String,
        category: String,
        karma: String,
        bodmin: String,
        bodmax: String,
        bodaug: String,
        agimin: String,
        agimax: String,
        agiaug: String,
        reamin: String,
        reamax: String,
        reaaug: String,
        strmin: String,
        strmax: String,
        straug: String,
        chamin: String,
        chamax: String,
        chaaug: String,
        intmin: String,
        intmax: String,
        intaug: String,
        logmin: String,
        logmax: String,
        logaug: String,
        wilmin: String,
        wilmax: String,
        wilaug: String,
        inimin: String,
        inimax: String,
        iniaug: String,
        edgmin: String,
        edgmax: String,
        edgaug: String,
        magmin: String,
        magmax: String,
        magaug: String,
        resmin: String,
        resmax: String,
        resaug: String,
        essmin: String,
        essmax: String,
        essaug: String,
        depmin: String,
        depmax: String,
        depaug: String,
        qualities: Qualities? = nil,
        bonus: [String: AnyCodable]? = nil,
        source: String,
        page: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.karma = karma
        self.bodmin = bodmin
        self.bodmax = bodmax
        self.bodaug = bodaug
        self.agimin = agimin
        self.agimax = agimax
        self.agiaug = agiaug
        self.reamin = reamin
        self.reamax = reamax
        self.reaaug = reaaug
        self.strmin = strmin
        self.strmax = strmax
        self.straug = straug
        self.chamin = chamin
        self.chamax = chamax
        self.chaaug = chaaug
        self.intmin = intmin
        self.intmax = intmax
        self.intaug = intaug
        self.logmin = logmin
        self.logmax = logmax
        self.logaug = logaug
        self.wilmin = wilmin
        self.wilmax = wilmax
        self.wilaug = wilaug
        self.inimin = inimin
        self.inimax = inimax
        self.iniaug = iniaug
        self.edgmin = edgmin
        self.edgmax = edgmax
        self.edgaug = edgaug
        self.magmin = magmin
        self.magmax = magmax
        self.magaug = magaug
        self.resmin = resmin
        self.resmax = resmax
        self.resaug = resaug
        self.essmin = essmin
        self.essmax = essmax
        self.essaug = essaug
        self.depmin = depmin
        self.depmax = depmax
        self.depaug = depaug
        self.qualities = qualities
        self.bonus = bonus
        self.source = source
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category, karma, bodmin, bodmax, bodaug, agimin, agimax, agiaug
        case reamin, reamax, reaaug, strmin, strmax, straug, chamin, chamax, chaaug
        case intmin, intmax, intaug, logmin, logmax, logaug, wilmin, wilmax, wilaug
        case inimin, inimax, iniaug, edgmin, edgmax, edgaug, magmin, magmax, magaug
        case resmin, resmax, resaug, essmin, essmax, essaug, depmin, depmax, depaug
        case qualities, bonus, source, page
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)

        // Decode karma as String or [String]
        if let karmaString = try? container.decode(String.self, forKey: .karma) {
            karma = karmaString
        } else if let karmaArray = try? container.decode([String].self, forKey: .karma) {
            karma = karmaArray.joined(separator: ",")
        } else {
            throw DecodingError.dataCorruptedError(forKey: .karma, in: container, debugDescription: "Expected String or [String] for karma")
        }

        bodmin = try container.decode(String.self, forKey: .bodmin)
        bodmax = try container.decode(String.self, forKey: .bodmax)
        bodaug = try container.decode(String.self, forKey: .bodaug)
        agimin = try container.decode(String.self, forKey: .agimin)
        agimax = try container.decode(String.self, forKey: .agimax)
        agiaug = try container.decode(String.self, forKey: .agiaug)
        reamin = try container.decode(String.self, forKey: .reamin)
        reamax = try container.decode(String.self, forKey: .reamax)
        reaaug = try container.decode(String.self, forKey: .reaaug)
        strmin = try container.decode(String.self, forKey: .strmin)
        strmax = try container.decode(String.self, forKey: .strmax)
        straug = try container.decode(String.self, forKey: .straug)
        chamin = try container.decode(String.self, forKey: .chamin)
        chamax = try container.decode(String.self, forKey: .chamax)
        chaaug = try container.decode(String.self, forKey: .chaaug)
        intmin = try container.decode(String.self, forKey: .intmin)
        intmax = try container.decode(String.self, forKey: .intmax)
        intaug = try container.decode(String.self, forKey: .intaug)
        logmin = try container.decode(String.self, forKey: .logmin)
        logmax = try container.decode(String.self, forKey: .logmax)
        logaug = try container.decode(String.self, forKey: .logaug)
        wilmin = try container.decode(String.self, forKey: .wilmin)
        wilmax = try container.decode(String.self, forKey: .wilmax)
        wilaug = try container.decode(String.self, forKey: .wilaug)
        inimin = try container.decode(String.self, forKey: .inimin)
        inimax = try container.decode(String.self, forKey: .inimax)
        iniaug = try container.decode(String.self, forKey: .iniaug)
        edgmin = try container.decode(String.self, forKey: .edgmin)
        edgmax = try container.decode(String.self, forKey: .edgmax)
        edgaug = try container.decode(String.self, forKey: .edgaug)
        magmin = try container.decode(String.self, forKey: .magmin)
        magmax = try container.decode(String.self, forKey: .magmax)
        magaug = try container.decode(String.self, forKey: .magaug)
        resmin = try container.decode(String.self, forKey: .resmin)
        resmax = try container.decode(String.self, forKey: .resmax)
        resaug = try container.decode(String.self, forKey: .resaug)
        essmin = try container.decode(String.self, forKey: .essmin)
        essmax = try container.decode(String.self, forKey: .essmax)
        essaug = try container.decode(String.self, forKey: .essaug)
        depmin = try container.decode(String.self, forKey: .depmin)
        depmax = try container.decode(String.self, forKey: .depmax)
        depaug = try container.decode(String.self, forKey: .depaug)
        qualities = try container.decodeIfPresent(Qualities.self, forKey: .qualities)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(karma, forKey: .karma)
        try container.encode(bodmin, forKey: .bodmin)
        try container.encode(bodmax, forKey: .bodmax)
        try container.encode(bodaug, forKey: .bodaug)
        try container.encode(agimin, forKey: .agimin)
        try container.encode(agimax, forKey: .agimax)
        try container.encode(agiaug, forKey: .agiaug)
        try container.encode(reamin, forKey: .reamin)
        try container.encode(reamax, forKey: .reamax)
        try container.encode(reaaug, forKey: .reaaug)
        try container.encode(strmin, forKey: .strmin)
        try container.encode(strmax, forKey: .strmax)
        try container.encode(straug, forKey: .straug)
        try container.encode(chamin, forKey: .chamin)
        try container.encode(chamax, forKey: .chamax)
        try container.encode(chaaug, forKey: .chaaug)
        try container.encode(intmin, forKey: .intmin)
        try container.encode(intmax, forKey: .intmax)
        try container.encode(intaug, forKey: .intaug)
        try container.encode(logmin, forKey: .logmin)
        try container.encode(logmax, forKey: .logmax)
        try container.encode(logaug, forKey: .logaug)
        try container.encode(wilmin, forKey: .wilmin)
        try container.encode(wilmax, forKey: .wilmax)
        try container.encode(wilaug, forKey: .wilaug)
        try container.encode(inimin, forKey: .inimin)
        try container.encode(inimax, forKey: .inimax)
        try container.encode(iniaug, forKey: .iniaug)
        try container.encode(edgmin, forKey: .edgmin)
        try container.encode(edgmax, forKey: .edgmax)
        try container.encode(edgaug, forKey: .edgaug)
        try container.encode(magmin, forKey: .magmin)
        try container.encode(magmax, forKey: .magmax)
        try container.encode(magaug, forKey: .magaug)
        try container.encode(resmin, forKey: .resmin)
        try container.encode(resmax, forKey: .resmax)
        try container.encode(resaug, forKey: .resaug)
        try container.encode(essmin, forKey: .essmin)
        try container.encode(essmax, forKey: .essmax)
        try container.encode(essaug, forKey: .essaug)
        try container.encode(depmin, forKey: .depmin)
        try container.encode(depmax, forKey: .depmax)
        try container.encode(depaug, forKey: .depaug)
        try container.encodeIfPresent(qualities, forKey: .qualities)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)
    }
}

struct Metatype: Codable {
    let id: String
    let name: String
    let karma: String
    let category: String
    let bodmin: String
    let bodmax: String
    let bodaug: String
    let agimin: String
    let agimax: String
    let agiaug: String
    let reamin: String
    let reamax: String
    let reaaug: String
    let strmin: String
    let strmax: String
    let straug: String
    let chamin: String
    let chamax: String
    let chaaug: String
    let intmin: String
    let intmax: String
    let intaug: String
    let logmin: String
    let logmax: String
    let logaug: String
    let wilmin: String
    let wilmax: String
    let wilaug: String
    let inimin: String
    let inimax: String
    let iniaug: String
    let edgmin: String
    let edgmax: String
    let edgaug: String
    let magmin: String
    let magmax: String
    let magaug: String
    let resmin: String
    let resmax: String
    let resaug: String
    let essmin: String
    let essmax: String
    let essaug: String
    let depmin: String
    let depmax: String
    let depaug: String
    let walk: String?
    let run: String?
    let sprint: String?
    let bonus: [String: AnyCodable]?
    let source: String
    let page: String
    let metavariants: [Metavariant]?

    init(
        id: String,
        name: String,
        karma: String,
        category: String,
        bodmin: String,
        bodmax: String,
        bodaug: String,
        agimin: String,
        agimax: String,
        agiaug: String,
        reamin: String,
        reamax: String,
        reaaug: String,
        strmin: String,
        strmax: String,
        straug: String,
        chamin: String,
        chamax: String,
        chaaug: String,
        intmin: String,
        intmax: String,
        intaug: String,
        logmin: String,
        logmax: String,
        logaug: String,
        wilmin: String,
        wilmax: String,
        wilaug: String,
        inimin: String,
        inimax: String,
        iniaug: String,
        edgmin: String,
        edgmax: String,
        edgaug: String,
        magmin: String,
        magmax: String,
        magaug: String,
        resmin: String,
        resmax: String,
        resaug: String,
        essmin: String,
        essmax: String,
        essaug: String,
        depmin: String,
        depmax: String,
        depaug: String,
        walk: String? = nil,
        run: String? = nil,
        sprint: String? = nil,
        bonus: [String: AnyCodable]? = nil,
        source: String,
        page: String,
        metavariants: [Metavariant]? = nil
    ) {
        self.id = id
        self.name = name
        self.karma = karma
        self.category = category
        self.bodmin = bodmin
        self.bodmax = bodmax
        self.bodaug = bodaug
        self.agimin = agimin
        self.agimax = agimax
        self.agiaug = agiaug
        self.reamin = reamin
        self.reamax = reamax
        self.reaaug = reaaug
        self.strmin = strmin
        self.strmax = strmax
        self.straug = straug
        self.chamin = chamin
        self.chamax = chamax
        self.chaaug = chaaug
        self.intmin = intmin
        self.intmax = intmax
        self.intaug = intaug
        self.logmin = logmin
        self.logmax = logmax
        self.logaug = logaug
        self.wilmin = wilmin
        self.wilmax = wilmax
        self.wilaug = wilaug
        self.inimin = inimin
        self.inimax = inimax
        self.iniaug = iniaug
        self.edgmin = edgmin
        self.edgmax = edgmax
        self.edgaug = edgaug
        self.magmin = magmin
        self.magmax = magmax
        self.magaug = magaug
        self.resmin = resmin
        self.resmax = resmax
        self.resaug = resaug
        self.essmin = essmin
        self.essmax = essmax
        self.essaug = essaug
        self.depmin = depmin
        self.depmax = depmax
        self.depaug = depaug
        self.walk = walk
        self.run = run
        self.sprint = sprint
        self.bonus = bonus
        self.source = source
        self.page = page
        self.metavariants = metavariants
    }

    enum CodingKeys: String, CodingKey {
        case id, name, karma, category, bodmin, bodmax, bodaug, agimin, agimax, agiaug
        case reamin, reamax, reaaug, strmin, strmax, straug, chamin, chamax, chaaug
        case intmin, intmax, intaug, logmin, logmax, logaug, wilmin, wilmax, wilaug
        case inimin, inimax, iniaug, edgmin, edgmax, edgaug, magmin, magmax, magaug
        case resmin, resmax, resaug, essmin, essmax, essaug, depmin, depmax, depaug
        case walk, run, sprint, bonus, source, page, metavariants
    }

    enum MetavariantsKeys: String, CodingKey {
        case metavariant
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        karma = try container.decode(String.self, forKey: .karma)
        category = try container.decode(String.self, forKey: .category)
        bodmin = try container.decode(String.self, forKey: .bodmin)
        bodmax = try container.decode(String.self, forKey: .bodmax)
        bodaug = try container.decode(String.self, forKey: .bodaug)
        agimin = try container.decode(String.self, forKey: .agimin)
        agimax = try container.decode(String.self, forKey: .agimax)
        agiaug = try container.decode(String.self, forKey: .agiaug)
        reamin = try container.decode(String.self, forKey: .reamin)
        reamax = try container.decode(String.self, forKey: .reamax)
        reaaug = try container.decode(String.self, forKey: .reaaug)
        strmin = try container.decode(String.self, forKey: .strmin)
        strmax = try container.decode(String.self, forKey: .strmax)
        straug = try container.decode(String.self, forKey: .straug)
        chamin = try container.decode(String.self, forKey: .chamin)
        chamax = try container.decode(String.self, forKey: .chamax)
        chaaug = try container.decode(String.self, forKey: .chaaug)
        intmin = try container.decode(String.self, forKey: .intmin)
        intmax = try container.decode(String.self, forKey: .intmax)
        intaug = try container.decode(String.self, forKey: .intaug)
        logmin = try container.decode(String.self, forKey: .logmin)
        logmax = try container.decode(String.self, forKey: .logmax)
        logaug = try container.decode(String.self, forKey: .logaug)
        wilmin = try container.decode(String.self, forKey: .wilmin)
        wilmax = try container.decode(String.self, forKey: .wilmax)
        wilaug = try container.decode(String.self, forKey: .wilaug)
        inimin = try container.decode(String.self, forKey: .inimin)
        inimax = try container.decode(String.self, forKey: .inimax)
        iniaug = try container.decode(String.self, forKey: .iniaug)
        edgmin = try container.decode(String.self, forKey: .edgmin)
        edgmax = try container.decode(String.self, forKey: .edgmax)
        edgaug = try container.decode(String.self, forKey: .edgaug)
        magmin = try container.decode(String.self, forKey: .magmin)
        magmax = try container.decode(String.self, forKey: .magmax)
        magaug = try container.decode(String.self, forKey: .magaug)
        resmin = try container.decode(String.self, forKey: .resmin)
        resmax = try container.decode(String.self, forKey: .resmax)
        resaug = try container.decode(String.self, forKey: .resaug)
        essmin = try container.decode(String.self, forKey: .essmin)
        essmax = try container.decode(String.self, forKey: .essmax)
        essaug = try container.decode(String.self, forKey: .essaug)
        depmin = try container.decode(String.self, forKey: .depmin)
        depmax = try container.decode(String.self, forKey: .depmax)
        depaug = try container.decode(String.self, forKey: .depaug)
        walk = try container.decodeIfPresent(String.self, forKey: .walk)
        run = try container.decodeIfPresent(String.self, forKey: .run)
        sprint = try container.decodeIfPresent(String.self, forKey: .sprint)
        bonus = try container.decodeIfPresent([String: AnyCodable].self, forKey: .bonus)
        source = try container.decode(String.self, forKey: .source)
        page = try container.decode(String.self, forKey: .page)

        // Decode metavariants
        if let variantsContainer = try? container.nestedContainer(keyedBy: MetavariantsKeys.self, forKey: .metavariants) {
            if let variantArray = try? variantsContainer.decode([Metavariant].self, forKey: .metavariant) {
                metavariants = variantArray
            } else if let singleVariant = try? variantsContainer.decode(Metavariant.self, forKey: .metavariant) {
                metavariants = [singleVariant]
            } else {
                metavariants = nil
            }
        } else {
            metavariants = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(karma, forKey: .karma)
        try container.encode(category, forKey: .category)
        try container.encode(bodmin, forKey: .bodmin)
        try container.encode(bodmax, forKey: .bodmax)
        try container.encode(bodaug, forKey: .bodaug)
        try container.encode(agimin, forKey: .agimin)
        try container.encode(agimax, forKey: .agimax)
        try container.encode(agiaug, forKey: .agiaug)
        try container.encode(reamin, forKey: .reamin)
        try container.encode(reamax, forKey: .reamax)
        try container.encode(reaaug, forKey: .reaaug)
        try container.encode(strmin, forKey: .strmin)
        try container.encode(strmax, forKey: .strmax)
        try container.encode(straug, forKey: .straug)
        try container.encode(chamin, forKey: .chamin)
        try container.encode(chamax, forKey: .chamax)
        try container.encode(chaaug, forKey: .chaaug)
        try container.encode(intmin, forKey: .intmin)
        try container.encode(intmax, forKey: .intmax)
        try container.encode(intaug, forKey: .intaug)
        try container.encode(logmin, forKey: .logmin)
        try container.encode(logmax, forKey: .logmax)
        try container.encode(logaug, forKey: .logaug)
        try container.encode(wilmin, forKey: .wilmin)
        try container.encode(wilmax, forKey: .wilmax)
        try container.encode(wilaug, forKey: .wilaug)
        try container.encode(inimin, forKey: .inimin)
        try container.encode(inimax, forKey: .inimax)
        try container.encode(iniaug, forKey: .iniaug)
        try container.encode(edgmin, forKey: .edgmin)
        try container.encode(edgmax, forKey: .edgmax)
        try container.encode(edgaug, forKey: .edgaug)
        try container.encode(magmin, forKey: .magmin)
        try container.encode(magmax, forKey: .magmax)
        try container.encode(magaug, forKey: .magaug)
        try container.encode(resmin, forKey: .resmin)
        try container.encode(resmax, forKey: .resmax)
        try container.encode(resaug, forKey: .resaug)
        try container.encode(essmin, forKey: .essmin)
        try container.encode(essmax, forKey: .essmax)
        try container.encode(essaug, forKey: .essaug)
        try container.encode(depmin, forKey: .depmin)
        try container.encode(depmax, forKey: .depmax)
        try container.encode(depaug, forKey: .depaug)
        try container.encodeIfPresent(walk, forKey: .walk)
        try container.encodeIfPresent(run, forKey: .run)
        try container.encodeIfPresent(sprint, forKey: .sprint)
        try container.encodeIfPresent(bonus, forKey: .bonus)
        try container.encode(source, forKey: .source)
        try container.encode(page, forKey: .page)

        // Encode metavariants
        if let variants = metavariants {
            var variantsContainer = container.nestedContainer(keyedBy: MetavariantsKeys.self, forKey: .metavariants)
            if variants.count == 1 {
                try variantsContainer.encode(variants[0], forKey: .metavariant)
            } else {
                try variantsContainer.encode(variants, forKey: .metavariant)
            }
        } else {
            try container.encodeNil(forKey: .metavariants)
        }
    }
}
