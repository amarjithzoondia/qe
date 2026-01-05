//
//  PreTaskDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

protocol PreTaskDBRepositoryProtocol {
    func save(_ preTask: [PreTask]) throws
    func fetchAll() throws -> [PreTask]
    func delete(id: Int) throws
    func savePreTaskContents(_ contents: [PreTaskAPI.Content], deletedContentIds: [Int], isContentsEmpty: Bool) throws
    func savePreTaskQuestions(_ questions: [PreTaskAPI.Question], deletedQuestionsIds: [Int], isQuestionsEmpty: Bool) throws
    func getLatestContentsUpdatedTime() throws -> String?
    func getLatestQuestionsUpdatedTime() throws -> String?
    func getPreTaskContents() throws -> [PreTaskAPI.Content]
    func getPreTaskQuestions() throws -> [PreTaskAPI.Question]
}
