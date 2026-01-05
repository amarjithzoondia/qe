//
//  LessonLearnedDBRepository.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class LessonLearnedDBRepository: LessonLearnedDBRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ lessons: [LessonLearned]) throws {
        for lesson in lessons {
            let fetchRequest: NSFetchRequest<LessonEntity> = LessonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", lesson.id)
            fetchRequest.fetchLimit = 1
            let existing = try context.fetch(fetchRequest).first
            
            let entity = existing ?? LessonEntity(context: context)
            entity.id = lesson.id > 0 ? Int64(lesson.id) : getNextLessonId()
            entity.title = lesson.title
            entity.desc = lesson.description
            entity.createdAt = lesson.createdAt
            entity.reportedBy = lesson.reportedBy
            
            // Save group (optional)
            if let group = lesson.facilities {
                let groupEntity = GroupEntity(context: context)
                groupEntity.id = group.groupId
                groupEntity.name = group.groupName
                groupEntity.code = group.groupCode
                groupEntity.image = group.groupImage
                entity.facilities = groupEntity
            }
            else {
                entity.facilities = nil
            }
            
            // Save images
            if let images = lesson.images {
                // 1. Remove existing images
                if let existingImages = entity.images as? Set<ImageEntity> {
                    for image in existingImages {
                        context.delete(image)
                    }
                }
                
                // 2. Add new images
                for img in images {
                    let imageEntity = ImageEntity(context: context)
                    imageEntity.image = img.image
                    imageEntity.desc = img.description
                    imageEntity.lesson = entity
                }
            }

        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [LessonLearned] {
        let request: NSFetchRequest<LessonEntity> = LessonEntity.fetchRequest()
        let userName = UserManager.getLoginedUser()?.name ?? ""
        request.predicate = NSPredicate(format: "reportedBy == %@", userName)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let results = try context.fetch(request)
        return results.map { entity in
            var group: GroupData? {
                if let group = entity.facilities {
                    return GroupData(
                        groupId: group.id,
                        groupCode: group.code,
                        groupName: group.name,
                        groupImage: group.image
                    )
                }
                
                return nil
            }
            
            let images = (entity.images as? Set<ImageEntity>)?.map {
                ImageData(
                    id: nil,
                    image: $0.image,
                    imageCount: nil,
                    description: $0.desc
                )
            }
            
            return LessonLearned(
                id: Int(entity.id),
                title: entity.title,
                description: entity.desc,
                createdAt: entity.createdAt,
                facilities: group,
                images: images,
                reportedBy: entity.reportedBy
                )
        }
    }
    
    func delete(id: Int) throws {
        let request: NSFetchRequest<LessonEntity> = LessonEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    
    
    private func getNextLessonId() -> Int64 {
        let fetchRequest: NSFetchRequest<LessonEntity> = LessonEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
