import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBar.isTranslucent = false
        
        let trackerViewController = TrackerViewController()
        let statisticViewController = StatisticsViewController()
        
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                        image: .trackerTabBarLogo,
                                                        selectedImage: .trackerTabBarLogoSelected)
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика",
                                                          image: .statisticsTabBarLogo,
                                                          selectedImage: .statisticsTabBarLogoSelected)
        
        viewControllers = [trackerViewController, statisticViewController]
        addTopLine(color: UIColor.gray, thickness: 0.5)
    }
    
    private func addTopLine(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0,
                              y: 0,
                              width: tabBar.frame.width,
                              height: thickness)
        tabBar.layer.addSublayer(border)
    }
}
