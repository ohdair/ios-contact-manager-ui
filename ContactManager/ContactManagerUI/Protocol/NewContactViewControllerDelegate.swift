//
//  NewContactViewControllerDelegate.swift
//  ContactManagerUI
//
//  Created by jun on 2023/02/07.
//

import Foundation

protocol NewContactViewControllerDelegate: NSObject {
    func add(contact: Contact)
    func edit(contact: Contact, indexPath: IndexPath)
}
