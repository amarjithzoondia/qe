//
//  QuestionDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class QuestionDBUseCase {
    private let repository: QuestionDBRepositoryProtocol
    
    init(repository: QuestionDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveQuestions(_ questions: [Questions]) throws {
        try repository.save(questions)
    }
    
    func getQuestions(_ auditItemId: Int) throws -> Questions {
        try repository.fetchQuestions(auditItemId)
    }
    
    func getUpdatedTime() throws -> Date? {
        try repository.getUpdatedTime()
    }
    
}
