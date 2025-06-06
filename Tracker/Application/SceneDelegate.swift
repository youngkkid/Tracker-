import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let onboardingService = OnboardingService()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        if onboardingService.isOnboardingShown {
            window?.rootViewController = TabBarController()
        } else {
            let onboardingViewController = OnboardingViewController(transitionStyle: .scroll,
                                                                    navigationOrientation: .horizontal)
            onboardingViewController.onFinish = {[weak self] in
                guard let self = self else {return}
                self.onboardingService.isOnboardingShown = true
                self.window?.rootViewController = TabBarController()
            }
            window?.rootViewController = onboardingViewController
            
        }
        
        window?.makeKeyAndVisible()
    }
}

