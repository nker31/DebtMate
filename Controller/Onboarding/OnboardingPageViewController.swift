//
//  OnboardingPageViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/17/24.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    // MARK: - Varibles
    private var viewModel: OnboardingPageViewModelProtocol
    private var pages: [UIViewController]
    
    // MARK: - UI Components
    let pageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .debtMateBlack
        pageControl.pageIndicatorTintColor = .separator
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let onBoardingSkipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(finishOnBoarding), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let onBoardingStartButton: UIButton = {
        let button = DebtMateButton(title: "Get Started")
        button.alpha = 0
        button.addTarget(self, action: #selector(finishOnBoarding), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(viewModel: OnboardingPageViewModelProtocol = OnboardingPageViewModel(), pages: [UIViewController] = [UIViewController]()) {
        self.viewModel = viewModel
        self.pages = pages
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        setupUI()
        setupOnboardingPages()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(pageControl)
        view.addSubview(onBoardingSkipButton)
        view.addSubview(onBoardingStartButton)
        
        NSLayoutConstraint.activate([
            onBoardingSkipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onBoardingSkipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            onBoardingSkipButton.heightAnchor.constraint(equalToConstant: 40),
            
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 40),
            
            onBoardingStartButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            onBoardingStartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onBoardingStartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onBoardingStartButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    private func setupOnboardingPages() {
        let pageOne = OnboardingViewController(imageName: "track",
                                               headline: String(localized: "onboarding_track_headline"),
                                               subheadline: String(localized: "onboarding_track_subheadline"))
        let pageTwo = OnboardingViewController(imageName: "manage-mockup",
                                               headline: String(localized: "onboarding_manage_headline"),
                                               subheadline: String(localized: "onboarding_manage_subheadline"))
        let pageThree = OnboardingViewController(imageName: "notify",
                                                 headline: String(localized: "onboarding_notify_headline"),
                                                 subheadline: String(localized: "onboarding_notify_subheadline"))
        
        pages.append(pageOne)
        pages.append(pageTwo)
        pages.append(pageThree)
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    private func updateButtonVisibility() {
        let isLastPage = pageControl.currentPage == pages.count - 1
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.onBoardingSkipButton.alpha = isLastPage ? 0 : 1
            self?.onBoardingStartButton.alpha = isLastPage ? 1 : 0
        }
    }
    
    private func navigateToAuth() {
        let loginViewController = UINavigationController(rootViewController: LoginViewController())
        setRootViewController(loginViewController)
    }
    
    // MARK: - Selectors
    @objc func finishOnBoarding() {
        viewModel.markOnBoardingComplete()
        navigateToAuth()
    }
    
    @objc func pageChanged() {
        setViewControllers([pages[pageControl.currentPage]], direction: .forward, animated: true, completion: nil)
        updateButtonVisibility()
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < (pages.count - 1) else {
            return nil
        }
        return pages[currentIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        
        pageControl.currentPage = currentIndex
        updateButtonVisibility()
    }
}
