import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
    let equipmentSetup: EquipmentSetup?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case equipmentSetup = "equipment_setup"
    }

    init(id: UUID = UUID(), username: String, equipmentSetup: EquipmentSetup? = nil) {
        self.id = id
        self.username = username
        self.equipmentSetup = equipmentSetup
    }
}

struct EquipmentSetup: Codable {
    let grinder: String?
    let machine: String?
    let tamper: String?

    init(grinder: String? = nil, machine: String? = nil, tamper: String? = nil) {
        self.grinder = grinder
        self.machine = machine
        self.tamper = tamper
    }
}
