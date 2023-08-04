//
//  ChatView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/18/23.
//
import MultipeerConnectivity
import SwiftUI

struct ChatView: View {
  @EnvironmentObject private var model: Model
  let person: Person

  @State private var newMessage: String = ""

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { scrollView in
        VStack {
          if let nearby = model.nearby {
            ScrollView {
              VStack(spacing: 4) {
                ForEach(nearby.chats[person]!.messages, id: \.id) { message in
                  ChatMessageRow(message: message, geo: geometry)
                    .padding(.horizontal)
                }
              }
            }
            .onChange(of: nearby.chats[person]!.messages) { new in
              DispatchQueue.main.async {
                if let last = nearby.chats[person]!.messages.last {
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
                    nearby.send(newMessage, chat: nearby.chats[person]!)
                    newMessage = ""
                  }
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let last = nearby.chats[person]!.messages.last {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}

struct ChatView_Previews: PreviewProvider {

  static var model = Model()
  static var person = Person(UIDevice.current.name, id: UUID())

  static var previews: some View {
    ChatView(person: person).environmentObject(model)
  }
}