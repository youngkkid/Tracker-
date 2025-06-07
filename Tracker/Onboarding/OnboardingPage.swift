import UIKit

enum OnboardingPage: CaseIterable {
    case first
    case second
    
    var text: String {
        switch self {
        case .first: "Отслеживайте только то, что хотите"
        case  .second: "Даже если это \nне литры воды и йога"
        }
    }
    
    var buttonText: String {
        "Вот это технологии!"
    }
    
    var image: UIImage {
        switch self {
        case .first: .firstOnboarding
        case .second: .secondOnboarding
        }
    }
}
