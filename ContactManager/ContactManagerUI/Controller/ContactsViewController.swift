//
//  ContactsViewController.swift
//  ContactManagerUI
//
//  Created by jun on 2023/01/31.
//

import UIKit

final class ContactsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var contacts = [
        Contact(name: "Joo", age: 5, phoneNumber: "010-1234-1234"),
        Contact(name: "june", age: 4, phoneNumber: "010-5678-5678")
    ]
    private var searchedContacts = [Contact]()
    var isSearching: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarEmpty = searchController?.searchBar.text?.isEmpty ?? false
        return isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self

        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false

        let nibName = UINib(nibName: ContactTableViewCell.className, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: ContactTableViewCell.className)
    }

    @IBAction func addContact(_ sender: UIBarButtonItem) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ContactHandler") as? ContactHandlerViewController {
            viewController.handle = .add
            viewController.delegate = self
            present(UINavigationController(rootViewController: viewController), animated: true)
        }
    }
}

extension ContactsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : sectionOfContacts().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedContacts.count
        }
        let character = sectionOfContacts()[section]
        let lastIndex: Int = contacts.lastIndex { $0.name.uppercased().hasPrefix(String(character)) } ?? 0
        let firstIndex: Int = contacts.firstIndex { $0.name.uppercased().hasPrefix(String(character)) } ?? 0
        return lastIndex - firstIndex + 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return "Search Results"
        }
        return String(sectionOfContacts()[section])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ContactTableViewCell.className,
            for: indexPath
        ) as? ContactTableViewCell else {
            return UITableViewCell()
        }
        if isSearching {
            cell.configure(contact: searchedContacts[indexPath.row])
        } else {
            let characters = contacts.compactMap { contact in
                contact.name.uppercased().first
            }.removeDuplicates()
            let contact = contacts.filter { conatact in
                conatact.name.uppercased().first! == characters[indexPath.section]
            }
            cell.configure(contact: contact[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.contacts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private func sectionOfContacts() -> [Character] {
        return contacts.compactMap { contact in
            contact.name.uppercased().first
        }.removeDuplicates()
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ContactHandler") as? ContactHandlerViewController {
            viewController.handle = .edit
            viewController.delegate = self
            guard let selectedCell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell,
                  let contact = selectedCell.getContact() else {
                return
            }
            viewController.editContact = (contact, indexPath)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension ContactsViewController: NewContactViewControllerDelegate {
    func edit(contact: Contact, indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell,
              let selectedContact = selectedCell.getContact(),
              let index = contacts.firstIndex(of: selectedContact) else {
            return
        }
        contacts[index] = contact
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func add(contact: Contact) {
        contacts.append(contact)
        contacts.sort { $0.name.uppercased() < $1.name.uppercased() }
        tableView.reloadData()
    }
}

extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if let firstWord = text.first, firstWord.isNumber {
            self.searchedContacts = self.contacts.filter { contact in
                contact.phoneNumber.filter { $0.isNumber }.contains(text)
            }
        } else {
            self.searchedContacts = self.contacts.filter { contact in
                contact.name.lowercased().contains(text.lowercased())
            }
        }
        self.tableView.reloadData()
    }
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var dictionary = [Element: Bool]()
        return filter { dictionary.updateValue(true, forKey: $0) == nil }
    }
}
