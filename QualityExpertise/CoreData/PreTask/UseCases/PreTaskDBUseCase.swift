//
//  PreTaskDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class PreTaskDBUseCase {
    private let repository: PreTaskDBRepositoryProtocol
    
    init(repository: PreTaskDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func savePreTasks(_ preTask: [PreTask]) throws {
        try repository.save(preTask)
    }
    
    func getPreTasks() throws -> [PreTask] {
        try repository.fetchAll()
    }
    
    func deletePreTask(_ preTask: PreTask) throws {
        try repository.delete(id: preTask.id)
    }
    
    func savePreTaskContents(_ contents: [PreTaskAPI.Content], deletedContentIds: [Int], isContentsEmpty: Bool) throws {
        try repository.savePreTaskContents(contents, deletedContentIds: deletedContentIds, isContentsEmpty: isContentsEmpty)
    }
    
    func savePreTaskQuestions(_ questions: [PreTaskAPI.Question], deletedQuestionsIds: [Int], isQuestionsEmpty: Bool) throws {
        try repository.savePreTaskQuestions(questions, deletedQuestionsIds: deletedQuestionsIds, isQuestionsEmpty: isQuestionsEmpty)
    }
    
    func getLatestContentsUpdatedTime() throws -> String? {
        try repository.getLatestContentsUpdatedTime()
    }
    
    func getLatestQuestionsUpdatedTime() throws -> String? {
        try repository.getLatestQuestionsUpdatedTime()
    }
    
    func getPreTaskContents() throws -> [PreTaskAPI.Content] {
        try repository.getPreTaskContents()
    }
    
    func getPreTaskQuestions() throws -> [PreTaskAPI.Question] {
        try repository.getPreTaskQuestions()
    }
}
