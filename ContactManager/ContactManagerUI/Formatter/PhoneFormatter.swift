//
//  PhoneFormatter.swift
//  ContactManagerUI
//
//  Created by 박재우 on 2023/02/13.
//

import Foundation

class PhoneFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let numbers = obj as? String,
              Int(numbers) != nil else { return nil }
        var formatType: String
        var index = numbers.startIndex
        var formattedNumbers = ""

        switch numbers.count {
        case ...9:
            formatType = "XX-XXX-XXXX"
        case 10:
            formatType = "XXX-XXX-XXXX"
        default:
            formatType = "XXX-XXXX-XXXX"
        }

        for character in formatType where index < numbers.endIndex {
            if character == "X" {
                formattedNumbers.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                formattedNumbers.append(character)
            }
        }

        while index < numbers.endIndex {
            formattedNumbers.append(numbers[index])
            index = numbers.index(after: index)
        }

        return formattedNumbers
    }
}
