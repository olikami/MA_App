import SwiftUI
import X509

struct CertificateView: View {
  var certificates: [Certificate]

  @State private var showOverlay = false

  var chain: [Bool] {
    var chain: [Bool] = []
    certificates.indices.forEach { index in
      if index < certificates.count - 1 {
        let child = certificates[index]
        let parent = certificates[index + 1]
        if parent.publicKey.isValidSignature(child.signature, for: child) {
          chain.append(true)
        } else {
          chain.append(false)
        }
      }
    }
    return chain.reversed()
  }

  var body: some View {
    VStack {
      if let firstCertificate = certificates.first {
        ZStack(alignment: .topTrailing) {
          CertificateCardView(
            certificate: firstCertificate,
            cardColor: getCommonName(subject: firstCertificate.issuer).contains("Community")
              ? Color.green
              : getCommonName(subject: firstCertificate.issuer).contains("Official")
                ? Color.blue : Color.teal)
          Button(action: {
            showOverlay.toggle()
          }) {
            Image(systemName: "info.circle")
              .resizable()
              .frame(width: 20, height: 20)
          }
          .foregroundColor(Color.white)
          .padding(15)
        }
      }
    }
    .frame(width: 300)
    .padding(20)
    .sheet(isPresented: $showOverlay) {
      OverlayView(certificates: certificates.reversed(), chain: chain)
        .background(Color.white.opacity(0.95))
        .padding()
        .cornerRadius(15)
    }
  }
}

struct OverlayView: View {
  var certificates: [Certificate]
  var chain: [Bool]

  var body: some View {
    VStack(spacing: 20) {
      ForEach(0..<certificates.count, id: \.self) { index in
        if index == 0 {
          if isRootCert(certificate: certificates[index]) {
            CertificateCardView(certificate: certificates[index], cardColor: Color.black)
          } else {
            CertificateCardView(certificate: certificates[index], cardColor: Color.red)
          }
        } else {
          if chain[index - 1] {
            if getCommonName(subject: certificates[index].subject).contains("User")
              || getCommonName(subject: certificates[index].issuer).contains("User")
            {
              CertificateCardView(certificate: certificates[index], cardColor: Color.teal)
            } else if getCommonName(subject: certificates[index].subject).contains("Community")
              || getCommonName(subject: certificates[index].issuer).contains("Community")
            {
              CertificateCardView(certificate: certificates[index], cardColor: Color.green)
            } else if getCommonName(subject: certificates[index].subject).contains("Official")
              || getCommonName(subject: certificates[index].issuer).contains("Official")
            {
              CertificateCardView(certificate: certificates[index], cardColor: Color.blue)
            } else {
              CertificateCardView(certificate: certificates[index])
            }
          } else {
            CertificateCardView(certificate: certificates[index], cardColor: Color.red)
          }
        }

        if index != certificates.count - 1 {
          HStack {
            Spacer()
            Image(systemName: "signature")
              .resizable()
              .foregroundColor(chain[index] ? Color.green : Color.red)
              .frame(width: 20, height: 20)
              .opacity(0)
            Image(systemName: chain[index] ? "checkmark" : "xmark")
              .resizable()
              .foregroundColor(chain[index] ? Color.green : Color.red)
              .frame(width: 20, height: 20)
              .opacity(0)
            Image(systemName: "arrow.down")
              .resizable()
              .foregroundColor(chain[index] ? Color.green : Color.red)
              .frame(width: 30, height: 30)
            Image(systemName: "signature")
              .resizable()
              .foregroundColor(chain[index] ? Color.green : Color.red)
              .frame(width: 20, height: 20)
            Image(systemName: chain[index] ? "checkmark" : "xmark")
              .resizable()
              .foregroundColor(chain[index] ? Color.green : Color.red)
              .frame(width: 18, height: 18)
            Spacer()
          }
        }
      }
    }
    .padding()
  }
}

struct CertificateView_Previews: PreviewProvider {
  static var validUserCertificate: [Certificate] {
    do {
      return [
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIICwjCCAaqgAwIBAgIUIl2KhJE5UyxKYxwXkAv8fpVd8IgwDQYJKoZIhvcNAQEL\nBQAwHzEdMBsGA1UEAwwUVXNlciBJbnRlcm1lZGlhdGUgQ0EwHhcNMjMwODI1MDg1\nMjI1WhcNMjMxMDI0MDg1MjI1WjAXMRUwEwYDVQQDDAxPbGl2ZXIgS2FtZXIwggEi\nMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDLmOE2ODLdhiKe6L8MQnK5oPK6\nQhUUyVIpq/h4w2tsAhaPIs5BdSdOOQP8aDp0shipPnYMtmrp7pDFxmsFS5CRMw1J\nO5wDuSv7c455nkEiSgbjxqqRHbz51Pw+oZYn9DGWa9kKM878f6Zm76rNpwh7RXkV\n+VP2upFJ+cPE0RJsLGUF1uJpntlJXm5IJMSRRvy6FuelgPOidG5DwQEsV66H+FRa\n2zDa2oziEZaB/z2uJZGIOzYeMFiXiud5v0qXaWPBhDRR9aXUkn67h/l46kOXAQwj\nINtzEfRvYrq5fct+c1iV4pDzcTd0J8RcYhMbfl364wBgjXuMefUiIbRVVljHAgMB\nAAEwDQYJKoZIhvcNAQELBQADggEBAFfjSGFUyGvrvhI6v9WYdaX1qgAzuy6bCqp9\nW4GLWw7XYibo7Uo6wJkvMT8cxNkBAsyq9H2l0kPv3hKfk9sgx8mMIF02sWzxy1vy\nteOIs/7yw0tWPISWMszHk0WzgQlt7ZGFZc5Vq8rx50MRXTjyJfmAfbG2qtaBljdi\na2m2f7/a25JnoQpOY1H53/oUaZBQ/MwvYUYK62ial6mHI4oD1ajFIuHOG8nzuxmS\nV5cZsohJfpKUaCkDVqZFVs8YgHw9BSP/t1hPlXGBwZzNY5VK+B4c3LkO7hsGkA5z\nao6lVMcHUKvs99J+0wYSUftYnd58XyVUUwOfhy+qdlnyJGSkBZk=\n-----END CERTIFICATE-----"
        ),
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIIDTDCCAjSgAwIBAgIUSZut6cC8ruG6IaGrc6WLwm8Vc88wDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMB4XDTIzMDcwNjIxMDczOFoXDTI0\nMTExNzIxMDczOFowHzEdMBsGA1UEAwwUVXNlciBJbnRlcm1lZGlhdGUgQ0EwggEi\nMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyEP0IR+bKXLAzyUs/nwP14A2h\nLLOcVBsqEaWAqYZ4VaHeOr15Larwp/4r1OS90LH6sGsGHgP9ej/Q2c3ZR8UdIwiU\nVye97+jwGL+dhw5gxZxBYmSfz2PSVE0vrS3XepXV0B/LTPWThFbF3Gt0kZ6M24G7\nJdCOoMSZhkdbI727dxfqQI91yAic3ty9KXD+v44paY62pel3Vpe2kx0vEUkPVC47\ngLZQTaK/lbg7lD2y++7eQejkojT54NKiIAQ4j7BxJgGtnfKrsw4UsoqYfQ7fuqbs\n8+mzr9aLM70dFrVT0RERgDa4A3DoNSPQuj4rZ6uhGeVlhDVIDyT+b+co9XrVAgMB\nAAGjgYcwgYQwHQYDVR0OBBYEFCrM6WsgJP5uh5Y0Lm947ZMk4KjAMFIGA1UdIwRL\nMEmAFCkNGZwVn09uMkf0YtSK4O3lkO0BoRukGTAXMRUwEwYDVQQDDAxNQUNBIFJv\nb3QgQ0GCFGRxThRUFJYE5OodPpkfs5J7yfstMA8GA1UdEwEB/wQFMAMBAf8wDQYJ\nKoZIhvcNAQELBQADggEBAA8GRmeGfTgopaAPemt+4jO2kgPlaIzg3jnewkvpcRIY\n03BIH2A+yZ6sDEEcF7hFirb3NpHtn8Kom3eLCS6amOE/5mmIgy32+MjwaZv1dmeI\nGBMoEHLzz5rGxiVx5vvfM7iiO4F5hGpKOjpD39gkFT5gow6ke5amk1OTtJf/7ivv\nj8Q8n9rP7enLEyHCBpSfK2JosVww0RoSQLs8pfmh+oNwhudVy21vf39hO6YOmR22\n/6V0or1929Y3mh4wFSV31+Lx4hT88O4KTk8oVDnU5cx6GS4grpR1bEufQtXslJOe\nXR6IxUY8F61ZwtUFYct5tYILFpbOLVKp5LDBd7dp/yM=\n-----END CERTIFICATE-----"
        ),
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIIDRDCCAiygAwIBAgIUZHFOFFQUlgTk6h0+mR+zknvJ+y0wDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMB4XDTIzMDcwNjIxMDY1OFoXDTI2\nMDQyNTIxMDY1OFowFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMIIBIjANBgkqhkiG\n9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs1VOIYsd6aqBO5iW4DwygdNwrqyfWA0CGhRW\nt98k0M3ttL2qOm70iHOVWG15Rqq5Mkrp78eLChnH75rHzomtrpOOgaCOyNzaKSEs\nyWPwX1c2dXI5+Tqr8ARdIwF6G7UQHG15zBIWC6amsA4CSaj2+gE7nopqh+wIRxfE\ndlHYG269Cr84Ul14S58qpN1wFkqWdq+buEtaNKjAIAkQsx2Z7hLcACHM7+qV3oxC\nbiBxDr21efTx72tacMf0CC+we1T7ox65QVQ5Bx5jLciiJdOU51qUKhS1UHSXRMce\nnecTWHieGGXSTJ1f+ICsBqy/d8KkvAGqjGeKyIgkAvS+09ZV4QIDAQABo4GHMIGE\nMB0GA1UdDgQWBBQpDRmcFZ9PbjJH9GLUiuDt5ZDtATBSBgNVHSMESzBJgBQpDRmc\nFZ9PbjJH9GLUiuDt5ZDtAaEbpBkwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBghRk\ncU4UVBSWBOTqHT6ZH7OSe8n7LTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEB\nCwUAA4IBAQCFgIBp1DMDaR1lcDKXtnam8bYiV6jC9HpgzLtM8FhlgPAIzsNLp15Q\ngR13X091hnouIFVAHiKffShaiYxo05z+Ew9j7VFKZqKOdYJdH/2gSm3rr0OZQ1ts\noKd4B2xIe1ItlCvRyIfnWf0jYTxj2x8O3F0I/9MwO19pX4bbxvGPvARUoVSzmg0v\nqKH2yci+FzH3GO8tf1RvQ+yWpeYm4OifVng6WTWzj/t7JODatwPXyJVp9YDCra6t\n6Z2Fw3UOsmwNDTKDgAqG8iQF6QSVqpnFOoKFmdCn29QoNBWxB+RQCKKCKwP2yreu\nNOHsVyR0dPYSpMVFaFN9QUuQRmpn61Bc\n-----END CERTIFICATE-----"
        ),
      ]
    } catch {
      print("Error initializing certificate: \(error)")
      return []
    }
  }

  static var invalidUserCertificate: [Certificate] {
    do {
      return [
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIIDnTCCAoWgAwIBAgIUQ7Z8F+iyhubsYoh5so6JaLa0Jx4wDQYJKoZIhvcNAQEL\nBQAwXjELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\nGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDEXMBUGA1UEAwwOSW52YWxpZCBQZXJz\nb24wHhcNMjMwODI4MTUxNzA1WhcNMjYwNjE3MTUxNzA1WjBeMQswCQYDVQQGEwJB\nVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0\ncyBQdHkgTHRkMRcwFQYDVQQDDA5JbnZhbGlkIFBlcnNvbjCCASIwDQYJKoZIhvcN\nAQEBBQADggEPADCCAQoCggEBAKpogJAIgSPeA2a7/DPiMUyXjXv419mPFbc00yzd\nqoeXlpdpFOcPYpalEznSBC+bBzp0Kz6I7Yl2JVVuAKxOsHRSjgvkFDtt/hK8/EHb\nZMQbgeg3iZVUOFjYXmLqA2y8c/4g9klPc5Cv+pK9m1rTaVDq+Yc0J8fwL2NMRigE\n2Gl5JroQcE3mP1/H2/hXPeIIEIsw0gMfCL6MbNMIG9RgakgDVwKXZaQkq3yXHFCo\n9+r+qt2boNjah5eLd4i7Zzcdfq3oHIT2/HtfQb7Z5NcgzuITaBC8jNTUeL1Kyomq\njQxpPQg0lkgxQLLRfJc1KFz03nEVX9XSuTGS2eE1a8ynyv8CAwEAAaNTMFEwHQYD\nVR0OBBYEFGpTGXNitO67ERALrf2qVFRnl1eTMB8GA1UdIwQYMBaAFGpTGXNitO67\nERALrf2qVFRnl1eTMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEB\nADtemHz98skJnCq4k4RQlG5TgCLeo/C5ukNnv7Ya5XdWMDQv+biuTe/2EHf3YoBG\nktTr6zaTfslf1YniVnTETt6Lv6Igh48fTmXSSjXDhSsdayIcz3JlYf22K/AeJWQh\nnzOSxuOrSM+xq5KEioS9H2ReDP3uDkaclDvERMceQjgreOqKWDrp/H9PSi/NW3IA\nLWxt4F2I8L6dPcK42DMTrFzFwzmr9gx0l57bFSjd9XzkvdR1byjenXavds+g3vos\nfuJWltzeoq1PYxQVAzVHMpT/+AoLj8BcW7tfX1iKPhUy5BsC8DwxSRS981m+vc1H\nzKNDRtFlNvVDRke7vxloL7I=\n-----END CERTIFICATE-----"
        ),
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIIDTDCCAjSgAwIBAgIUSZut6cC8ruG6IaGrc6WLwm8Vc88wDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMB4XDTIzMDcwNjIxMDczOFoXDTI0\nMTExNzIxMDczOFowHzEdMBsGA1UEAwwUVXNlciBJbnRlcm1lZGlhdGUgQ0EwggEi\nMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyEP0IR+bKXLAzyUs/nwP14A2h\nLLOcVBsqEaWAqYZ4VaHeOr15Larwp/4r1OS90LH6sGsGHgP9ej/Q2c3ZR8UdIwiU\nVye97+jwGL+dhw5gxZxBYmSfz2PSVE0vrS3XepXV0B/LTPWThFbF3Gt0kZ6M24G7\nJdCOoMSZhkdbI727dxfqQI91yAic3ty9KXD+v44paY62pel3Vpe2kx0vEUkPVC47\ngLZQTaK/lbg7lD2y++7eQejkojT54NKiIAQ4j7BxJgGtnfKrsw4UsoqYfQ7fuqbs\n8+mzr9aLM70dFrVT0RERgDa4A3DoNSPQuj4rZ6uhGeVlhDVIDyT+b+co9XrVAgMB\nAAGjgYcwgYQwHQYDVR0OBBYEFCrM6WsgJP5uh5Y0Lm947ZMk4KjAMFIGA1UdIwRL\nMEmAFCkNGZwVn09uMkf0YtSK4O3lkO0BoRukGTAXMRUwEwYDVQQDDAxNQUNBIFJv\nb3QgQ0GCFGRxThRUFJYE5OodPpkfs5J7yfstMA8GA1UdEwEB/wQFMAMBAf8wDQYJ\nKoZIhvcNAQELBQADggEBAA8GRmeGfTgopaAPemt+4jO2kgPlaIzg3jnewkvpcRIY\n03BIH2A+yZ6sDEEcF7hFirb3NpHtn8Kom3eLCS6amOE/5mmIgy32+MjwaZv1dmeI\nGBMoEHLzz5rGxiVx5vvfM7iiO4F5hGpKOjpD39gkFT5gow6ke5amk1OTtJf/7ivv\nj8Q8n9rP7enLEyHCBpSfK2JosVww0RoSQLs8pfmh+oNwhudVy21vf39hO6YOmR22\n/6V0or1929Y3mh4wFSV31+Lx4hT88O4KTk8oVDnU5cx6GS4grpR1bEufQtXslJOe\nXR6IxUY8F61ZwtUFYct5tYILFpbOLVKp5LDBd7dp/yM=\n-----END CERTIFICATE-----"
        ),
        try Certificate(
          pemEncoded:
            "-----BEGIN CERTIFICATE-----\nMIIDRDCCAiygAwIBAgIUZHFOFFQUlgTk6h0+mR+zknvJ+y0wDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMB4XDTIzMDcwNjIxMDY1OFoXDTI2\nMDQyNTIxMDY1OFowFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMIIBIjANBgkqhkiG\n9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs1VOIYsd6aqBO5iW4DwygdNwrqyfWA0CGhRW\nt98k0M3ttL2qOm70iHOVWG15Rqq5Mkrp78eLChnH75rHzomtrpOOgaCOyNzaKSEs\nyWPwX1c2dXI5+Tqr8ARdIwF6G7UQHG15zBIWC6amsA4CSaj2+gE7nopqh+wIRxfE\ndlHYG269Cr84Ul14S58qpN1wFkqWdq+buEtaNKjAIAkQsx2Z7hLcACHM7+qV3oxC\nbiBxDr21efTx72tacMf0CC+we1T7ox65QVQ5Bx5jLciiJdOU51qUKhS1UHSXRMce\nnecTWHieGGXSTJ1f+ICsBqy/d8KkvAGqjGeKyIgkAvS+09ZV4QIDAQABo4GHMIGE\nMB0GA1UdDgQWBBQpDRmcFZ9PbjJH9GLUiuDt5ZDtATBSBgNVHSMESzBJgBQpDRmc\nFZ9PbjJH9GLUiuDt5ZDtAaEbpBkwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBghRk\ncU4UVBSWBOTqHT6ZH7OSe8n7LTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEB\nCwUAA4IBAQCFgIBp1DMDaR1lcDKXtnam8bYiV6jC9HpgzLtM8FhlgPAIzsNLp15Q\ngR13X091hnouIFVAHiKffShaiYxo05z+Ew9j7VFKZqKOdYJdH/2gSm3rr0OZQ1ts\noKd4B2xIe1ItlCvRyIfnWf0jYTxj2x8O3F0I/9MwO19pX4bbxvGPvARUoVSzmg0v\nqKH2yci+FzH3GO8tf1RvQ+yWpeYm4OifVng6WTWzj/t7JODatwPXyJVp9YDCra6t\n6Z2Fw3UOsmwNDTKDgAqG8iQF6QSVqpnFOoKFmdCn29QoNBWxB+RQCKKCKwP2yreu\nNOHsVyR0dPYSpMVFaFN9QUuQRmpn61Bc\n-----END CERTIFICATE-----"
        ),
      ]
    } catch {
      print("Error initializing certificate: \(error)")
      return []
    }
  }

  static var previews: some View {
    CertificateView(certificates: validUserCertificate)
    CertificateView(certificates: invalidUserCertificate)
  }
}
