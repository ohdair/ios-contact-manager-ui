# iOS_contact-manager-ui
---
# 💻 실행 화면
|연락처 추가|연락처 수정|연락처 삭제|연락처 검색|
|:---|:---|:---|:---|
|<img src="https://user-images.githubusercontent.com/79438622/224877270-4d8b0d03-1043-40ad-bd65-7b0fb19d3109.gif">|<img src="https://user-images.githubusercontent.com/79438622/224877421-8ad6e0da-d428-433b-9c4d-04706afaa18d.gif">|<img src="https://user-images.githubusercontent.com/79438622/224877434-4e9f34c1-8438-42de-9bac-49449c3f0e11.gif">|<img src="https://user-images.githubusercontent.com/79438622/224877446-64a0ea4c-ed06-47fb-958e-b180fe003293.gif">|

# 🔖 역할 분배
|Controller|역할|
|:---|:---|
|ContactsViewController|- 우측 상단 ➕ 버튼을 누르면 `ContactHandlerViewController` 화면으로 modal push로 이동<br> - NavigationItem에 searchController 추가 <br> - tableView의 Cell 선택 시, 연락처를 수정할 수 있는 화면으로 이동<br> - Cell을 Swiping하면 삭제의 버튼 활성화 및 삭제 구현|
|ContactHandlerViewController|- 연락처를 Handler 타입을 이용하여 추가 및 수정을 반영 <br>&nbsp; - 추가 : 새로운 연락처가 추가<br>&nbsp; - 수정 : 기존 연락처를 수정|

|enum|역할|
|:---|:---|
|Handler|ContactHandlerViewController에서 `add`와 `edit`의 상태를 받아서 처리할 수 있도록 타입 정의|

|struct|역할|
|:---|:---|
|Contact|연락처에 필요한 정보(`name`, `age`와 `phoneNumber`)를 갖는 구조체|

# Step에 따른 구현
## 🚀 STEP 1 - iOS App Target 추가
- 기존 `ContactManager` 타깃의 주요 파일을 `ContactManagerUI`의 타깃 멤버십 파일로 추가
## 🚀 STEP 2 - 연락처 목록 구현
- tableView 구현
- ContactTableViewCell로 tableView에서 Cell로 사용

<img src="https://user-images.githubusercontent.com/79438622/224887860-7b4a481c-1a21-4354-b422-f51f9f939720.png" width="30%">

## 🚀 STEP 3 - 연락처 추가 기능 구현

|정상 동작|취소 기능|에러 발생시|
|:---|:---|:---|
|<img src="https://user-images.githubusercontent.com/79438622/224889060-74e24ac4-1ad2-4833-9119-a8a0c8ec927d.gif">|<img src="https://user-images.githubusercontent.com/79438622/224889087-cd489904-2d1a-4cb1-9284-f0e1a248ec7f.gif">|<img src="https://user-images.githubusercontent.com/79438622/224889116-cafc5533-4b0f-4756-b9b4-3e69e958b43e.gif">|


### 숫자만 입력 가능하도록 구현
전화번호 입력시 "-"를 커스텀 키보드로 구현하지 않고 아래와 같이 표시합니다.<br>
전화번호 숫자의 개수가<br>
- 9개 이하인 경우 XX-XXX-XXXX<br>
- 10개인 경우 XXX-XXX-XXXX<br>
- 11개 이상인 경우 XXX-XXXX-XXXX<br>

### Formatter 타입으로 PhoneFormatter 생성<br>

```Swift
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
```

### 연락처를 추가
tableView에 반영하기 위해서 `reloadData()`는 전체적으로 다시 불러오는 거라서 비용이 크다는 것을 알고 `insertRows()`를 사용

## 🚀 STEP Bonus
### 아이폰 연락처와 비슷하게 구현
- 검색 기능
- 삭제 기능
- 편집 기능

### 추가된 연락처의 이름에 맞게 Section을 분리
기존 추가 기능을 할 때, insert되는 부분을 이름을 오름차순으로 정렬하여 알파벳에 맞게 Section을 분리하여 Row를 추가

### 검색 기능
isSearching이라는 변수를 두어 Bool값에 따라 tableView의 Cell을 재구성하여서 변경하도록 처리
- section의 수
```Swift
func numberOfSections(in tableView: UITableView) -> Int {
    return isSearching ? 1 : sectionOfContacts().count
}
```
- section마다 row 수
```Swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isSearching {
        return searchedContacts.count
    }
    ...
}
```
- section Header 변경
```Swift
func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if isSearching {
        return "Search Results"
    }
    ...
}
```

### Cell을 Swiping하면 delete 구현
```Swift
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell,
              let selectedContact = selectedCell.getContact(),
              let selectedIndex = self.contacts.firstIndex(of: selectedContact) else {
            return
        }
        self.contacts.remove(at: selectedIndex)
        self.tableView.reloadData()
    }
}
```

### Cell 버튼 클릭시 ContactHandlerViewController의 edit 상태로 화면 전환
```Swift
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
```

---
# 📓 학습내용 요점
(수정 중)

# 🧨 트러블 슈팅
(수정 중)
