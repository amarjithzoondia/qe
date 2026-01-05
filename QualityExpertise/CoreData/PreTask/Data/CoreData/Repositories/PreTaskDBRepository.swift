//
//  ToolBoxTalkDBRepository.swift
//  QualityExpertise
//
//  Created by Vivek M on 24/07/25.
//

import CoreData

final class PreTaskDBRepository: PreTaskDBRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func save(_ preTasks: [PreTask]) throws {
        for preTask in preTasks {
            let fetchRequest: NSFetchRequest<PreTaskEntity> = PreTaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", preTask.id)
            fetchRequest.fetchLimit = 1
            let existing = try context.fetch(fetchRequest).first
            
            let entity = existing ?? PreTaskEntity(context: context)
            entity.id = preTask.id > 0 ? Int64(preTask.id) : getNextPreTaskEntityId()
            entity.date = preTask.date
            entity.startTime = preTask.startTime ?? ""
            entity.endTime = preTask.endTime ?? ""
            entity.createdAt = preTask.createdAt
            entity.reportedBy = preTask.reportedBy
            entity.taskTitle = preTask.taskTitle
            entity.msraReference = preTask.msraReference
            entity.permitReference = preTask.permitReference
            entity.notes = preTask.notes
            
            let attendedEmployees = preTask.attendees
            do {
                let jsonData = try JSONEncoder().encode(attendedEmployees)
                entity.attendees = jsonData
            } catch {
                print("Error encoding injuredEmployees: \(error)")
            }
            
            
            let contents = preTask.contents
            do {
                let jsonData = try JSONEncoder().encode(contents)
                entity.contents = jsonData
            } catch {
                print("Error encoding incidentType: \(error)")
            }
            
            let questions = preTask.questions
            do {
                let jsonData = try JSONEncoder().encode(questions)
                entity.questions = jsonData
            } catch {
                print("Error encoding incidentType: \(error)")
            }
            
            if let userData = preTask.sendNotificationTo {
                do {
                    let jsonData = try JSONEncoder().encode(userData)
                    entity.sendNotificationTo = jsonData
                } catch {
                    print("Error encoding incidentType: \(error)")
                }
            }
            
            let otherTopic = preTask.otherTopic
            do {
                let jsonData = try JSONEncoder().encode(otherTopic)
                entity.otherTopic = jsonData
            } catch {
                print("Error encoding incidentType: \(error)")
            }
            

            if let group = preTask.facilities {
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
            
            
            if let images = preTask.images {
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
                    imageEntity.preTask = entity
                }
            }

        }
        
        try context.save()
    }
    
    func fetchAll() throws -> [PreTask] {
        let request: NSFetchRequest<PreTaskEntity> = PreTaskEntity.fetchRequest()
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
            let employeeData = entity.attendees
                do {
                    attendedEmployees = try JSONDecoder().decode([Employee].self, from: employeeData)
                } catch {
                    print("Error decoding attendedEmployees: \(error)")
                }
            
            
            var contents: [PreTaskAPI.Content] = []
            let contentsData = entity.contents
                do {
                    contents = try JSONDecoder().decode([PreTaskAPI.Content].self, from: contentsData)
                } catch {
                    print("Error decoding contents: \(error)")
                }
            
            var questions: [PreTaskAPI.Question] = []
            let questionsData = entity.questions
                do {
                    questions = try JSONDecoder().decode([PreTaskAPI.Question].self, from: questionsData)
                } catch {
                    print("Error decoding questions: \(error)")
                }
            
            var otherTopic: [PreTaskQuestion] = []
            let otherTopicsData = entity.otherTopic
            print(otherTopicsData)
            print("--------")
                do {
                    otherTopic = try JSONDecoder().decode([PreTaskQuestion].self, from: otherTopicsData)
                } catch {
                    print("Error decoding otherTopic: \(error)")
                }
            
            var sendNotificationTo: [UserData] = []
            if let data = entity.sendNotificationTo {
                do {
                    sendNotificationTo = try JSONDecoder().decode([UserData].self, from: data)
                } catch {
                    print("Error decoding sendNotificationTo: \(error)")
                }
            }
            
            
            return PreTask(
                id: Int(entity.id),
                date: entity.date,
                startTime: entity.startTime,
                endTime: entity.endTime,
                taskTitle: entity.taskTitle,
                msraReference: entity.msraReference,
                permitReference: entity.permitReference,
                contents: contents,
                questions: questions,
                otherTopic:otherTopic,
                attendees: attendedEmployees,
                images: images,
                facilities: group,
                notes: entity.notes,
                createdAt: entity.createdAt,
                reportedBy: entity.reportedBy,
                sendNotificationTo: sendNotificationTo
            )
        }
    }
    
    func delete(id: Int) throws {
        let request: NSFetchRequest<PreTaskEntity> = PreTaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
    

    private func getNextPreTaskEntityId() -> Int64 {
        let fetchRequest: NSFetchRequest<PreTaskEntity> = PreTaskEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let maxEntity = result.first {
            return maxEntity.id + 1
        } else {
            return 1 // Start from 1 if no entries exist
        }
    }
    
    func savePreTaskContents(
        _ contents: [PreTaskAPI.Content],
        deletedContentIds: [Int],
        isContentsEmpty: Bool
    ) throws {
        let fetchRequest: NSFetchRequest<PreTaskContentsEntity> = PreTaskContentsEntity.fetchRequest()
        let existingEntities = try context.fetch(fetchRequest)
        
        // If all contents are deleted or API returned empty
        if isContentsEmpty {
            for entity in existingEntities {
                context.delete(entity)
            }
            print("🗑️ Cleared all PreTaskContentsEntity records")
            try context.save()
            return
        }

        // Convert to dictionary for quick lookups
        let existingById = Dictionary(uniqueKeysWithValues: existingEntities.map { (Int($0.id), $0) })
        let apiIds = Set(contents.map { $0.id })
        let deletedIdsFromAPI = Set(deletedContentIds)
        
        // 1️⃣ Add or update
        for content in contents {
            if let entity = existingById[content.id] {
                // Update existing
                entity.title = content.title
                entity.updatedTime = content.updatedTime ?? ""
                entity.order = Int64(content.order ?? -1)
            } else {
                // Insert new
                let newEntity = PreTaskContentsEntity(context: context)
                newEntity.id = Int64(content.id)
                newEntity.title = content.title
                newEntity.updatedTime = content.updatedTime ?? ""
                newEntity.order = Int64(content.order ?? -1)
            }
        }
        
        // 2️⃣ Delete specific IDs from API (if any)
        for id in deletedIdsFromAPI {
            if let entity = existingById[id] {
                context.delete(entity)
                print("🗑️ Deleted local content ID (explicit API deletion): \(id)")
            }
        }

        // 3️⃣ Delete any local contents missing in API response (i.e., removed server-side but not flagged)
        let missingIds = Set(existingById.keys).subtracting(apiIds).subtracting(deletedIdsFromAPI)
        for id in missingIds {
            if let entity = existingById[id] {
                context.delete(entity)
                print("🗑️ Deleted local content ID (missing in API): \(id)")
            }
        }

        try context.save()
        print("✅ Pre-task contents synced (added/updated/deleted/missing handled).")
    }


    
    func savePreTaskQuestions(
        _ questions: [PreTaskAPI.Question],
        deletedQuestionsIds: [Int],
        isQuestionsEmpty: Bool
    ) throws {
        let fetchRequest: NSFetchRequest<PreTaskQuestionsEntity> = PreTaskQuestionsEntity.fetchRequest()
        let existingEntities = try context.fetch(fetchRequest)
        
        // If all questions are deleted or API returned empty
        if isQuestionsEmpty {
            for entity in existingEntities {
                context.delete(entity)
            }
            print("🗑️ Cleared all PreTaskQuestionsEntity records")
            try context.save()
            return
        }

        // Map existing and API data
        let existingById = Dictionary(uniqueKeysWithValues: existingEntities.map { (Int($0.id), $0) })
        let apiIds = Set(questions.map { $0.id })
        let deletedIdsFromAPI = Set(deletedQuestionsIds)

        // 1️⃣ Add or update
        for question in questions {
            if let entity = existingById[question.id] {
                // Update existing
                entity.contentId = Int64(question.contentId)
                entity.title = question.title
                entity.imageUrl = question.imageUrl
                entity.updatedTime = question.updatedTime ?? ""
            } else {
                // Insert new
                let newEntity = PreTaskQuestionsEntity(context: context)
                newEntity.id = Int64(question.id)
                newEntity.contentId = Int64(question.contentId)
                newEntity.title = question.title
                newEntity.imageUrl = question.imageUrl
                newEntity.updatedTime = question.updatedTime ?? ""
            }
        }

        // 2️⃣ Delete specific IDs from API (if any)
        for id in deletedIdsFromAPI {
            if let entity = existingById[id] {
                context.delete(entity)
                print("🗑️ Deleted local question ID (explicit API deletion): \(id)")
            }
        }

        // 3️⃣ Delete any local questions missing in API response (i.e., removed server-side but not flagged)
        let missingIds = Set(existingById.keys).subtracting(apiIds).subtracting(deletedIdsFromAPI)
        for id in missingIds {
            if let entity = existingById[id] {
                context.delete(entity)
                print("🗑️ Deleted local question ID (missing in API): \(id)")
            }
        }

        try context.save()
        print("✅ Pre-task questions synced (added/updated/deleted/missing handled).")
    }


    
    func getLatestContentsUpdatedTime() throws -> String? {
        let fetchRequest: NSFetchRequest<PreTaskContentsEntity> = PreTaskContentsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedTime", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        let latestEntity = try context.fetch(fetchRequest).first
        return latestEntity?.updatedTime
    }

    func getLatestQuestionsUpdatedTime() throws -> String? {
        let fetchRequest: NSFetchRequest<PreTaskQuestionsEntity> = PreTaskQuestionsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedTime", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        let latestEntity = try context.fetch(fetchRequest).first
        return latestEntity?.updatedTime
    }
    
    func getPreTaskContents() throws -> [PreTaskAPI.Content] {
        let contentRequest: NSFetchRequest<PreTaskContentsEntity> = PreTaskContentsEntity.fetchRequest()
        
        // Numeric sort: 0 → 1 → 10 → 20 → 999 ...
        contentRequest.sortDescriptors = [
            NSSortDescriptor(key: "order", ascending: true)
        ]
        
        let contents = try context.fetch(contentRequest)
        
        return contents.map { content in
            PreTaskAPI.Content(
                id: Int(content.id),
                title: content.title,
                updatedTime: content.updatedTime,
                order: Int(content.order)
            )
        }
    }

    func getPreTaskQuestions() throws -> [PreTaskAPI.Question] {
        let questionRequest: NSFetchRequest<PreTaskQuestionsEntity> = PreTaskQuestionsEntity.fetchRequest()
        let questions = try context.fetch(questionRequest)
        
        return questions.map { question in
            PreTaskAPI.Question(
                id: Int(question.id),
                contentId: Int(question.contentId),
                title: question.title,
                imageUrl: question.imageUrl ?? "",
                updatedTime: question.updatedTime
            )
        }
    }



}
