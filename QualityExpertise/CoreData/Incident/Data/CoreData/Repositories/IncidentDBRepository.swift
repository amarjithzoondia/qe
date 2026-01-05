//
//  IncidentDBRepository.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class IncidentDBRepository: IncidentDBRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ incidents: [Incident]) throws {
        for incident in incidents {
            let fetchRequest: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", incident.id)
            fetchRequest.fetchLimit = 1
            let existing = try context.fetch(fetchRequest).first
            
            let entity = existing ?? IncidentEntity(context: context)
            entity.id = incident.id > 0 ? Int64(incident.id) : getNextIncidentId()
            entity.incidentDate = incident.incidentDate
            entity.incidentTime = incident.incidentTime
            entity.incidentLocation = incident.incidentLocation
            entity.descriptions = incident.description
            entity.corrections = incident.corrections
            entity.createdAt = incident.createdAt
            entity.reportedBy = incident.reportedBy
            
            if let injuredEmployees = incident.injuredEmployees {
                do {
                    let jsonData = try JSONEncoder().encode(injuredEmployees)
                    entity.injuredEmployees = jsonData
                } catch {
                    print("Error encoding injuredEmployees: \(error)")
                }
            }
            
            let incidentType = incident.incidentType
            do {
                let jsonData = try JSONEncoder().encode(incidentType)
                entity.incidentType = jsonData
            } catch {
                print("Error encoding incidentType: \(error)")
            }

            if let group = incident.facilities {
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
            
            
            if let images = incident.images {
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
                    imageEntity.incident = entity
                }
            }

        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [Incident] {
        let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
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
            
            var injuredEmployees: [Employee] = []
            if let data = entity.injuredEmployees {
                do {
                    injuredEmployees = try JSONDecoder().decode([Employee].self, from: data)
                } catch {
                    print("Error decoding staticEquipment: \(error)")
                }
            }
            
            var incidentTypes: [Int] = []
            if let data = entity.incidentType {
                do {
                    incidentTypes = try JSONDecoder().decode([Int].self, from: data)
                } catch {
                    print("Error decoding staticEquipment: \(error)")
                }
            }
            
            
            
            return Incident(
                id: Int(entity.id),
                incidentDate: entity.incidentDate,
                incidentTime: entity.incidentTime,
                incidentLocation: entity.incidentLocation,
                incidentType: incidentTypes,
                injuredEmployees: injuredEmployees,
                description: entity.descriptions,
                corrections: entity.corrections,
                createdAt: entity.createdAt,
                facilities: group,
                images: images,
                reportedBy: entity.reportedBy)
        }
    }
    
    func delete(id: Int) throws {
        let request: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    

    private func getNextIncidentId() -> Int64 {
        let fetchRequest: NSFetchRequest<IncidentEntity> = IncidentEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
