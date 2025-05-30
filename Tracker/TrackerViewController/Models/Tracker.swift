import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
    let isHabit: Bool
    
    init(trackerCoreData: TrackerCoreData) {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let colorHex = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let scheduleData = trackerCoreData.schedule
        else {
            fatalError("Invalid of initialisations for Tracker")
        }
        
        self.id = id
        self.name = name
        self.color = .fromHex(colorHex)
        self.emoji = emoji
        self.isHabit = trackerCoreData.isHabit
        
        do {
            self.schedule = try JSONDecoder().decode([DayOfWeek].self, from: scheduleData)
        } catch {
            fatalError("Failed to decode schedule: \(error)")
        }
    }
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [DayOfWeek], isHabit: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
    }
}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    static func fromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
