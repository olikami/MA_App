import Combine
import SwiftUI

struct PageTwo: View {
  let nextPage: () -> Void

  @State private var fullName: String = ""
  @EnvironmentObject var model: Model
  @State private var showInvalidNameMessage: Bool = false

  // Timer-related property set to 3 seconds
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var isNameValid: Bool {
    let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    let nameComponents = trimmedName.components(separatedBy: .whitespaces)
    let distinctWords = Set(nameComponents)
    return distinctWords.count >= 2
  }

  var body: some View {
    VStack(spacing: 20) {
      Text("Name")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Please enter your full name. The full name will later be used to identify you.")
        .font(.body)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)

      TextField("Full Name", text: $fullName)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal, 20)

      if showInvalidNameMessage {
        Text("Please enter both first and last name.")
          .foregroundColor(.red)
          .transition(.opacity)
      }

      Button(action: {
        model.createPerson(name: fullName)
        nextPage()
      }) {
        Text("Submit")
          .font(.headline)
          .padding()
          .background(isNameValid ? Color.blue : Color(.lightGray))
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .disabled(!isNameValid)
    }
    .animation(.easeInOut(duration: 0.5), value: showInvalidNameMessage)
    .onReceive(timer) { _ in
      if !self.isNameValid && !self.fullName.isEmpty {
        self.showInvalidNameMessage = true
      } else {
        self.showInvalidNameMessage = false
      }
    }
  }
}
