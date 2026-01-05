//
//  InspectionDBRepository.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class QuestionDBRepository: QuestionDBRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    
    func save(_ responses: [Questions]) throws {
        let currentUpdatedTime = try getUpdatedTime()

        for response in responses {
            if response.updatedTime.repoDate() == currentUpdatedTime {
                continue
            }
            
            let fetchRequest: NSFetchRequest<QuestionsEntity> = QuestionsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "auditItemId == %d", response.auditItemId)

            let existing = try context.fetch(fetchRequest).first
            let entity = existing ?? QuestionsEntity(context: context)

            if existing == nil {
                entity.id = getNextQuestionId()
            }

            entity.auditItemId = Int64(response.auditItemId)
            entity.updatedTime = response.updatedTime
            entity.contents = try JSONEncoder().encode(response.contents)
        }

        try context.save()
    }


    
    func fetchQuestions(_ auditItemId: Int) throws -> Questions {
        let request: NSFetchRequest<QuestionsEntity> = QuestionsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "auditItemId == %d", auditItemId)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "No matching question found", code: 0)
        }

        let contents = try JSONDecoder().decode([EquipmentStatic].self, from: entity.contents)
        
        return Questions(
            id: Int(entity.id),
            updatedTime: entity.updatedTime,
            auditItemId: Int(entity.auditItemId),
            contents: contents
        )
    }
    
    func getUpdatedTime() throws -> Date? {
        let request: NSFetchRequest<QuestionsEntity> = QuestionsEntity.fetchRequest()
        let allQuestions = try context.fetch(request)

        // Get the latest date from updatedTime strings
        let latestDate = allQuestions
            .compactMap { $0.updatedTime.repoDate() }  // uses your String extension
            .max()
        
        // Return the latest date as a formatted string (in original repo format)
        return latestDate
    }



    private func getNextQuestionId() -> Int64 {
        let fetchRequest: NSFetchRequest<QuestionsEntity> = QuestionsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
