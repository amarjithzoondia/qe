//
//  InspectionDBRepository.swift
//  ALNASR
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class InspectionDBRepository: InspectionDBRepositoryProtocol {

    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ inspection: Inspections) throws {
        let fetchRequest: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", inspection.id)
        fetchRequest.fetchLimit = 1
        
        let existing = try context.fetch(fetchRequest).first
        
        let entity = existing ?? InspectionEntity(context: context)
        entity.id = inspection.id > 0 ? Int64(inspection.id) : getNextInspectionId()
        entity.modelNumber = inspection.modelNumber
        entity.inspectedBy = inspection.inspectedBy
        entity.rentalOrSubContractor = inspection.subContractor
        entity.equipmentSource = Int64(inspection.equipmentSource?.rawValue ?? -1)
        entity.inspectionName = inspection.auditItem.auditItemTitle
        entity.inspectionId = Int64(inspection.auditItem.auditItemId)
        entity.location = inspection.location
        entity.inspectionDate = inspection.inspectionDate
        entity.desc = inspection.description
        entity.notes = inspection.notes
        entity.createdAt = inspection.createdAt
        entity.questionsUpdatedTime = inspection.lastQuestionsUpdatedAt
        entity.formUpdatedTime = inspection.formUpdatedTime
        
        // Save group (optional)
        if let group = inspection.facilities {
            let groupEntity = GroupEntity(context: context)
            groupEntity.id = group.groupId
            groupEntity.name = group.groupName
            groupEntity.code = group.groupCode
            groupEntity.image = group.groupImage
            entity.facilities = groupEntity
        } else {
            entity.facilities = nil
        }
        
        // Save images
        if let images = inspection.images {
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
                imageEntity.inspection = entity
                
            }
        }
        
        if let staticEquipment = inspection.staticEquipment {
            do {
                let jsonData = try JSONEncoder().encode(staticEquipment)
                entity.staticEquipmentData = jsonData
            } catch {
                print("Error encoding static equipment: \(error)")
            }
        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [Inspections] {
        let request: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        let userName = UserManager.getLoginedUser()?.name ?? ""
        request.predicate = NSPredicate(format: "inspectedBy == %@", userName)
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
            
            // 🔹 Decode staticEquipment JSON
            var staticEquipment: [EquipmentStatic]? = nil
            if let data = entity.staticEquipmentData {
                do {
                    staticEquipment = try JSONDecoder().decode([EquipmentStatic].self, from: data)
                } catch {
                    print("Error decoding staticEquipment: \(error)")
                }
            }
            
            return Inspections(
                id: Int(entity.id),
                auditItem: AuditsInspectionsList(
                    auditItemId: Int(entity.inspectionId),
                    auditItemTitle: entity.inspectionName
                ),
                modelNumber: entity.modelNumber,
                inspectedBy: entity.inspectedBy,
                location: entity.location ?? "",
                inspectionDate: entity.inspectionDate,
                description: entity.desc ?? "",
                equipmentSource: EquipmentSource(rawValue: Int(entity.equipmentSource)) ?? .alnasar,
                subContractor: entity.rentalOrSubContractor,
                notes: entity.notes ?? "",
                createdAt: entity.createdAt,
                facilities: group,
                images: images,
                staticEquipment: staticEquipment,
                lastQuestionsUpdatedAt: entity.questionsUpdatedTime,
                formUpdatedTime: entity.formUpdatedTime
            )
        }
    }


    
    func delete(id: Int) throws {
        let inspectionRequest: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        inspectionRequest.predicate = NSPredicate(format: "id == %d", id)

        if let inspection = try context.fetch(inspectionRequest).first {
            context.delete(inspection)
        }
        try context.save()
    }

    
    func getAllAnswers(inspectionId: Int) throws -> [EquipmentStatic] {
        let fetchRequest: NSFetchRequest<InspectionAnswersEntity> = InspectionAnswersEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "inspectionId == %d", inspectionId)
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { result in
                EquipmentStatic(
                    id: Int(result.questionId),
                    title: "",
                    selectedValue: StaticEquipmentOptions(rawValue: Int(result.answerType))
                )
            }
        } catch {
            print("❌ Failed to fetch answers for inspectionId \(inspectionId): \(error)")
            return []
        }
    }
    
    func saveContents(_ contents: InspectionContentsResponse) throws {
        for content in contents.contentsList {
            let fetchRequest: NSFetchRequest<InspectionContentsEntity> = InspectionContentsEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "auditItemId == %d", content.type ?? -1)
            fetchRequest.fetchLimit = 1
            
            let existing = try context.fetch(fetchRequest).first
            let entity = existing ?? InspectionContentsEntity(context: context)
            let encodedContent = try JSONEncoder().encode(content.contents)
            
            entity.auditItemId = Int64(content.type ?? -1)
            entity.updatedTime = content.updatedTime ?? Date().formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
            entity.contents = encodedContent
            
        }
        try context.save()
    }
    
    func getContents(_ inspectionTypeId: Int) throws -> [EquipmentStatic] {
        let fetchRequest: NSFetchRequest<InspectionContentsEntity> = InspectionContentsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "auditItemId == %d", inspectionTypeId)
        
        let results = try context.fetch(fetchRequest)
        
        let decodedList: [EquipmentStatic] = try results.flatMap { entity in
            try JSONDecoder().decode([EquipmentStatic].self, from: entity.contents)
        }
        return decodedList
    }
    
    func getLatestUpdatedTime() throws -> Date? {
        let request: NSFetchRequest<InspectionContentsEntity> = InspectionContentsEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.map { $0.updatedTime }.max()?
                .repoDate(inputFormat: Constants.DateFormat.REPO_DATE_TIME, local: LocalizationService.shared.language.local)
        } catch {
            return nil
        }
    }
    
    func getLatestUpdatedTime(_ inspectionTypeId: Int) throws -> String? {
        let fetchRequest: NSFetchRequest<InspectionContentsEntity> = InspectionContentsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "auditItemId == %d", inspectionTypeId)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.updatedTime
        } catch {
            return nil
        }
    }
    
    func getLatestFormUpdatedTime(_ inspectionTypeId: Int) throws -> String? {
        let fetchRequest: NSFetchRequest<AuditItemEntity> = AuditItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "auditItemId == %d", inspectionTypeId)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.updatedTime
        } catch {
            return nil
        }
    }
    
    
    func saveAuditItems(_ auditItems: AuditsInspectionsListResponse) throws {
        // 1. Delete all existing items
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AuditItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // 2. Insert fresh items
        for content in auditItems.contents {
            let entity = AuditItemEntity(context: context)
            entity.id = getNextInspectionId()
            entity.auditItemId = Int64(content.auditItemId)
            entity.auditItemTitle = content.auditItemTitle
            entity.image = content.image ?? ""
            entity.updatedTime = content.formUpdatedTime ?? ""
        }
        
        // 3. Save once
        try context.save()
    }

    
    func getAuditItems() throws -> [AuditsInspectionsList] {
        let fetchRequest: NSFetchRequest<AuditItemEntity> = AuditItemEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                key: "auditItemTitle",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )
        ]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map {
                AuditsInspectionsList(
                    auditItemId: Int($0.auditItemId),
                    auditItemTitle: $0.auditItemTitle,
                    image: $0.image
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    
    func getUpdatedAuditItemsDate() throws -> String? {
        let fetchRequest: NSFetchRequest<AuditItemEntity> = AuditItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedTime", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.updatedTime
        } else {
            return nil
        }
    }
    
    private func getNextInspectionId() -> Int64 {
        let fetchRequest: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
}
