import Foundation

struct OnboardingPage {
    let illustrationName: String
    let title: String
    let dotIndex: Int
}

extension OnboardingPage {
    static let all: [OnboardingPage] = [
        OnboardingPage(illustrationName: "onboarding_illustration",
                       title: "Trade anytime anywhere",
                       dotIndex: 0),
        OnboardingPage(illustrationName: "onboarding_illustration_3",
                       title: "Transact fast and easy",
                       dotIndex: 1),
        OnboardingPage(illustrationName: "onboarding_illustration_2",
                       title: "Save and invest at the same time",
                       dotIndex: 2)
    ]
}
