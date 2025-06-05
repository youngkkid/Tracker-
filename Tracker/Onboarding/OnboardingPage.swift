import UIKit

enum OnboardingPage: CaseIterable {
    case first
    case second
    
    var text: String {
        switch self {
        case .first:
            return "Отслеживайте только то, что хотите"
        case  .second:
            return "Даже если это \nне литры воды и йога"
        }
    }
    
    var buttonText: String {
        return "Вот это технологии!"
    }
    
    var image: UIImage {
        switch self {
        case .first:
            return .firstOnboarding
        case .second:
            return .secondOnboarding
        }
    }
}
