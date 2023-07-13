import uuid as uuid

from cryptography import x509
from django.db import models


class ApplicationUser(models.Model):
    # Create a UUID as a primary key as to not leak the information
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)

    def short_uuid(self):
        first_uuid_group = str(self.uuid).split("-")[0]
        return first_uuid_group

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.short_uuid()})"

    def certificate_requests(self):
        return self.certificatesigningrequest_set.order_by("-created")

    def latest_certificate_request(self):
        return self.certificate_requests().first()


certificate_signing_request_statuses = [
    (0, "new"), (1, "approved"), (2, "denied")
]


class CertificateSigningRequest(models.Model):
    # Create a UUID as a primary key as to not leak the information
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created = models.DateTimeField(auto_now_add=True, editable=False)

    user = models.ForeignKey("ApplicationUser", on_delete=models.CASCADE)

    csr_string = models.CharField(max_length=2048)

    status = models.IntegerField(choices=certificate_signing_request_statuses, default=0)

    def csr(self):
        return x509.load_pem_x509_csr(self.csr_string.encode())
