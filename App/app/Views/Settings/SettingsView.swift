//
//  SettingsView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct LocationSettingsView: View {
  @EnvironmentObject var model: Model
  @State var locations: [Location] = []

  func fetchLocations() {
    let url = URL(string: "https://master-thesis.oli.fyi/messages/locations/")!
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let data = data {
        if let decodedLocations = try? JSONDecoder().decode([Location].self, from: data) {
          DispatchQueue.main.async {
            self.locations = decodedLocations
          }
        }
      }
    }.resume()
  }

  var selectedLocationBinding: Binding<Location?> {
    Binding<Location?>(
      get: {
        self.locations.first(where: { $0.postcode == self.model.location })
      },
      set: {
        self.model.location = $0?.postcode ?? 0  // or another default value
      }
    )
  }

  var body: some View {
    NavigationView {
      Form {
        HStack {
          Text("Location")  // This is the label on the left
          Spacer()
          if locations.count < 1 {
            // Show loading wheel if locations are being loaded
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
          } else {
            Picker(selection: selectedLocationBinding, label: EmptyView()) {  // Using EmptyView for label since we already have the label on the left
              if self.model.location == nil {
                Text("Select a location...").tag(nil as Location?)
              }
              ForEach(locations, id: \.self) { location in
                Text(postcodeFormatter(location.postcode)).tag(location as Location?)
              }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)  // Makes sure the picker takes the available space on the right
          }
        }
      }
      .navigationBarTitle("Settings")
      .onAppear(perform: fetchLocations)
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    LocationSettingsView()
      .environmentObject(Model())
  }
}
