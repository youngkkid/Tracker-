import UIKit

final class OnboardingViewController: UIPageViewController {
    
    var onFinish: (() -> Void)?
    
    private lazy var onboardingView = OnboardingView()
    
    private lazy var pages: [UIViewController] = {
        return createSlides().map { slide in
            let vc = UIViewController()
            vc.view = slide
            return vc
        }
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.numberOfPages = pages.count
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFirstPage()
        setupPageControl()
        
        dataSource = self
        delegate = self
    }
    
    private func createSlides() -> [OnboardingView] {
        return OnboardingPage.allCases.map{ page in
            let view = OnboardingView()
            view.setPageLabelText(text: page.text)
            view.setButton(text: page.buttonText)
            view.setImageView(for: page.image)
            view.onFinish = {[weak self] in
                self?.onFinish?()
            }
            
            return view
        }
    }
    
    private func setFirstPage() {
        if let first = pages.first {
            setViewControllers([first],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}


extension OnboardingViewController {
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

