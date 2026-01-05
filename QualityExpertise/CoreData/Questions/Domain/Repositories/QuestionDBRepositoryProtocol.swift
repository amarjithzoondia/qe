//
//  QuestionDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

protocol QuestionDBRepositoryProtocol {
    func save(_ responses: [Questions]) throws
    func fetchQuestions(_ auditItemId: Int) throws -> Questions
    func getUpdatedTime() throws -> Date?
}
