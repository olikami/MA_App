from django.db import models


class CertificateSigningRequestStatus(models.IntegerChoices):
    NEW = 0
    APPROVED = 1
    DENIED = -1
