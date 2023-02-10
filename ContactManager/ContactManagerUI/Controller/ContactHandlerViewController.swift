//
//  NewContactViewController.swift
//  ContactManagerUI
//
//  Created by jun on 2023/02/07.
//

import UIKit

enum Handler {
    case add
    case edit
}

final class ContactHandlerViewController: UIViewController {
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!

    weak var delegate: NewContactViewControllerDelegate?
    var handle: Handler?
    var editContact: (contact: Contact, indexPath: IndexPath)?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self

        nameTextField.text = editContact?.contact.name
        ageTextField.text = editContact?.contact.age.description
        phoneNumberTextField.text = editContact?.contact.phoneNumber

        switch handle {
        case .add:
            navigationItem.title = "새 연락처"
            navigationItem.leftBarButtonItem = createNavigationItem(title: "Cancel", action: #selector(cancelButtonDidTap))
            navigationItem.rightBarButtonItem = createNavigationItem(title: "Save", action: #selector(saveButtonDidTap))
        case .edit:
            navigationItem.title = "연락처 편집"
            navigationItem.rightBarButtonItem = createNavigationItem(title: "Edit", action: #selector(saveButtonDidTap))
        case .none:
            return
        }
    }

    private func createNavigationItem(title: String, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, style: .plain, target: self, action: action)
    }

    @objc private func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "정말로 취소하시겠습니까?", message: nil, preferredStyle: .alert)
        let noButton = UIAlertAction(title: "아니오", style: .default)
        alert.addAction(noButton)
        let yesButton = UIAlertAction(title: "예", style: .destructive, handler: { [self] _ in
            if handle == .add {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        })
        alert.addAction(yesButton)
        present(alert, animated: true)
    }

    @objc private func saveButtonDidTap(_ sender: UIBarButtonItem) {
        do {
            let name = try getName(input: nameTextField.text ?? "")
            let age = try getAge(input: ageTextField.text ?? "")
            try isValidPhoneNumber(phoneNumberTextField.text ?? "")
            let phoneNumber = phoneNumberTextField.text ?? ""
            let contact = Contact(name: name, age: age, phoneNumber: phoneNumber)
            if handle == .add {
                delegate?.add(contact: contact)
                dismiss(animated: true)
            } else if handle == .edit, let indexPath = editContact?.indexPath {
                delegate?.edit(contact: contact, indexPath: indexPath)
                navigationController?.popViewController(animated: true)
            }
        } catch {
            showErrorAlert(error.localizedDescription)
        }
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let checkButton = UIAlertAction(title: "확인", style: .default)
        alert.addAction(checkButton)
        present(alert, animated: true)
    }
}

extension ContactHandlerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField, let text = textField.text {
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = format(phone: newString)
            return false
        }
        return true
    }

    private func format(phone: String) -> String {
        let numbers = phone.filter({ $0.isNumber })
        var index = numbers.startIndex
        var formatType = ""
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
