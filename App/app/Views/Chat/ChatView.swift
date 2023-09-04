//
//  ChatView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/18/23.
//
import MultipeerConnectivity
import SwiftUI

struct ChatView: View {
  var messages: [Message]
  var sendMessage: (String) -> Void

  @State private var newMessage: String = ""

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { scrollView in
        VStack {
          ScrollView {
            VStack(spacing: 4) {
              ForEach(messages, id: \.id) { message in
                ChatMessageRow(message: message, geo: geometry, isCurrentUser: true)
                  .padding(.horizontal)
              }
            }
          }
          .onChange(of: messages) { new in
            DispatchQueue.main.async {
              if let last = messages.last {
                withAnimation(.spring()) {
                  scrollView.scrollTo(last.id)
                }
              } else {
                print("Messages changed but no new message?")
              }
            }
          }
          HStack {
            TextField("Enter a message", text: $newMessage, axis: .vertical)
              .textFieldStyle(RoundedTextFieldStyle())
              .animation(.spring(), value: newMessage)
              .padding(.horizontal)

            Button {
              if !newMessage.isEmpty {
                DispatchQueue.main.async {
                  sendMessage(newMessage)
                  newMessage = ""
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  if let last = messages.last {
                    print("Scrolling to last!")
                    withAnimation(.spring()) {
                      scrollView.scrollTo(last.id)
                    }
                  } else {
                    print("No last message")
                  }
                }
              }
            } label: {
              Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)
                .opacity(newMessage.isEmpty ? 0 : 1).animation(.spring(), value: newMessage)
            }
            .frame(maxWidth: newMessage.isEmpty ? 0 : nil)
            .animation(.spring(), value: newMessage)
          }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}

struct ChatView_Previews: PreviewProvider {

  static var model = Model()
  static var person = Person(UIDevice.current.name, id: UUID())

  static func sendMessage(newMessage: String) {
    return
  }

  static var previews: some View {
    ChatView(messages: model.communityMessages, sendMessage: sendMessage).environmentObject(model)
  }
}
