import os
from datetime import datetime, timedelta

from cryptography import x509
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives._serialization import Encoding
from django.db.models.signals import post_save
from django.dispatch import receiver

from identity.models import CertificateSigningRequest, Certificate
from lib.certificatesigningrequeststatus import CertificateSigningRequestStatus


@receiver(post_save, sender=CertificateSigningRequest)
def create_certificate(sender, instance, **kwargs):
    if (
        not instance.certificate()
        and instance.status == CertificateSigningRequestStatus.APPROVED
    ):
        # CSR doesn't have a certificate yet and is approved, therefore create certificate

        csr_cert = instance.csr()

        directory = os.path.dirname(__file__)

        with open(os.path.join(directory, "x509/maca.crt"), "rb") as ca_cert_data:
            ca_cert = x509.load_pem_x509_certificate(ca_cert_data.read())

        with open(
            os.path.join(directory, "x509/user.crt"), "rb"
        ) as intermediate_cert_data:
            intermediate_cert = x509.load_pem_x509_certificate(
                intermediate_cert_data.read()
            )

        with open(os.path.join(directory, "x509/user.key"), "rb") as key_file:
            private_ca_key = serialization.load_pem_private_key(
                key_file.read(),
                password=None,
            )

        cert = (
            x509.CertificateBuilder()
            .subject_name(csr_cert.subject)
            .issuer_name(intermediate_cert.subject)
            .public_key(csr_cert.public_key())
            .serial_number(x509.random_serial_number())
            .not_valid_before(datetime.utcnow())
            .not_valid_after(
                # Our certificate will be valid for 60 days
                datetime.utcnow()
                + timedelta(days=60)
                # Sign our certificate with our private key
            )
            .sign(private_ca_key, hashes.SHA256())
        )

        chain = (
            cert.public_bytes(Encoding.PEM).decode()
            + intermediate_cert.public_bytes(Encoding.PEM).decode()
            + ca_cert.public_bytes(Encoding.PEM).decode()
        )

        Certificate.objects.create(
            csr=instance,
            user=instance.user,
            certificate_string=chain,
        )
