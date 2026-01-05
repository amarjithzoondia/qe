//
//  ToolBoxTalkDBRepository.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class ToolBoxTalkDBRepository: ToolBoxTalkDBRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ toolBoxTalks: [ToolBoxTalk]) throws {
        for toolBoxTalk in toolBoxTalks {
            let fetchRequest: NSFetchRequest<ToolBoxEntity> = ToolBoxEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", toolBoxTalk.id)
            fetchRequest.fetchLimit = 1
            let existing = try context.fetch(fetchRequest).first
            
            let entity = existing ?? ToolBoxEntity(context: context)
            entity.id = toolBoxTalk.id > 0 ? Int64(toolBoxTalk.id) : getNextToolBoxId()
            entity.date = toolBoxTalk.date
            entity.startTime = toolBoxTalk.startTime
            entity.endTime = toolBoxTalk.endTime
            entity.topic = toolBoxTalk.topic
            entity.createdAt = toolBoxTalk.createdAt
            entity.reportedBy = toolBoxTalk.reportedBy
            
            let attendedEmployees = toolBoxTalk.attendees
            do {
                let jsonData = try JSONEncoder().encode(attendedEmployees)
                entity.attendantedEmployees = jsonData
            } catch {
                print("Error encoding injuredEmployees: \(error)")
            }
            
            
            let discussionPoints = toolBoxTalk.discussionPoints
            do {
                let jsonData = try JSONEncoder().encode(discussionPoints)
                entity.discussionPoints = jsonData
            } catch {
                print("Error encoding incidentType: \(error)")
            }

            if let group = toolBoxTalk.facilities {
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
            
            
            if let images = toolBoxTalk.images {
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
                    imageEntity.toolBox = entity
                }
            }

        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [ToolBoxTalk] {
        let request: NSFetchRequest<ToolBoxEntity> = ToolBoxEntity.fetchRequest()
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
            
            var attendedEmployees: [Employee] = []
            let employeeData = entity.attendantedEmployees
                do {
                    attendedEmployees = try JSONDecoder().decode([Employee].self, from: employeeData)
                } catch {
                    print("Error decoding staticEquipment: \(error)")
                }
            
            
            var discussionPoints: [DiscussionPoint] = []
            let discussionData = entity.discussionPoints
                do {
                    discussionPoints = try JSONDecoder().decode([DiscussionPoint].self, from: discussionData)
                } catch {
                    print("Error decoding staticEquipment: \(error)")
                }
            
            
            return ToolBoxTalk(
                id: Int(entity.id),
                date: entity.date,
                startTime: entity.startTime,
                endTime: entity.endTime,
                topic: entity.topic,
                discussionPoints: discussionPoints,
                attendees: attendedEmployees,
                createdAt: entity.createdAt,
                facilities: group,
                images: images,
                reportedBy: entity.reportedBy)
        }
    }
    
    func delete(id: Int) throws {
        let request: NSFetchRequest<ToolBoxEntity> = ToolBoxEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    

    private func getNextToolBoxId() -> Int64 {
        let fetchRequest: NSFetchRequest<ToolBoxEntity> = ToolBoxEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
