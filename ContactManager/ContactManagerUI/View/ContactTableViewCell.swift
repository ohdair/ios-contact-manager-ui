//
//  ContactTableViewCell.swift
//  ContactManagerUI
//
//  Created by 박재우 on 2023/01/31.
//

import UIKit

final class ContactTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!

    static var className: String {
        return String(describing: self)
    }
}

extension ContactTableViewCell {
    func configure(contact: Contact) {
        nameLabel.text = contact.name
        ageLabel.text = contact.age.description
        phoneNumberLabel.text = contact.phoneNumber
    }

    func getContact() -> Contact? {
        guard let name = nameLabel.text,
              let age = Int(ageLabel.text ?? ""),
              let phoneNumber = phoneNumberLabel.text else {
            return nil
        }
        return Contact(name: name, age: UInt(age), phoneNumber: phoneNumber)
    }
}
