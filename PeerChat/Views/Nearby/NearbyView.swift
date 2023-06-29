//
//  NearbyView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct NearbyView: View {
    @EnvironmentObject private var model: Model
    
    var body: some View {
        NavigationView{
            List{
                Section("Chats"){
                    if(model.chats.isEmpty){
                        Text("No Chats")
                    }else{
                        ForEach(Array(model.chats),id:\.value.id){id, chat in
                            NavigationLink{
                                ChatView(person:id)
                                    .navigationTitle(chat.person.name)
                            } label: {
                                Text(chat.peer.displayName)
                            }
                        }
                    }
                }
                Section("Near-By Peers"){
                    if(model.connectedPeers.isEmpty){
                        Text("No Peers")
                    }else{
                        ForEach(model.connectedPeers,id:\.hash){peer in
                            Text(peer.displayName)
                        }
                    }
                }
            }
        }
    }
}

struct NearbyView_Previews: PreviewProvider {
    
    static var model = Model()
    
    static var previews: some View {
        NearbyView().environmentObject(model)
    }
}
