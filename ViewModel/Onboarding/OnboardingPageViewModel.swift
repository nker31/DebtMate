//
//  OnboardingPageViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/18/24.
//

import Foundation

protocol OnboardingPageViewModelProtocol {
    func markOnBoardingComplete()
}

class OnboardingPageViewModel: OnboardingPageViewModelProtocol {
    func markOnBoardingComplete() {
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
    }
}
