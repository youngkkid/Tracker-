import Foundation

final class OnboardingService {
    private let onboardingKey = "onboardingShow"
    private let userDefaults = UserDefaults.standard
    
    var isOnboardingShown: Bool {
        get {
            userDefaults.bool(forKey: onboardingKey)
        }
        set {
            userDefaults.set(newValue, forKey: onboardingKey)
        }
    }
}
