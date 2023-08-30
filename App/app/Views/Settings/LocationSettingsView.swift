//
//  LocationSettingsView.swift
//  app
//
//  Created by Oliver Kamer on 30.08.23.
//

import SwiftUI

struct LocationSettingsView: View {
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
      NavigationView{
        Form {
          Picker(selection: selectedLocationBinding, label: Text("Location")) {
            if self.model.location == nil {
              Text("Select a location...").tag(nil as Location?)
            }
            ForEach(locations, id: \.self) { location in
              Text(postcodeFormatter(location.postcode)).tag(location as Location?)
            }
          }
        }
        .navigationBarTitle("Settings")
        .onAppear(perform: fetchLocations)
      }
    }
    }
}

struct LocationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSettingsView()
    }
}
