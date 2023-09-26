import SwiftASN1
import SwiftUI
import X509

struct CertificateCardView: View {
  var certificate: Certificate?
  var cardColor: Color = Color.brown
  let textColor: Color = Color.white
  let padding: CGFloat = 20

  func getFingerprint(certificate: Certificate) -> String {
    do {
      var serializer = DER.Serializer()
      try serializer.serialize(certificate)
      let serializerData = Data(serializer.serializedBytes)
      let secCertificate = SecCertificateCreateWithData(nil, serializerData as CFData)
      let pubKey = SecCertificateCopyKey(secCertificate!)
      var error: Unmanaged<CFError>?
      guard let pubKeyData = SecKeyCopyExternalRepresentation(pubKey!, &error) as? Data else {
        throw error!.takeRetainedValue() as Error
      }

      return fingerprint(publicKeyData: pubKeyData)!
    } catch let error {
      print(error)
      return "error"
    }
  }

  var body: some View {
    ZStack(alignment: .leading) {
      cardColor
      VStack(alignment: .leading) {
        if let certificate = certificate {
          Text(
            getCommonName(subject: certificate.subject)
          )
          .font(.largeTitle)
          .foregroundColor(textColor)
          .bold()
          .padding(.top, padding)
          .padding(.leading, padding)
          .padding(.trailing, padding)

          Spacer()

          HStack {
            Spacer()
            Text(getFingerprint(certificate: certificate))
              .font(.caption)
              .foregroundColor(textColor)
              .padding(.bottom, padding)
              .padding(.leading, padding)
              .padding(.trailing, padding)
          }

        }
      }
    }
    .frame(width: 300, height: 150)
    .cornerRadius(20)
    .shadow(radius: 5)
  }
}

struct CertificateCardView_Preview: PreviewProvider {

  static var certificate: Certificate? {
    do {
      return try Certificate(
        pemEncoded:
          "-----BEGIN CERTIFICATE-----\nMIICwjCCAaqgAwIBAgIUIl2KhJE5UyxKYxwXkAv8fpVd8IgwDQYJKoZIhvcNAQEL\nBQAwHzEdMBsGA1UEAwwUVXNlciBJbnRlcm1lZGlhdGUgQ0EwHhcNMjMwODI1MDg1\nMjI1WhcNMjMxMDI0MDg1MjI1WjAXMRUwEwYDVQQDDAxPbGl2ZXIgS2FtZXIwggEi\nMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDLmOE2ODLdhiKe6L8MQnK5oPK6\nQhUUyVIpq/h4w2tsAhaPIs5BdSdOOQP8aDp0shipPnYMtmrp7pDFxmsFS5CRMw1J\nO5wDuSv7c455nkEiSgbjxqqRHbz51Pw+oZYn9DGWa9kKM878f6Zm76rNpwh7RXkV\n+VP2upFJ+cPE0RJsLGUF1uJpntlJXm5IJMSRRvy6FuelgPOidG5DwQEsV66H+FRa\n2zDa2oziEZaB/z2uJZGIOzYeMFiXiud5v0qXaWPBhDRR9aXUkn67h/l46kOXAQwj\nINtzEfRvYrq5fct+c1iV4pDzcTd0J8RcYhMbfl364wBgjXuMefUiIbRVVljHAgMB\nAAEwDQYJKoZIhvcNAQELBQADggEBAFfjSGFUyGvrvhI6v9WYdaX1qgAzuy6bCqp9\nW4GLWw7XYibo7Uo6wJkvMT8cxNkBAsyq9H2l0kPv3hKfk9sgx8mMIF02sWzxy1vy\nteOIs/7yw0tWPISWMszHk0WzgQlt7ZGFZc5Vq8rx50MRXTjyJfmAfbG2qtaBljdi\na2m2f7/a25JnoQpOY1H53/oUaZBQ/MwvYUYK62ial6mHI4oD1ajFIuHOG8nzuxmS\nV5cZsohJfpKUaCkDVqZFVs8YgHw9BSP/t1hPlXGBwZzNY5VK+B4c3LkO7hsGkA5z\nao6lVMcHUKvs99J+0wYSUftYnd58XyVUUwOfhy+qdlnyJGSkBZk=\n-----END CERTIFICATE-----"
      )
    } catch {
      print("Error initializing certificate: \(error)")
      return nil
    }
  }

  static var previews: some View {
    CertificateCardView(certificate: certificate)
  }
}
