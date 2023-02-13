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
        let cancelTitle = "정말로 취소하시겠습니까?"
        showAlert(title: cancelTitle, leftButtonTitle: "아니오", rightButtonTitle: "예")
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
            showAlert(title: error.localizedDescription, leftButtonTitle: "확인")
        }
    }

    private func showAlert(title: String, leftButtonTitle: String, rightButtonTitle: String? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let leftButton = UIAlertAction(title: leftButtonTitle, style: .default)
        alert.addAction(leftButton)
        if rightButtonTitle != nil {
            let rightButton = UIAlertAction(title: rightButtonTitle, style: .destructive) { [self] _ in
                if handle == .add {
                    dismiss(animated: true)
                } else {
                    navigationController?.popViewController(animated: true)
                }
            alert.addAction(rightButton)
        }
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
            let stringOfNumber = newString.filter { $0.isNumber }
            let phoneFormatter = PhoneFormatter()
            textField.text = phoneFormatter.string(for: stringOfNumber)
            return false
        }
        return true
    }
}
