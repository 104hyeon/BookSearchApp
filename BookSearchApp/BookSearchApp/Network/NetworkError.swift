import Foundation

enum NetworkError: Error {
    case invalidUrl
    case dataFetchFail
    case decodingFail
    case requestFail
    case responseFail
    case encodingFail
    case taskFail
    
    var errorTitle: String {
        switch self {
        case .invalidUrl:
            return "유효하지 않은 URL입니다."
        case .dataFetchFail:
            return "데이터 가져오기를 실패했습니다."
        case .decodingFail:
            return "디코딩에 실패했습니다."
        case .requestFail:
            return "요청에 실패했습니다."
        case .responseFail:
            return "응답에 실패했습니다."
        case .encodingFail:
            return "인코딩에 실패했습니다."
        case .taskFail:
            return "작업에 실패했습니다."
        }
    }
}
