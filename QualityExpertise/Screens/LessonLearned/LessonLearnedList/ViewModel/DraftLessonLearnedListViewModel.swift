//
//  DraftLessonLearnedListViewModel.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//


import Foundation

class DraftLessonLearnedListViewModel: BaseViewModel, ObservableObject {
    @Published var lessons: [LessonLearned] = []
    
    private let localRepository = LessonLearnedDBRepository()
    private let localUseCase: LessonLearnedDBUseCase
    
    override init() {
        localUseCase = LessonLearnedDBUseCase(repository: localRepository)
    }
    
    func fetchDraftList() {
        self.error = nil
        self.noDataFound = false
        do {
            let lessons = try localUseCase.getLessons()
            DispatchQueue.safeAsyncMain {
                self.lessons = lessons
                self.noDataFound = lessons.isEmpty
            }
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
        }
    }
    
    func deleteViolation(lesson: LessonLearned) -> Bool {
        do {
            try localUseCase.deleteLesson(lesson)
            return true
        } catch {
            DispatchQueue.safeAsyncMain {
                self.error = error.systemError
            }
            return false
        }
    }
}
