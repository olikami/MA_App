//
//  rootCert.swift
//  app
//
//  Created by Oliver Kamer on 28.08.23.
//

import Foundation
import X509

func isRootCert(certificate: Certificate) -> Bool {
  let rootString =
    "-----BEGIN CERTIFICATE-----\nMIIDRDCCAiygAwIBAgIUZHFOFFQUlgTk6h0+mR+zknvJ+y0wDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMB4XDTIzMDcwNjIxMDY1OFoXDTI2\nMDQyNTIxMDY1OFowFzEVMBMGA1UEAwwMTUFDQSBSb290IENBMIIBIjANBgkqhkiG\n9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs1VOIYsd6aqBO5iW4DwygdNwrqyfWA0CGhRW\nt98k0M3ttL2qOm70iHOVWG15Rqq5Mkrp78eLChnH75rHzomtrpOOgaCOyNzaKSEs\nyWPwX1c2dXI5+Tqr8ARdIwF6G7UQHG15zBIWC6amsA4CSaj2+gE7nopqh+wIRxfE\ndlHYG269Cr84Ul14S58qpN1wFkqWdq+buEtaNKjAIAkQsx2Z7hLcACHM7+qV3oxC\nbiBxDr21efTx72tacMf0CC+we1T7ox65QVQ5Bx5jLciiJdOU51qUKhS1UHSXRMce\nnecTWHieGGXSTJ1f+ICsBqy/d8KkvAGqjGeKyIgkAvS+09ZV4QIDAQABo4GHMIGE\nMB0GA1UdDgQWBBQpDRmcFZ9PbjJH9GLUiuDt5ZDtATBSBgNVHSMESzBJgBQpDRmc\nFZ9PbjJH9GLUiuDt5ZDtAaEbpBkwFzEVMBMGA1UEAwwMTUFDQSBSb290IENBghRk\ncU4UVBSWBOTqHT6ZH7OSe8n7LTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEB\nCwUAA4IBAQCFgIBp1DMDaR1lcDKXtnam8bYiV6jC9HpgzLtM8FhlgPAIzsNLp15Q\ngR13X091hnouIFVAHiKffShaiYxo05z+Ew9j7VFKZqKOdYJdH/2gSm3rr0OZQ1ts\noKd4B2xIe1ItlCvRyIfnWf0jYTxj2x8O3F0I/9MwO19pX4bbxvGPvARUoVSzmg0v\nqKH2yci+FzH3GO8tf1RvQ+yWpeYm4OifVng6WTWzj/t7JODatwPXyJVp9YDCra6t\n6Z2Fw3UOsmwNDTKDgAqG8iQF6QSVqpnFOoKFmdCn29QoNBWxB+RQCKKCKwP2yreu\nNOHsVyR0dPYSpMVFaFN9QUuQRmpn61Bc\n-----END CERTIFICATE-----"

  do {
    let rootCert = try Certificate(pemEncoded: rootString)
    if rootCert.serialNumber == certificate.serialNumber
      && rootCert.publicKey == certificate.publicKey
    {
      return true
    }
  } catch let error {
    print(error)

  }
  return false
}
