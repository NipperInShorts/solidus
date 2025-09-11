//
//  ReviewRequestManager.swift
//  Solidus
//
//  Created by Justin Nipper on 9/11/25.
//

import Foundation
import StoreKit
import SwiftUI

final class ReviewRequestManager {
    static let shared = ReviewRequestManager()
    
    @AppStorage("lastPromptDate") private var lastPromptDateString: String = ""
    @AppStorage("visitCount") private var visitCount: Int = 0
    @Environment(\.requestReview) private var storeKitRequestReview
    
    private let visitThreshold = 3
    private let promptInterval: TimeInterval = 4 * 30 * 24 * 60 * 60
    
    @MainActor
    func incrementVisitCountAndCheckForReview(using requestReview: () -> Void) {
        visitCount += 1
        checkForReview(using: requestReview)
    }
    
    func shouldRequestReview() -> Bool {
        if visitCount < visitThreshold { return false }
        
        guard !lastPromptDateString.isEmpty else {
            return true
        }
        
        guard let lastPromptDate = DateFormatter.localizedStringToDate(lastPromptDateString), Calendar.current.dateComponents([.month], from: lastPromptDate, to: .now).month ?? 0 >= 4 else {
            return false
        }
        return true
    }
    
    @MainActor
    private func checkForReview(using requestReview: ()-> Void) {
        if shouldRequestReview() {
            requestReview()
               
            visitCount = 0
            lastPromptDateString = DateFormatter.localizedString(from: .now)
        }
    }
}

extension DateFormatter {
    static func localizedString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    static func localizedStringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.date(from: string)
    }
}
