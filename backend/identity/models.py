import uuid as uuid

from cryptography import x509
from django.db import models
from cryptography.x509.oid import NameOID

from lib.certificatesigningrequeststatus import CertificateSigningRequestStatus
from lib.uuid import short_uuid


class ApplicationUser(models.Model):
    # Create a UUID as a primary key as to not leak the information
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)

    def short_uuid(self):
        return short_uuid(self.uuid)

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.short_uuid()})"

    def certificate_requests(self):
        return self.certificatesigningrequest_set.order_by("-created")

    def latest_certificate_request(self):
        return self.certificate_requests.first()

    def latest_certificate(self):
        if self.certificate_set.exists():
            return self.certificate_set.order_by("-created").first()
        return None


class CertificateSigningRequest(models.Model):
    # Create a UUID as a primary key as to not leak the information
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created = models.DateTimeField(auto_now_add=True, editable=False)

    user = models.ForeignKey("ApplicationUser", on_delete=models.CASCADE)

    csr_string = models.TextField()

    status = models.IntegerField(
        choices=CertificateSigningRequestStatus.choices, default=0
    )

    def csr(self):
        return x509.load_pem_x509_csr(self.csr_string.encode())

    def common_name(self):
        csr = self.csr()
        subject = csr.subject
        common_name = subject.get_attributes_for_oid(NameOID.COMMON_NAME)[0].value
        return common_name

    def certificate(self):
        try:
            return self.cert
        except CertificateSigningRequest.cert.RelatedObjectDoesNotExist:
            return None

    def __str__(self):
        return f"CSR from {self.user} for {self.common_name()} on {self.created.isoformat()}"


class Certificate(models.Model):
    csr = models.OneToOneField(
        "CertificateSigningRequest",
        models.CASCADE,
        related_name="cert",
        primary_key=True,
        editable=False,
    )
    created = models.DateTimeField(auto_now_add=True, editable=False)

    user = models.ForeignKey(
        "ApplicationUser", on_delete=models.CASCADE, editable=False
    )

    certificate_string = models.TextField(editable=False)

    def subject(self):
        cert = x509.load_pem_x509_certificate(self.certificate_string.encode())
        return cert.subject.rfc4514_string()

    def __str__(self):
        return self.subject()
