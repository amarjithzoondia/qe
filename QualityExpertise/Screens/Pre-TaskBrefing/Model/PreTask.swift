//
//  PreTask.swift
//  ALNASR
//
//  Created by Amarjith B on 24/10/25.
//

import Foundation

// MARK: - Main PreTask Model

struct PreTask: Identifiable, Codable {
    var id: Int
    var date: String
    var startTime: String?
    var endTime: String?
    var taskTitle: String

    var msraReference: String?
    var permitReference: String?

    var contents: [PreTaskAPI.Content]?
    var questions: [PreTaskAPI.Question]?
    var otherTopic: [PreTaskQuestion]?

    var attendees: [Employee]?
    var images: [ImageData]?
    var facilities: GroupData?
    var notes: String?

    var createdAt: String
    var reportedBy: String
    var sendNotificationTo: [UserData]?
}

// MARK: - Question Model

struct PreTaskQuestion: Identifiable, Codable {
    var id: Int
    var title: String
    var selectedAnswer: PreTaskAnswer?
}

// MARK: - Answer Enum

enum PreTaskAnswer: Int, Codable, CaseIterable {
    case null = 0
    case yes = 1
    case no = 2
    case notApplicable = 3
    
    var title: String {
        switch self {
        case .yes:
            return "yes".localizedString()
        case .no:
            return "no".localizedString()
        case .notApplicable:
            return "not_applicable".localizedString()
        case .null:
            return ""
        }
    }
}

struct PreTaskTopic: Codable, Identifiable {
    var id: Int
    var title: String
    var questions: [PreTaskAPI.Question]
}

// MARK: - API Namespace for Topics & Questions

enum PreTaskAPI {

    struct TopicsResponse: Codable {
        var contents: [Content]
        var questions: [Question]
        let deletedContentsId : [Int]
        let deletedQuestionsId: [Int]
        let isContentEmpty: Bool
        let isQuestionEmpty: Bool
    }

    struct Content: Codable, Identifiable {
        var id: Int
        var title: String
        var updatedTime: String?
        var order: Int?
    }

    struct Question: Codable, Identifiable {
        var id: Int
        var contentId: Int
        var title: String
        var imageUrl: String?
        var selectedAnswer: PreTaskAnswer?
        var updatedTime: String?
    }
}

// MARK: - Dummy / Mock Data Generator

extension PreTask {

    static func mock(count: Int = 5) -> [PreTask] {

        func mockQuestion(id: Int, title: String, answer: PreTaskAnswer) -> PreTaskQuestion {
            PreTaskQuestion(
                id: id,
                title: title,
                selectedAnswer: answer
            )
        }

        let sampleQuestions = [
            mockQuestion(id: 1, title: "Helmet worn properly", answer: .yes),
            mockQuestion(id: 2, title: "Safety boots in use", answer: .no),
            mockQuestion(id: 3, title: "Gloves available", answer: .notApplicable)
        ]

        let sampleContents = [
            PreTaskAPI.Content(id: 1, title: "PPE Compliance", updatedTime: "2025-10-27 09:00:00", order: 1),
            PreTaskAPI.Content(id: 2, title: "Tool Inspection", updatedTime: "2025-10-27 09:05:00", order: 2),
            PreTaskAPI.Content(id: 3, title: "Site Preparation", updatedTime: "2025-10-27 09:10:00", order: 3)
        ]

        let sampleAPIQuestions = [
            PreTaskAPI.Question(id: 101, contentId: 1, title: "Helmet check", imageUrl: "helmet.png", updatedTime: "2025-10-27 09:15:00"),
            PreTaskAPI.Question(id: 102, contentId: 2, title: "Boot inspection", imageUrl: "boots.png", updatedTime: "2025-10-27 09:20:00")
        ]

        return (1...count).map { i in
            PreTask(
                id: i,
                date: "27-10-2025",
                startTime: "2025-10-27 08:00:00",
                endTime: "2025-10-27 10:00:00",
                taskTitle: "Task #\(i) - Equipment Maintenance",
                msraReference: "MSRA-\(1000 + i)",
                permitReference: "PR-\(2000 + i)",
                contents: sampleContents.shuffled(),
                questions: sampleAPIQuestions.shuffled(),
                otherTopic: sampleQuestions.shuffled(),
                attendees: [
                    Employee.dummy(),
                    Employee(
                        id: i,
                        employeeCode: "E\(1000 + i)",
                        employeeName: "Employee \(i)",
                        companyName: "Company \(i)",
                        profession: "Technician"
                    )
                ],
                images: [ImageData.dummy(imageCount: 1)],
                facilities: GroupData.dummy(),
                notes: "Notes for task \(i)",
                createdAt: "2025-10-27 09:00:00",
                reportedBy: "User \(i)",
                sendNotificationTo: [UserData.dummy()]
            )
        }
    }
}

extension PreTaskAPI.TopicsResponse {
    /// Converts API TopicsResponse to [PreTaskTopic]
    func toPreTaskTopics() -> [PreTaskTopic] {
        contents.map { content in
            let relatedQuestions = questions.filter { $0.contentId == content.id }
            return PreTaskTopic(
                id: content.id,
                title: content.title,
                questions: relatedQuestions
            )
        }
    }
}
