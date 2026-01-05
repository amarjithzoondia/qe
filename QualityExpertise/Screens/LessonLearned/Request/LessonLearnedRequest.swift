//
//  LessonLearnedRequest.swift
//  QualityExpertise
//
//  Created by Amarjith B on 21/07/25.
//

enum LessonLearnedRequest {
    case lessonLearnedList(params: LessonLearnedListParams)
    case lessonLearnedDeatil(params: LessonLearnedDetailParams)
    case addlessonLearned(params: LessonLearnedParams)
    case generatePdf(params: LessonLearnedPdfParams)
    case generateExcel(params: LessonLearnedExcelParams)
}

extension LessonLearnedRequest: RequestProtocol {
    var repository: Repository? {
        nil
    }
    
    var folderPath: RequestFolder? {
        .lessonLearned
    }
    
    var endpoint: String {
        switch self {
        case .lessonLearnedList:
            return "list"
        case.lessonLearnedDeatil:
            return "detail"
        case .addlessonLearned:
            return "create"
        case .generatePdf:
            return "generate-pdf"
        case .generateExcel:
            return "generate-excel"
        }
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var params: (any Encodable)? {
        switch self {
        case .lessonLearnedList(let params):
            return params
        case .lessonLearnedDeatil(params: let params):
            return params
        case .addlessonLearned(params: let params):
            return params
        case .generatePdf(params: let params):
            return params
        case .generateExcel(params: let params):
            return params
        }
    }
    
    
}
