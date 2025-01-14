//
//  Error.swift
//  ContactManager
//
//  Created by jun on 2023/01/31.
//

import Foundation

enum ContactManagerError {
    case invalidCommand
    case invalidInput
    case emptyInput
    case invalidName
    case invalidAge
    case invalidPhoneNumber
    case existContact
    case excludeContact(name: String)
}

extension ContactManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCommand:
            return "선택이 잘못되었습니다 확인 후 다시 입력해주세요."
        case .invalidInput:
            return "입력이 잘못되었습니다"
        case .emptyInput:
            return "아무것도 입력되지 않았습니다"
        case .invalidName:
            return "입력한 이름정보가 잘못되었습니다"
        case .invalidAge:
            return "입력한 나이정보가 잘못되었습니다"
        case .invalidPhoneNumber:
            return "입력한 연락처정보가 잘못되었습니다"
        case .existContact:
            return "입력한 연락처는 이미 존재합니다"
        case .excludeContact(let name):
            return "연락처에 \(name) 이(가) 없습니다."
        }
    }
}
