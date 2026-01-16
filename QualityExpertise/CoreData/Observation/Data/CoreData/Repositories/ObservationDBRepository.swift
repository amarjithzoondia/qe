//
//  ObservationDBRepository.swift
//  ALNASR
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class ObservationDBRepository: ObservationDBRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ observation: NFObservationDraftData) throws {
        let fetchRequest: NSFetchRequest<ObservationEntity> = ObservationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "observationId == %d", observation.id)
        fetchRequest.fetchLimit = 1
        let existing = try context.fetch(fetchRequest).first
        
        let entity = existing ?? ObservationEntity(context: context)
        entity.observationId = observation.id > 0 ? Int64(observation.id) : getNextObservationId()
        entity.observationTitle = observation.observationTitle
        entity.reportedBy = observation.reportedBy
        entity.location = observation.location
        entity.descriptions = observation.description
        entity.responsiblePersonName = observation.responsiblePersonName
        entity.responsiblePersonEmail = observation.responsiblePersonEmail
        entity.createdAt = observation.createdAt
        
        if let projectResponsiblePerson = observation.projectResponsiblePerson {
            do {
                let jsonData = try JSONEncoder().encode(projectResponsiblePerson)
                entity.projectResponsiblePerson = jsonData
            } catch {
                print("Error encoding projectResponsiblePerson: \(error)")
            }
        } else {
            entity.projectResponsiblePerson = nil
        }
        
        if let sendNotification = observation.sendNotification {
            do {
                let jsonData = try JSONEncoder().encode(sendNotification)
                entity.sendNotification = jsonData
            } catch {
                print("Error encoding sendNotification: \(error)")
            }
        }
        else {
            entity.sendNotification = nil
        }
        
        if let group = observation.facilites {
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
        
        
        if let images = observation.imageDescription {
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
                imageEntity.observation = entity
            }
        }
        try context.save()
    }
    
    func fetchAll() throws -> [NFObservationDraftData] {
        let request: NSFetchRequest<ObservationEntity> = ObservationEntity.fetchRequest()
        let userName = UserManager.getLoginedUser()?.name ?? ""
        request.predicate = NSPredicate(format: "reportedBy == %@", userName)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
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
            
            var projectResponsiblePerson: UserData?
            if let data = entity.projectResponsiblePerson {
                do {
                    projectResponsiblePerson = try JSONDecoder().decode(UserData.self, from: data)
                } catch {
                    print("Error decoding projectResponsiblePerwsn: \(error)")
                }
            }
            
            var sendNotification: [UserData]?
            if let data = entity.sendNotification {
                do {
                    sendNotification = try JSONDecoder().decode([UserData].self, from: data)
                } catch {
                    print("Error decoding sendNotificationTo: \(error)")
                }
            }
            
            print(NFObservationDraftData(
                id: Int(entity.observationId),
                observationTitle: entity.observationTitle,
                reportedBy: entity.reportedBy,
                location: entity.location,
                description: entity.descriptions,
                responsiblePersonName: entity.responsiblePersonName,
                responsiblePersonEmail: entity.responsiblePersonEmail,
                projectResponsiblePerson: projectResponsiblePerson,
                sendNotification: sendNotification,
                imageDescription: images ?? [],
                facilites: group,
                createdAt: entity.createdAt
                ))
            
            return NFObservationDraftData(
                id: Int(entity.observationId),
                observationTitle: entity.observationTitle,
                reportedBy: entity.reportedBy,
                location: entity.location,
                description: entity.descriptions,
                responsiblePersonName: entity.responsiblePersonName,
                responsiblePersonEmail: entity.responsiblePersonEmail,
                projectResponsiblePerson: projectResponsiblePerson,
                sendNotification: sendNotification,
                imageDescription: images ?? [],
                facilites: group,
                createdAt: entity.createdAt
                )
        }
    }
    
    func delete(id: Int) throws {
        let request: NSFetchRequest<ObservationEntity> = ObservationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "observationId == %d", id)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    

    private func getNextObservationId() -> Int64 {
        let fetchRequest: NSFetchRequest<ObservationEntity> = ObservationEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "observationId", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.observationId + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
