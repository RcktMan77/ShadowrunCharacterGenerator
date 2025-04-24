//
//  DataManager.swift
//  ShadowrunCharacterGenerator
//
//  Created by Zach Davis on 4/23/25.
//

import Foundation

class DataManager: ObservableObject {
    @Published var priorityData: PriorityData
    @Published var skills: [Skill] = []
    @Published var qualities: [Quality] = []
    @Published var books: [Book] = []
    @Published var complexForms: [ComplexForm] = []
    @Published var contacts: [Contact] = []
    @Published var contactMetadata: ContactMetadata?
    @Published var echoes: [Echo] = []
    @Published var improvements: [Improvement] = []
    @Published var gear: [Gear] = []
    @Published var armor: [Armor] = []
    @Published var weapons: [Weapon] = []
    @Published var cyberware: [Cyberware] = []
    @Published var bioware: [Bioware] = []
    @Published var programs: [Program] = []
    @Published var licenses: [License] = []
    @Published var lifestyles: [Lifestyle] = []
    @Published var spells: [Spell] = []
    @Published var powers: [Power] = []
    @Published var traditions: [Tradition] = []
    @Published var mentors: [Mentor] = []
    @Published var metamagics: [Metamagic] = []
    @Published var martialArts: [MartialArt] = []
    @Published var metatypes: [Metatype] = []
    @Published var drugComponents: [DrugComponent] = []

    init() {
        self.priorityData = PriorityData(
            metatype: [:],
            attributes: [:],
            skills: [:],
            magic: [:],
            resources: [:]
        )
        self.contactMetadata = nil
        loadData()
    }

    private func loadData() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Load books.json
        if let url = Bundle.main.url(forResource: "books", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(BookWrapper.self, from: data)
                self.books = wrapper.chummer.books.book
            } catch {
                print("Error decoding books.json: \(error)")
            }
        }

        // Load complexforms.json
        if let url = Bundle.main.url(forResource: "complexforms", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ComplexFormWrapper.self, from: data)
                self.complexForms = wrapper.chummer.complexforms.complexform
            } catch {
                print("Error decoding complexforms.json: \(error)")
            }
        }

        // Load contacts.json
        if let url = Bundle.main.url(forResource: "contacts", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ContactWrapper.self, from: data)
                self.contacts = wrapper.chummer.contacts.contact.map { Contact(name: $0, connection: 1, loyalty: 1) }
                self.contactMetadata = ContactMetadata(
                    genders: wrapper.chummer.genders.gender,
                    types: wrapper.chummer.types.type,
                    preferredPayments: wrapper.chummer.preferredpayments.preferredpayment,
                    ages: wrapper.chummer.ages.age,
                    personalLives: wrapper.chummer.personallives.personallife,
                    hobbiesVices: wrapper.chummer.hobbiesvices.hobbyvice
                )
            } catch {
                print("Error decoding contacts.json: \(error)")
            }
        }

        // Load echoes.json
        if let url = Bundle.main.url(forResource: "echoes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(EchoWrapper.self, from: data)
                self.echoes = wrapper.chummer.echoes.echo
            } catch {
                print("Error decoding echoes.json: \(error)")
            }
        }

        // Load improvements.json
        if let url = Bundle.main.url(forResource: "improvements", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ImprovementWrapper.self, from: data)
                self.improvements = wrapper.chummer.improvements.improvement
            } catch {
                print("Error decoding improvements.json: \(error)")
            }
        }

        // Load priorities.json
        if let url = Bundle.main.url(forResource: "priorities", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(PriorityWrapper.self, from: data)
                self.priorityData = wrapper.toPriorityData()
            } catch {
                print("Error decoding priorities.json: \(error)")
            }
        }

        // Load skills.json
        if let url = Bundle.main.url(forResource: "skills", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(SkillWrapper.self, from: data)
                self.skills = wrapper.chummer.skills.skill
            } catch {
                print("Error decoding skills.json: \(error)")
            }
        }

        // Load qualities.json
        if let url = Bundle.main.url(forResource: "qualities", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(QualityWrapper.self, from: data)
                self.qualities = wrapper.chummer.qualities.quality
            } catch {
                print("Error decoding qualities.json: \(error)")
            }
        }

        // Load gear.json
        if let url = Bundle.main.url(forResource: "gear", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(GearWrapper.self, from: data)
                self.gear = wrapper.chummer.gears.gear
            } catch {
                print("Error decoding gear.json: \(error)")
            }
        }

        // Load armor.json
        if let url = Bundle.main.url(forResource: "armor", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ArmorWrapper.self, from: data)
                self.armor = wrapper.chummer.armors.armor
            } catch {
                print("Error decoding armor.json: \(error)")
            }
        }

        // Load weapons.json
        if let url = Bundle.main.url(forResource: "weapons", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(WeaponWrapper.self, from: data)
                self.weapons = wrapper.chummer.weapons.weapon
            } catch {
                print("Error decoding weapons.json: \(error)")
            }
        }

        // Load cyberware.json
        if let url = Bundle.main.url(forResource: "cyberware", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(CyberwareWrapper.self, from: data)
                self.cyberware = wrapper.chummer.cyberwares.cyberware
            } catch {
                print("Error decoding cyberware.json: \(error)")
            }
        }

        // Load bioware.json
        if let url = Bundle.main.url(forResource: "bioware", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(BiowareWrapper.self, from: data)
                self.bioware = wrapper.chummer.biowares.bioware
            } catch {
                print("Error decoding bioware.json: \(error)")
            }
        }

        // Load programs.json
        if let url = Bundle.main.url(forResource: "programs", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(ProgramWrapper.self, from: data)
                self.programs = wrapper.chummer.programs.program
            } catch {
                print("Error decoding programs.json: \(error)")
            }
        }

        // Load licenses.json
        if let url = Bundle.main.url(forResource: "licenses", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(LicenseWrapper.self, from: data)
                self.licenses = wrapper.chummer.licenses.license
            } catch {
                print("Error decoding licenses.json: \(error)")
            }
        }

        // Load lifestyles.json
        if let url = Bundle.main.url(forResource: "lifestyles", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(LifestyleWrapper.self, from: data)
                self.lifestyles = wrapper.chummer.lifestyles.lifestyle
            } catch {
                print("Error decoding lifestyles.json: \(error)")
            }
        }

        // Load spells.json
        if let url = Bundle.main.url(forResource: "spells", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(SpellWrapper.self, from: data)
                self.spells = wrapper.chummer.spells.spell
            } catch {
                print("Error decoding spells.json: \(error)")
            }
        }

        // Load powers.json
        if let url = Bundle.main.url(forResource: "powers", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(PowerWrapper.self, from: data)
                self.powers = wrapper.chummer.powers.power
            } catch {
                print("Error decoding powers.json: \(error)")
            }
        }

        // Load traditions.json
        if let url = Bundle.main.url(forResource: "traditions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(TraditionWrapper.self, from: data)
                self.traditions = wrapper.chummer.traditions.tradition
            } catch {
                print("Error decoding traditions.json: \(error)")
            }
        }

        // Load mentors.json
        if let url = Bundle.main.url(forResource: "mentors", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(MentorWrapper.self, from: data)
                self.mentors = wrapper.chummer.mentors.mentor
            } catch {
                print("Error decoding mentors.json: \(error)")
            }
        }

        // Load metamagic.json
        if let url = Bundle.main.url(forResource: "metamagic", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(MetamagicWrapper.self, from: data)
                self.metamagics = wrapper.chummer.metamagics.metamagic
            } catch {
                print("Error decoding metamagic.json: \(error)")
            }
        }

        // Load martialarts.json
        if let url = Bundle.main.url(forResource: "martialarts", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(MartialArtWrapper.self, from: data)
                self.martialArts = wrapper.chummer.martialarts.martialart
            } catch {
                print("Error decoding martialarts.json: \(error)")
            }
        }

        // Load metatypes.json
        if let url = Bundle.main.url(forResource: "metatypes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(MetatypeWrapper.self, from: data)
                self.metatypes = wrapper.chummer.metatypes.metatype
            } catch {
                print("Error decoding metatypes.json: \(error)")
            }
        }

        // Load drugcomponents.json
        if let url = Bundle.main.url(forResource: "drugcomponents", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wrapper = try decoder.decode(DrugComponentWrapper.self, from: data)
                self.drugComponents = wrapper.chummer.drugcomponents.drugcomponent
            } catch {
                print("Error decoding drugcomponents.json: \(error)")
            }
        }
    }
}

// Wrapper Structs for JSON Decoding
struct BookWrapper: Decodable {
    let chummer: ChummerBooks
    struct ChummerBooks: Decodable {
        let books: Books
    }
    struct Books: Decodable {
        let book: [Book]
    }
}

struct ComplexFormWrapper: Decodable {
    let chummer: ChummerComplexForms
    struct ChummerComplexForms: Decodable {
        let complexforms: ComplexForms
    }
    struct ComplexForms: Decodable {
        let complexform: [ComplexForm]
    }
}

struct ContactWrapper: Decodable {
    let chummer: ChummerContacts
    struct ChummerContacts: Decodable {
        let contacts: Contacts
        let genders: Genders
        let types: Types
        let preferredpayments: PreferredPayments
        let ages: Ages
        let personallives: PersonalLives
        let hobbiesvices: HobbiesVices
    }
    struct Contacts: Decodable {
        let contact: [String]
    }
    struct Genders: Decodable {
        let gender: [String]
    }
    struct Types: Decodable {
        let type: [String]
    }
    struct PreferredPayments: Decodable {
        let preferredpayment: [String]
    }
    struct Ages: Decodable {
        let age: [String]
    }
    struct PersonalLives: Decodable {
        let personallife: [String]
    }
    struct HobbiesVices: Decodable {
        let hobbyvice: [String]
    }
}

struct ContactMetadata {
    let genders: [String]
    let types: [String]
    let preferredPayments: [String]
    let ages: [String]
    let personalLives: [String]
    let hobbiesVices: [String]
}

struct EchoWrapper: Decodable {
    let chummer: ChummerEchoes
    struct ChummerEchoes: Decodable {
        let echoes: Echoes
    }
    struct Echoes: Decodable {
        let echo: [Echo]
    }
}

struct ImprovementWrapper: Decodable {
    let chummer: ChummerImprovements
    struct ChummerImprovements: Decodable {
        let improvements: Improvements
    }
    struct Improvements: Decodable {
        let improvement: [Improvement]
    }
}

struct PriorityWrapper: Decodable {
    let chummer: ChummerPriorities
    struct ChummerPriorities: Decodable {
        let priorities: Priorities
    }
    struct Priorities: Decodable {
        let priority: [RawPriorityData]
    }
}

struct SkillWrapper: Decodable {
    let chummer: ChummerSkills
    struct ChummerSkills: Decodable {
        let skills: Skills
    }
    struct Skills: Decodable {
        let skill: [Skill]
    }
}

struct QualityWrapper: Decodable {
    let chummer: ChummerQualities
    struct ChummerQualities: Decodable {
        let qualities: Qualities
    }
    struct Qualities: Decodable {
        let quality: [Quality]
    }
}

struct GearWrapper: Decodable {
    let chummer: ChummerGears
    struct ChummerGears: Decodable {
        let gears: Gears
    }
    struct Gears: Decodable {
        let gear: [Gear]
    }
}

struct ArmorWrapper: Decodable {
    let chummer: ChummerArmors
    struct ChummerArmors: Decodable {
        let armors: Armors
    }
    struct Armors: Decodable {
        let armor: [Armor]
    }
}

struct WeaponWrapper: Decodable {
    let chummer: ChummerWeapons
    struct ChummerWeapons: Decodable {
        let weapons: Weapons
    }
    struct Weapons: Decodable {
        let weapon: [Weapon]
    }
}

struct CyberwareWrapper: Decodable {
    let chummer: ChummerCyberwares
    struct ChummerCyberwares: Decodable {
        let cyberwares: Cyberwares
    }
    struct Cyberwares: Decodable {
        let cyberware: [Cyberware]
    }
}

struct BiowareWrapper: Decodable {
    let chummer: ChummerBiowares
    struct ChummerBiowares: Decodable {
        let biowares: Biowares
    }
    struct Biowares: Decodable {
        let bioware: [Bioware]
    }
}

struct ProgramWrapper: Decodable {
    let chummer: ChummerPrograms
    struct ChummerPrograms: Decodable {
        let programs: Programs
    }
    struct Programs: Decodable {
        let program: [Program]
    }
}

struct LicenseWrapper: Decodable {
    let chummer: ChummerLicenses
    struct ChummerLicenses: Decodable {
        let licenses: Licenses
    }
    struct Licenses: Decodable {
        let license: [License]
    }
}

struct LifestyleWrapper: Decodable {
    let chummer: ChummerLifestyles
    struct ChummerLifestyles: Decodable {
        let lifestyles: Lifestyles
    }
    struct Lifestyles: Decodable {
        let lifestyle: [Lifestyle]
    }
}

struct SpellWrapper: Decodable {
    let chummer: ChummerSpells
    struct ChummerSpells: Decodable {
        let spells: Spells
    }
    struct Spells: Decodable {
        let spell: [Spell]
    }
}

struct PowerWrapper: Decodable {
    let chummer: ChummerPowers
    struct ChummerPowers: Decodable {
        let powers: Powers
    }
    struct Powers: Decodable {
        let power: [Power]
    }
}

struct TraditionWrapper: Decodable {
    let chummer: ChummerTraditions
    struct ChummerTraditions: Decodable {
        let traditions: Traditions
    }
    struct Traditions: Decodable {
        let tradition: [Tradition]
    }
}

struct MentorWrapper: Decodable {
    let chummer: ChummerMentors
    struct ChummerMentors: Decodable {
        let mentors: Mentors
    }
    struct Mentors: Decodable {
        let mentor: [Mentor]
    }
}

struct MetamagicWrapper: Decodable {
    let chummer: ChummerMetamagics
    struct ChummerMetamagics: Decodable {
        let metamagics: Metamagics
    }
    struct Metamagics: Decodable {
        let metamagic: [Metamagic]
    }
}

struct MartialArtWrapper: Decodable {
    let chummer: ChummerMartialArts
    struct ChummerMartialArts: Decodable {
        let martialarts: MartialArts
    }
    struct MartialArts: Decodable {
        let martialart: [MartialArt]
    }
}

struct MetatypeWrapper: Decodable {
    let chummer: ChummerMetatypes
    struct ChummerMetatypes: Decodable {
        let metatypes: Metatypes
    }
    struct Metatypes: Decodable {
        let metatype: [Metatype]
    }
}

struct DrugComponentWrapper: Decodable {
    let chummer: ChummerDrugComponents
    struct ChummerDrugComponents: Decodable {
        let drugcomponents: DrugComponents
    }
    struct DrugComponents: Decodable {
        let drugcomponent: [DrugComponent]
    }
}

struct RawPriorityData: Decodable {
    let level: String
    let metatypes: Metatypes?
    let attributes: Int?
    let skills: SkillPriority?
    let magic: MagicPriority?
    let resources: Int?

    struct Metatypes: Decodable {
        let metatype: [MetatypeOption]
    }
}

extension PriorityWrapper {
    func toPriorityData() -> PriorityData {
        var metatype: [String: [MetatypeOption]] = [:]
        var attributes: [String: Int] = [:]
        var skills: [String: SkillPriority] = [:]
        var magic: [String: MagicPriority] = [:]
        var resources: [String: Int] = [:]

        for priority in chummer.priorities.priority {
            let level = priority.level
            if let metatypes = priority.metatypes?.metatype {
                metatype[level] = metatypes
            }
            if let attr = priority.attributes {
                attributes[level] = attr
            }
            if let skill = priority.skills {
                skills[level] = skill
            }
            if let mag = priority.magic {
                magic[level] = mag
            }
            if let res = priority.resources {
                resources[level] = res
            }
        }

        return PriorityData(
            metatype: metatype,
            attributes: attributes,
            skills: skills,
            magic: magic,
            resources: resources
        )
    }
}
