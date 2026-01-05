//
//  LessonLearnedDBRepositoryProtocol.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

protocol LessonLearnedDBRepositoryProtocol {
    func save(_ lessons: [LessonLearned]) throws
    func fetchAll() throws -> [LessonLearned]
    func delete(id: Int) throws
}
