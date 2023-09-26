import Foundation

func splitName(_ fullName: String) -> (firstName: String, lastName: String?) {
  let nameComponents = fullName.split(separator: " ")

  switch nameComponents.count {
  case 0:
    return ("", nil)
  case 1:
    return (String(nameComponents[0]), nil)
  case 2:
    return (String(nameComponents[0]), String(nameComponents[1]))
  default:
    let firstName = nameComponents.dropLast().joined(separator: " ")
    let lastName = nameComponents.last!
    return (firstName, String(lastName))
  }
}
