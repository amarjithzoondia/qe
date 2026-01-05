//
//  LessonLearnedDBUseCase.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import Foundation

final class LessonLearnedDBUseCase {
    private let repository: LessonLearnedDBRepositoryProtocol
    
    init(repository: LessonLearnedDBRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveLessons(_ lessons: [LessonLearned]) throws {
        try repository.save(lessons)
    }
    
    func getLessons() throws -> [LessonLearned] {
        try repository.fetchAll()
    }
    
    func deleteLesson(_ lesson: LessonLearned) throws {
        try repository.delete(id: lesson.id)
    }
}
